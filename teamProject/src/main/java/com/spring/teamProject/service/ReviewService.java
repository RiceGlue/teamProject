package com.spring.teamProject.service;

import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.WaitingVO;

public interface ReviewService {
	
	public ReservationVO getReservationById(long reservationId) throws Exception;
	public WaitingVO getWaitingById(long waitingId) throws Exception;
	public StoreVO selectStoreInfo (long storeId) throws Exception;
	
}
