package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.dao.DataAccessException;

import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.ManageReviewVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.ReviewLikeVO;
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
	public ReviewVO selectReview(long reviewId) throws DataAccessException;
	public List<ImageFileVO> selectReviewImageFile(long reviewId) throws DataAccessException;
	public void updateReview (ReviewVO review) throws DataAccessException;
	
	public ImageFileVO selectReviewImageById (long imageId) throws DataAccessException;
	public void deleteReviewImage(long imageId) throws DataAccessException;
	public void insertReviewImage(ImageFileVO imgFile) throws DataAccessException;
	public void deleteReviewImages(long reviewId) throws DataAccessException;
	public void deleteReview(long reviewId) throws DataAccessException;
	
	public void increaseLikes(ReviewLikeVO reviewLikeVO) throws DataAccessException;
	public void decreaseLikes(ReviewLikeVO reviewLikeVO) throws DataAccessException;
	public int getLikeCount(long reviewId) throws DataAccessException;
	public List<ReviewLikeVO> uesrLikeReview(long memberId) throws DataAccessException;
	public boolean isLiked(ReviewLikeVO reviewLikeVO) throws DataAccessException;
	
	public List<ReviewVO> selectBestReview() throws DataAccessException;
	public ImageFileVO selectBestReviewImage(long reviewId) throws DataAccessException;
	public List<ReviewVO> selectUserReview(long memberId) throws DataAccessException;
	
	public List<ReviewVO> selectStoreAllReview(long storeId) throws DataAccessException;
	public int countStoreAllReview(long storeId) throws DataAccessException;
	
	public void requestReviewManage(ManageReviewVO manageReviewVO) throws DataAccessException;
	public ManageReviewVO getReviewManageStatus(long reviewId) throws DataAccessException;
	
	public List<ManageReviewVO> selectReviewManage() throws DataAccessException;
	public void updateReviewManage(ManageReviewVO manageReviewVO) throws DataAccessException;
}
