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

	@Override
    public int registerWaiting(WaitingVO waitingVO) {
        // 상태 기본값 지정
        waitingVO.setStatus("WAITING");
        return waitingDAO.insertWaiting(waitingVO);
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
