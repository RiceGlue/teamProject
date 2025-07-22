package com.spring.teamProject.service;

import java.util.List;

import com.spring.teamProject.vo.WaitingVO;

public interface WaitingService {
	void insertWaitingSlot(WaitingVO vo);
	List<WaitingVO> getWaitingSlotsByStore(Long storeId);
	void deleteWaitingSlot(Long waitingId);
	void updateWaitingSlot(WaitingVO vo);
}
