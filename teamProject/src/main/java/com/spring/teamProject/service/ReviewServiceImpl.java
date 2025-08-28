package com.spring.teamProject.service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.spring.teamProject.dao.ReviewDAO;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.ReviewLikeVO;
import com.spring.teamProject.vo.ReviewVO;
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
	
	@Override
	public long addReservationReview(ReviewVO review) throws Exception{
		reviewDAO.insertReservationReview(review);
		return review.getReviewId();
	}
	
	@Override
	public long addWaitingReview(ReviewVO review) throws Exception{
		reviewDAO.insertWaitingReview(review);
		return review.getReviewId();
	}
	
	@Override
	public void addReviewImageFiles(List<ImageFileVO> imgList) throws Exception{
		reviewDAO.insertReviewImageFiles(imgList);
	}
	
	@Override
	public ReviewVO getRivew(long reviewId) throws Exception {
		ReviewVO reviewVO = reviewDAO.selectReview(reviewId);
		return reviewVO;
	}
	
	@Override
	public List<ImageFileVO> getImageFile (long reviewId) throws Exception {
		List<ImageFileVO> imglist = reviewDAO.selectReviewImageFile(reviewId);
		return imglist;
	}
	
	@Override
	public void modifyReview (ReviewVO review) throws Exception {
		reviewDAO.updateReview(review);
	}
	
	@Override
	public long getImageId (ImageFileVO imagefile) throws Exception {
		long imageId = reviewDAO.selectImageId(imagefile);
		return imageId;
	}
	
	@Override
	public void modifyReviewImage(ImageFileVO imgFile) throws Exception {
		reviewDAO.updateReviewImage(imgFile);
	}
	
	@Override
	public void deleteReviewImage(String fileName) throws Exception {
		reviewDAO.deleteReviewImage(fileName);
	}
	
	@Override
	public void addReviewImage(ImageFileVO imgFile) throws Exception {
		reviewDAO.insertReviewImage(imgFile);
	}
	
	@Override
	public void deleteReviewImages(long reviewId) throws Exception {
		reviewDAO.deleteReviewImages(reviewId);
	}
	
	@Override
	public void deleteReview (long reviewId) throws Exception {
		reviewDAO.deleteReview (reviewId);
	}

	@Override
	public List<ReviewVO> getBestReviewList() throws Exception {
	    List<ReviewVO> reviewList = reviewDAO.selectBestReview();
	    
	    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

	    for (ReviewVO review : reviewList) {
	        Date fullDate = review.getCreatedAt();
	        
	        if (fullDate != null) {
	            // Date -> String (yyyy-MM-dd)
	            String dateOnlyString = dateFormat.format(fullDate);
	            
	            // String -> Date (시간은 00:00:00으로 초기화됨)
	            Date dateOnly = dateFormat.parse(dateOnlyString);
	            
	            // 다시 Date 타입으로 저장
	            review.setCreatedAt(dateOnly); 
	        }
	    }
	    return reviewList;
	}

	
	@Override
	public ImageFileVO getBestReviewImage(long reviewId) throws Exception{
		return reviewDAO.selectBestReviewImage(reviewId);
	}
	
	@Override
	public List<ReviewVO> getUserReview(long memberId) throws Exception {
		return reviewDAO.selectUserReview(memberId);
	}
	
	@Override
	public void increaseLike(ReviewLikeVO reviewLikeVO) throws Exception{
		reviewDAO.increaseLikes(reviewLikeVO);
	}
	
	@Override
	public void decreaseLike(ReviewLikeVO reviewLikeVO) throws Exception{
		reviewDAO.decreaseLikes(reviewLikeVO);
	}
	
	@Override
	public int getLikeCount(long reviewId) throws Exception{
		return reviewDAO.getLikeCount(reviewId);
	}
	
	@Override
	public List<ReviewLikeVO> uesrLikeReview(long memberId) throws Exception {
		return reviewDAO.uesrLikeReview(memberId);
	}
}
