package com.spring.teamProject.service;

import java.util.List;

import com.spring.teamProject.dao.WaitingDAO;
import com.spring.teamProject.vo.WaitingVO;

public class WaitingServiceImpl implements WaitingService {
	
	private final WaitingDAO waitingDAO;

    public WaitingServiceImpl(WaitingDAO waitingDAO) {
        this.waitingDAO = waitingDAO;
    }

    @Override
    public List<WaitingVO> getAllWaitings() {
        return waitingDAO.getAllWaitings();
    }

    @Override
    public WaitingVO getWaitingById(Long waitingId) {
        return waitingDAO.getWaitingById(waitingId);
    }

    @Override
    public void insertWaiting(WaitingVO waiting) {
        waitingDAO.insertWaiting(waiting);
    }

    @Override
    public void updateWaitingStatus(Long waitingId, String status) {
        waitingDAO.updateWaitingStatus(waitingId, status);
    }

    @Override
    public void deleteWaiting(Long waitingId) {
        waitingDAO.deleteWaiting(waitingId);
    }
}
