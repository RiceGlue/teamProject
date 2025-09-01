package com.spring.teamProject.service;

import java.util.List;

import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.ManageReviewVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.ReviewLikeVO;
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
	public ReviewVO getRivew(long reviewId) throws Exception;
	public List<ImageFileVO> getImageFile (long reviewId) throws Exception;
	public void modifyReview (ReviewVO review) throws Exception;
	public ImageFileVO getReviewImageById (long imageId) throws Exception;
	public void deleteReviewImage(long imageId) throws Exception;
	public void addReviewImage(ImageFileVO imgFile) throws Exception;
	public void deleteReviewImages(long reviewId) throws Exception;
	public void deleteReview(long reviewId) throws Exception;
	
	public List<ReviewVO> getBestReviewList() throws Exception;
	public ImageFileVO getBestReviewImage(long reviewId) throws Exception;
	public List<ReviewVO> getUserReview(long memberId) throws Exception;
	public List<ReviewLikeVO> uesrLikeReview(long memberId) throws Exception;
	public List<ManageReviewVO> selectReviewManage() throws Exception;
	
	public void increaseLike(ReviewLikeVO reviewLikeVO) throws Exception;
	public void decreaseLike(ReviewLikeVO reviewLikeVO) throws Exception;
	public boolean isLiked(Long memberId, Long reviewId) throws Exception;
	
	public int getLikeCount(long reviewId) throws Exception;
	
	public List<ReviewVO> getStoreAllReview(long storeId) throws Exception;
	public int countStoreAllReview(long storeId) throws Exception;
	
	public void requestReviewManage(ManageReviewVO manageReviewVO) throws Exception;
	public ManageReviewVO getReviewManageStatus(long reviewId) throws Exception;
	
	public void updateReviewManage(ManageReviewVO manageReviewVO) throws Exception;
}
