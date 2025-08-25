package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;
import org.springframework.dao.DataAccessException;

import com.spring.teamProject.vo.WaitingVO;

public interface WaitingDAO {
    int insertWaiting(WaitingVO waiting);
    void updateWaitingStatus(@Param("waitingId") Long waitingId, @Param("status") String status);
    void deleteWaiting(Long waitingId);
    WaitingVO getWaitingById(Long waitingId);
    List<WaitingVO> getAllWaitings();
    // TODO: 매장별로 현재 대기중인 모든 웨이팅 목록을 가져오는 메소드도 필요할 수 있음
    // List<WaitingVO> getCurrentWaitings(Long storeId);

    // 새로 추가된 메소드: 현재 대기 중인 팀 수 카운트
    int countCurrentWaitings(@Param("storeId") Long storeId);
    int countActiveWaitingsByMemberId(Long memberId);

    List<WaitingVO> selectWaitingsByMemberId(@Param("memberId") Long memberId);
    List<WaitingVO> selectCurrentWaitings(@Param("storeId") Long storeId);
    
    void increaseUserTemperatureByWaiting(long waitingId) throws DataAccessException;
    void decreaseUserTemperatureByWaiting(long waitingId) throws DataAccessException;
}