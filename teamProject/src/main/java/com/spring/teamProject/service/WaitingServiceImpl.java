package com.spring.teamProject.service;

import java.time.LocalDateTime; // LocalDateTime 임포트 추가
import java.time.ZoneId;       // ZoneId 임포트 추가
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // 트랜잭션 관리를 위해 추가

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.spring.teamProject.dao.WaitingDAO;
import com.spring.teamProject.vo.WaitingVO;

@Service
public class WaitingServiceImpl implements WaitingService {

	@Autowired
    private WaitingDAO waitingDAO;

	@Autowired
    private FCMService fcmService; // FCM 서비스 주입

	// 인터페이스에 추가하신 MVC 폼 전송용 메서드 구현
    @Override
    @Transactional // DB 및 Firebase 작업이 함께 수행되도록 트랜잭션 처리
    public int registerWaiting(WaitingVO waitingVO) {
        // 사실상 insertWaiting과 동일한 로직을 수행합니다.
        return insertAndSyncToFirebase(waitingVO);
    }

    // 핵심 등록 메서드
    @Override
    @Transactional // DB 및 Firebase 작업이 함께 수행되도록 트랜잭션 처리
    public void insertWaiting(WaitingVO waiting) {
        insertAndSyncToFirebase(waiting);
    }

    // 웨이팅 등록 및 Firebase 동기화 처리
    private int insertAndSyncToFirebase(WaitingVO waitingVO) {
        // status가 설정되지 않았으면 기본값 "WAITING" 설정
        if (waitingVO.getStatus() == null || waitingVO.getStatus().isEmpty()) {
            waitingVO.setStatus("WAITING");
        }

        // 1. MyBatis를 통해 MySQL DB에 웨이팅 정보를 저장합니다.
        // insert 성공 시 waitingVO 객체에 auto-increment된 waitingId가 자동으로 채워집니다.
        int result = waitingDAO.insertWaiting(waitingVO);

        // 2. Firebase Realtime Database에 실시간으로 동기화합니다.
        if (result > 0 && waitingVO.getWaitingId() != null) {
            final FirebaseDatabase database = FirebaseDatabase.getInstance();
            // 데이터 구조: /waitings/{storeId}/{waitingId}
            DatabaseReference ref = database.getReference("waitings")
                                            .child(String.valueOf(waitingVO.getStoreId()))
                                            .child(String.valueOf(waitingVO.getWaitingId()));

            // WaitingVO 객체의 필드를 Map으로 변환하여 Firebase에 보낼 데이터 구성
            Map<String, Object> waitingMap = new HashMap<>();
            waitingMap.put("memberId", waitingVO.getMemberId());
            waitingMap.put("storeId", waitingVO.getStoreId());
            waitingMap.put("guestCount", waitingVO.getGuestCount());
            waitingMap.put("status", waitingVO.getStatus());
            waitingMap.put("fcmToken", waitingVO.getFcmToken());

            // createdAt 필드 변환: LocalDateTime -> Epoch Milliseconds
            if (waitingVO.getCreatedAt() != null) {
                waitingMap.put("createdAt", waitingVO.getCreatedAt().atZone(ZoneId.of("Asia/Seoul")).toInstant().toEpochMilli());
            } else {
                // DB에서 NOW()로 저장되더라도 객체에 바로 반영되지 않을 수 있으므로, 현재 시간을 사용
                waitingMap.put("createdAt", System.currentTimeMillis());
            }

            // updatedAt 필드 변환: LocalDateTime -> Epoch Milliseconds
            if (waitingVO.getUpdatedAt() != null) {
                waitingMap.put("updatedAt", waitingVO.getUpdatedAt().atZone(ZoneId.of("Asia/Seoul")).toInstant().toEpochMilli());
            } else {
                // DB에서 NOW()로 저장되더라도 객체에 바로 반영되지 않을 수 있으므로, 현재 시간을 사용
                waitingMap.put("updatedAt", System.currentTimeMillis());
            }

            // Firebase에 데이터 업데이트 (updateChildren 사용 및 CompletionListener 추가)
            ref.updateChildren(waitingMap, (error, ref1) -> {
                if (error != null) {
                    System.err.println("Firebase updateChildren failed for new waiting (ID: " + waitingVO.getWaitingId() + "): " + error.getMessage());
                } else {
                    System.out.println("Firebase new waiting added/updated successfully (ID: " + waitingVO.getWaitingId() + ")");
                }
            });
        }
        return result;
    }

