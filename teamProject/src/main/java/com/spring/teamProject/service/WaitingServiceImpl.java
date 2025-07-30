package com.spring.teamProject.service;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.spring.teamProject.dao.WaitingDAO;
import com.spring.teamProject.vo.WaitingVO;
import com.spring.teamProject.vo.WaitingSettingVO; // WaitingSettingVO 임포트 추가

@Service
public class WaitingServiceImpl implements WaitingService {

    @Autowired
    private WaitingDAO waitingDAO;

    @Autowired
    private FCMService fcmService;

    @Autowired
    private WaitingSettingService waitingSettingService; // WaitingSettingService 주입 추가

    @Override
    @Transactional
    public int registerWaiting(WaitingVO waitingVO) {
        System.out.println("DEBUG: registerWaiting 메서드 시작");
        return insertAndSyncToFirebase(waitingVO);
    }

    @Override
    @Transactional
    public void insertWaiting(WaitingVO waiting) {
        System.out.println("DEBUG: insertWaiting 메서드 시작");
        insertAndSyncToFirebase(waiting);
    }

    // 웨이팅 등록 및 Firebase 동기화 처리
    private int insertAndSyncToFirebase(WaitingVO waitingVO) {
        System.out.println("DEBUG: insertAndSyncToFirebase 메서드 시작");
        System.out.println("DEBUG: 초기 waitingVO 상태: " + waitingVO.getStatus());

        // **1. 웨이팅 설정 및 활성화/비활성화, 최대 팀 수 제한 로직 추가 시작 **
        Long storeId = waitingVO.getStoreId();
        WaitingSettingVO setting = waitingSettingService.getSetting(storeId); // 해당 매장의 웨이팅 설정 가져오기

        if (setting == null) {
            System.err.println("ERROR: 매장 ID " + storeId + "에 대한 웨이팅 설정이 존재하지 않습니다.");
            // 설정이 없으면 웨이팅 불가. 적절한 예외를 던지거나 특정 에러 코드 반환
            // 여기서는 0을 반환하여 실패를 알리고, 호출하는 컨트롤러에서 이 값을 확인하여 사용자에게 메시지 전달
            throw new IllegalStateException("웨이팅 설정을 먼저 등록해야 합니다."); // RuntimeException 발생
        }

        if (!setting.isActive()) {
            System.err.println("INFO: 매장 ID " + storeId + "의 웨이팅이 현재 비활성화되어 있습니다.");
            throw new IllegalStateException("현재 웨이팅 접수 시간이 아닙니다. 잠시 후 다시 시도해주세요."); // RuntimeException 발생
        }

        // 현재 대기 중인 팀 수 조회
        // 이 메소드는 WaitingDAO와 WaitingService 인터페이스에 추가해야 합니다.
        int currentWaitingCount = waitingDAO.countCurrentWaitings(storeId); // DAO 호출

        if (currentWaitingCount >= setting.getMaxTeams()) {
            System.err.println("INFO: 매장 ID " + storeId + "의 웨이팅이 최대 팀 수(" + setting.getMaxTeams() + ")에 도달했습니다.");
            throw new IllegalStateException("현재 웨이팅 팀 수가 가득 찼습니다. 잠시 후 다시 시도해주세요."); // RuntimeException 발생
        }
        // ** 웨이팅 설정 및 활성화/비활성화, 최대 팀 수 제한 로직 추가 끝 **

        // status가 설정되지 않았으면 기본값 "WAITING" 설정
        if (waitingVO.getStatus() == null || waitingVO.getStatus().isEmpty()) {
            waitingVO.setStatus("WAITING");
        }
        System.out.println("DEBUG: 최종 waitingVO 상태 설정 후: " + waitingVO.getStatus());

        // 1. MyBatis를 통해 MySQL DB에 웨이팅 정보를 저장합니다.
        System.out.println("DEBUG: MySQL DAO insertWaiting 호출 전");
        int result = waitingDAO.insertWaiting(waitingVO);
        System.out.println("DEBUG: MySQL DAO insertWaiting 호출 후. 결과(result): " + result);
        System.out.println("DEBUG: MySQL DB 저장 후 waitingVO.waitingId: " + waitingVO.getWaitingId());

        // 2. Firebase Realtime Database에 실시간으로 동기화합니다.
        System.out.println("DEBUG: Firebase 동기화 조건 확인: result > 0 && waitingVO.getWaitingId() != null");
        if (result > 0 && waitingVO.getWaitingId() != null) {
            System.out.println("DEBUG: Firebase 동기화 조건 만족! Firebase 연동 로직 시작.");

            try {
                final FirebaseDatabase database = FirebaseDatabase.getInstance();
                System.out.println("DEBUG: FirebaseDatabase.getInstance() 성공.");

                DatabaseReference ref = database.getReference("waitings")
                                                .child(String.valueOf(waitingVO.getStoreId()))
                                                .child(String.valueOf(waitingVO.getWaitingId()));
                System.out.println("DEBUG: Firebase Reference 경로: " + ref.toString());

                Map<String, Object> waitingMap = new HashMap<>();
                waitingMap.put("memberId", waitingVO.getMemberId());
                waitingMap.put("storeId", waitingVO.getStoreId());
                waitingMap.put("guestCount", waitingVO.getGuestCount());
                waitingMap.put("status", waitingVO.getStatus());
                waitingMap.put("fcmToken", waitingVO.getFcmToken());

                if (waitingVO.getCreatedAt() != null) {
                    waitingMap.put("createdAt", waitingVO.getCreatedAt().atZone(ZoneId.of("Asia/Seoul")).toInstant().toEpochMilli());
                } else {
                    waitingMap.put("createdAt", System.currentTimeMillis());
                }
                if (waitingVO.getUpdatedAt() != null) {
                    waitingMap.put("updatedAt", waitingVO.getUpdatedAt().atZone(ZoneId.of("Asia/Seoul")).toInstant().toEpochMilli());
                } else {
                    waitingMap.put("updatedAt", System.currentTimeMillis());
                }
                System.out.println("DEBUG: Firebase로 보낼 데이터: " + waitingMap);

                ref.updateChildren(waitingMap, (error, ref1) -> {
                    if (error != null) {
                        System.err.println("Firebase updateChildren failed for new waiting (ID: " + waitingVO.getWaitingId() + "): " + error.getMessage());
                    } else {
                        System.out.println("Firebase new waiting added/updated successfully (ID: " + waitingVO.getWaitingId() + ")");
                    }
                });
                System.out.println("DEBUG: Firebase updateChildren 호출 완료 (비동기).");

            } catch (Exception e) {
                System.err.println("DEBUG ERROR: Firebase 초기화 또는 데이터베이스 접근 중 예외 발생: " + e.getMessage());
                e.printStackTrace();
            }

        } else {
            System.out.println("DEBUG: Firebase 동기화 조건 불만족 (result=" + result + ", waitingId=" + waitingVO.getWaitingId() + ")");
        }
        return result;
    }

