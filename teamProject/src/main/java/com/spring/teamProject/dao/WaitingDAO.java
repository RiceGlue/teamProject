package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.spring.teamProject.vo.WaitingVO;

@Mapper
public interface WaitingDAO {
	
	void insertWaitingSlot(WaitingVO vo);
	
	List<WaitingVO> getWaitingSlotsByStore(Long storeId);
	
	void deleteWaitingSlot(Long waitingId);
	
	void updateWaitingSlot(WaitingVO vo);
	
	
}
