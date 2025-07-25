package com.spring.teamProject.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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
    public int registerWaiting(WaitingVO waitingVO) {
        // 사실상 insertWaiting과 동일한 로직을 수행합니다.
        return insertAndSyncToFirebase(waitingVO);
    }
    
    // 핵심 등록 메서드
    @Override
    public void insertWaiting(WaitingVO waiting) {
        insertAndSyncToFirebase(waiting);
    }

    private int insertAndSyncToFirebase(WaitingVO waitingVO) {
        // **여기에 status 초기화 로직 추가**
        // 만약 waitingVO에 status 값이 없다면, 기본값 "WAITING"을 설정합니다.
        // 이렇게 하면 DB에 NULL이 들어가는 것을 방지합니다.
        if (waitingVO.getStatus() == null || waitingVO.getStatus().isEmpty()) {
            waitingVO.setStatus("WAITING");
        }

        // 1. MyBatis를 통해 기존 DB(MariaDB/MySQL 등)에 웨이팅 정보를 저장합니다.
        int result = waitingDAO.insertWaiting(waitingVO); // insert 성공 시 영향받은 행의 수를 반환한다고 가정

        // DB에 insert 후, MyBatis 설정에 따라 waitingVO 객체에 auto-increment된 waitingId가 자동으로 채워져야 합니다.

        // 2. Firebase Realtime Database에 실시간으로 동기화합니다.
        if (result > 0 && waitingVO.getWaitingId() != null) {
            final FirebaseDatabase database = FirebaseDatabase.getInstance();
            // 체계적인 데이터 구조를 위해 /waitings/{storeId}/{waitingId} 경로를 사용합니다.
            DatabaseReference ref = database.getReference("waitings")
                                            .child(String.valueOf(waitingVO.getStoreId()))
                                            .child(String.valueOf(waitingVO.getWaitingId()));
            ref.setValueAsync(waitingVO); // 비동기 방식으로 데이터를 씁니다.
        }
        return result;
    }

    @Override
    public void updateWaitingStatus(Long waitingId, String status) {
        // 1. 기존 DB 상태 업데이트
        waitingDAO.updateWaitingStatus(waitingId, status);

        // 2. fcmToken 등 추가 정보를 위해 웨이팅 정보 조회
        WaitingVO waiting = waitingDAO.getWaitingById(waitingId);
        
        // 3. Firebase 상태 업데이트
        if (waiting != null) {
            final FirebaseDatabase database = FirebaseDatabase.getInstance();
            DatabaseReference ref = database.getReference("waitings")
                                            .child(String.valueOf(waiting.getStoreId()))
                                            .child(String.valueOf(waiting.getWaitingId()));
            ref.child("status").setValueAsync(status);

            // 4. '호출' 또는 '입장준비'와 같은 특정 상태일 때 푸시 알림 전송
            if ("CALLED".equalsIgnoreCase(status) || "READY".equalsIgnoreCase(status)) {
                String fcmToken = waiting.getFcmToken();
                fcmService.sendNotification(
                    fcmToken,
                    "입장 안내", 
                    "고객님의 순서가 되었습니다. 카운터로 와주세요. (대기번호: " + waiting.getWaitingId() + ")"
                );
            }
        }
    }

    @Override
    public void deleteWaiting(Long waitingId) {
        // 1. 삭제하기 전에 Firebase 경로를 찾기 위해 웨이팅 정보를 먼저 조회합니다.
        WaitingVO waiting = waitingDAO.getWaitingById(waitingId);
        
        // 2. 기존 DB에서 웨이팅 정보를 삭제합니다.
        waitingDAO.deleteWaiting(waitingId);

        // 3. Firebase에서도 해당 웨이팅 정보를 삭제합니다.
        if (waiting != null) {
            final FirebaseDatabase database = FirebaseDatabase.getInstance();
            DatabaseReference ref = database.getReference("waitings")
                                            .child(String.valueOf(waiting.getStoreId()))
                                            .child(String.valueOf(waiting.getWaitingId()));
            ref.removeValueAsync(); // 비동기 방식으로 데이터를 삭제합니다.
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
