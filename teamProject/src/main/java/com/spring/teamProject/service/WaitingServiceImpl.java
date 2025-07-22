package com.spring.teamProject.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.teamProject.dao.WaitingDAO;
import com.spring.teamProject.vo.WaitingVO;

@Service
public class WaitingServiceImpl implements WaitingService {

	@Autowired
	private WaitingDAO waitingDAO;

	@Autowired
	public void insertWaitingSlot(WaitingVO vo) {
		waitingDAO.insertWaitingSlot(vo);
	}

	@Override
	public List<WaitingVO> getWaitingSlotsByStore(Long storeId) {
		return waitingDAO.getWaitingSlotsByStore(storeId);
	}

	@Override
	public void deleteWaitingSlot(Long waitingId) {
		waitingDAO.deleteWaitingSlot(waitingId);
	}

	@Override
	public void updateWaitingSlot(WaitingVO vo) {
		waitingDAO.updateWaitingSlot(vo);
	}

}
