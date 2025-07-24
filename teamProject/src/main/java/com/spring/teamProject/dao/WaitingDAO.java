package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.teamProject.vo.WaitingVO;

@Mapper
public interface WaitingDAO {

	List<WaitingVO> getAllWaitings();
    WaitingVO getWaitingById(Long waitingId);
    //void insertWaiting(WaitingVO waiting);
    void updateWaitingStatus(@Param("waitingId") Long waitingId, @Param("status") String status);
    void deleteWaiting(Long waitingId);
	
    int insertWaiting(WaitingVO waitingVO);
    
}
