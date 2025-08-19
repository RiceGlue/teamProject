package com.spring.teamProject.service;

import java.util.List;
import com.spring.teamProject.vo.WaitingVO;

public interface WaitingService {
    int registerWaiting(WaitingVO waitingVO);
    void insertWaiting(WaitingVO waiting);
    void updateWaitingStatus(Long waitingId, String status);
    void deleteWaiting(Long waitingId);
    List<WaitingVO> getAllWaitings();
    WaitingVO getWaitingById(Long waitingId);

    // 새로 추가된 메소드
    int getCurrentWaitingCount(Long storeId);

    boolean checkExistingWaiting(Long memberId);

}