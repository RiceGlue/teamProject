package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.dao.DataAccessException;

import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.WaitingVO;

@Mapper
public interface ReviewDAO {

	public ReservationVO selectReservationById(long reservationId) throws DataAccessException;
	public WaitingVO selectWaitingById(long waitingId) throws DataAccessException;
	public StoreVO selectStore(long storeId) throws DataAccessException;
	public long insertReservationReview(ReviewVO review) throws DataAccessException;
	public long insertWaitingReview(ReviewVO review) throws DataAccessException;
	public void insertReviewImageFiles(List<ImageFileVO> imgList) throws DataAccessException; 
}