    @Override
    @Transactional // DB 및 Firebase 작업이 함께 수행되도록 트랜잭션 처리
    public void updateWaitingStatus(Long waitingId, String status) {
        // 1. MySQL DB 상태 업데이트
        waitingDAO.updateWaitingStatus(waitingId, status);

        // 2. FCM 토큰 및 Firebase 경로 생성을 위해 웨이팅 정보 조회
        WaitingVO waiting = waitingDAO.getWaitingById(waitingId);

        // 3. Firebase 상태 업데이트 및 푸시 알림 전송
        if (waiting != null) {
            final FirebaseDatabase database = FirebaseDatabase.getInstance();
            DatabaseReference ref = database.getReference("waitings")
                                            .child(String.valueOf(waiting.getStoreId()))
                                            .child(String.valueOf(waiting.getWaitingId()));

            // Firebase에 업데이트할 데이터 (status와 updatedAt)
            Map<String, Object> updates = new HashMap<>();
            updates.put("status", status);
            updates.put("updatedAt", System.currentTimeMillis()); // 현재 시간을 Epoch Milliseconds로 업데이트

            // Firebase 데이터 업데이트 (updateChildren 사용 및 CompletionListener 추가)
            ref.updateChildren(updates, (error, ref1) -> {
                if (error != null) {
                    System.err.println("Firebase status update failed for waiting (ID: " + waitingId + "): " + error.getMessage());
                } else {
                    System.out.println("Firebase status updated successfully: " + waitingId + " to " + status);
                }
            });

            // 4. 'CALLED' 또는 'READY' 상태일 때 푸시 알림 전송
            if ("CALLED".equalsIgnoreCase(status) || "READY".equalsIgnoreCase(status)) {
                String fcmToken = waiting.getFcmToken();
                // FCM 토큰이 유효한 경우에만 알림 전송
                if (fcmToken != null && !fcmToken.isEmpty()) {
                    fcmService.sendNotification(
                        fcmToken,
                        "입장 안내",
                        "고객님의 순서가 되었습니다. 카운터로 와주세요. (대기번호: " + waiting.getWaitingId() + ")"
                    );
                } else {
                    System.out.println("FCM Token is missing for waiting ID: " + waiting.getWaitingId() + ". Skipping notification.");
                }
            }
        }
    }

    @Override
    @Transactional // DB 및 Firebase 작업이 함께 수행되도록 트랜잭션 처리
    public void deleteWaiting(Long waitingId) {
        // 1. 삭제하기 전에 Firebase 경로를 찾기 위해 웨이팅 정보를 먼저 조회합니다.
        WaitingVO waiting = waitingDAO.getWaitingById(waitingId);

        // 2. MySQL DB에서 웨이팅 정보를 삭제합니다.
        waitingDAO.deleteWaiting(waitingId);

        // 3. Firebase에서도 해당 웨이팅 정보를 삭제합니다.
        if (waiting != null) {
            final FirebaseDatabase database = FirebaseDatabase.getInstance();
            DatabaseReference ref = database.getReference("waitings")
                                            .child(String.valueOf(waiting.getStoreId()))
                                            .child(String.valueOf(waiting.getWaitingId()));
            // 비동기 방식으로 데이터 삭제
            ref.removeValueAsync();
        }
    }

    // 인터페이스의 다른 메서드들 구현
    @Override
    public List<WaitingVO> getAllWaitings() {
        return waitingDAO.getAllWaitings();
    }

    @Override
    public WaitingVO getWaitingById(Long waitingId) {
        return waitingDAO.getWaitingById(waitingId);
    }
}