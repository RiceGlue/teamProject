package com.spring.teamProject.dao;

import java.util.List;

import com.spring.teamProject.vo.WaitingVO;

public interface WaitingDAO {
	
	void insertWaitngSlot(WaitingVO vo);
	
	List<WaitingVO> getWaitingSlotsByStore(Long storeId);
	
	void deleteWaitingSlot(Long waitingId);
	
	void updateWaitingSlot(WaitingVO vo);
	
	
}
