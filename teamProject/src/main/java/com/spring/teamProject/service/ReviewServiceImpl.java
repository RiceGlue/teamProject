package com.spring.teamProject.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.spring.teamProject.dao.ReviewDAO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.WaitingVO;

@Service("reviewService")
@Transactional(propagation=Propagation.REQUIRED)
public class ReviewServiceImpl implements ReviewService {
	
	@Autowired
	private ReviewDAO reviewDAO;

	@Override
	public ReservationVO getReservationById(long reservationId) throws Exception {
		ReservationVO resVO = reviewDAO.selectReservationById(reservationId);
		return resVO;
	}
	
	@Override
	public WaitingVO getWaitingById(long waitingId) throws Exception {
		WaitingVO waitVO = reviewDAO.selectWaitingById(waitingId);
		return waitVO;
	}
	
	@Override
	public StoreVO selectStoreInfo (long storeId) throws Exception {
		StoreVO storeInfo = reviewDAO.selectStore(storeId);
		return storeInfo;
	}
}
