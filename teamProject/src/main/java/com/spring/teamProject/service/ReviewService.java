package com.spring.teamProject.service;

import java.util.List;

import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.WaitingVO;

public interface ReviewService {
	
	public ReservationVO getReservationById(long reservationId) throws Exception;
	public WaitingVO getWaitingById(long waitingId) throws Exception;
	public StoreVO selectStoreInfo (long storeId) throws Exception;
	public long addReservationReview(ReviewVO review) throws Exception;
	public long addWaitingReview(ReviewVO review) throws Exception;
	public void addReviewImageFiles(List<ImageFileVO> imgList) throws Exception;
}
