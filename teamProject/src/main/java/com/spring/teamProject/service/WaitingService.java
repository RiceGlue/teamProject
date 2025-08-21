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

    /**
     * 특정 회원 ID로 웨이팅 목록을 조회합니다.
     * @param memberId 회원 ID
     * @return 해당 회원의 모든 웨이팅 목록
     */
    List<WaitingVO> getWaitingsByMemberId(Long memberId);

    /**
     * 특정 매장의 현재 대기 중인 웨이팅 목록을 조회합니다.
     * @param storeId 가게 ID
     * @return 대기중인 웨이팅 목록 (오래된 순)
     */
    List<WaitingVO> getCurrentWaitings(Long storeId);

}