    @Override
    @Transactional
    public void updateWaitingStatus(Long waitingId, String status) {
        waitingDAO.updateWaitingStatus(waitingId, status);

        WaitingVO waiting = waitingDAO.getWaitingById(waitingId);

        if (waiting != null) {
            final FirebaseDatabase database = FirebaseDatabase.getInstance();
            DatabaseReference ref = database.getReference("waitings")
                                            .child(String.valueOf(waiting.getStoreId()))
                                            .child(String.valueOf(waiting.getWaitingId()));

            Map<String, Object> updates = new HashMap<>();
            updates.put("status", status);
            updates.put("updatedAt", System.currentTimeMillis());

            ref.updateChildren(updates, (error, ref1) -> {
                if (error != null) {
                    System.err.println("Firebase status update failed for waiting (ID: " + waitingId + "): " + error.getMessage());
                } else {
                    System.out.println("Firebase status updated successfully: " + waitingId + " to " + status);
                }
            });

            if ("CALLED".equalsIgnoreCase(status) || "READY".equalsIgnoreCase(status)) {
                String fcmToken = waiting.getFcmToken();
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
    @Transactional
    public void deleteWaiting(Long waitingId) {
        WaitingVO waiting = waitingDAO.getWaitingById(waitingId);
        waitingDAO.deleteWaiting(waitingId);

        if (waiting != null) {
            final FirebaseDatabase database = FirebaseDatabase.getInstance();
            DatabaseReference ref = database.getReference("waitings")
                                            .child(String.valueOf(waiting.getStoreId()))
                                            .child(String.valueOf(waiting.getWaitingId()));
            ref.removeValueAsync();
        }
    }

    @Override
    public List<WaitingVO> getAllWaitings() {
        return waitingDAO.getAllWaitings();
    }

    @Override
    public WaitingVO getWaitingById(Long waitingId) {
        return waitingDAO.getWaitingById(waitingId);
    }

    // 새롭게 추가: 현재 대기중인 팀 수를 세는 메소드 구현
    @Override
    public int getCurrentWaitingCount(Long storeId) {
        return waitingDAO.countCurrentWaitings(storeId);
    }
}