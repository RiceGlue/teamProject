package com.spring.teamProject.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.common.BaseController;
import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.ReviewServiceImpl;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.StoreVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller("reviewController")
@RequestMapping(value="/review")
public class ReviewControllerImpl extends BaseController implements ReviewController{

	@Autowired
	private ReviewServiceImpl reviewService;


	@RequestMapping(value = "/reviewForm")
	public ModelAndView reviewForm(@ModelAttribute ReviewVO reviewVO, HttpServletRequest req, HttpServletResponse res) throws Exception {
	    String viewName = (String) req.getAttribute("viewName");
	    ModelAndView mav = ViewUtil.layout(viewName);

	    Long reservationId = reviewVO.getReservationId();
	    Long waitingId = reviewVO.getWaitingId();
	    Long memberId = reviewVO.getMemberId();

	    System.out.println("가게 아이디 : "+reviewVO.getStoreId());

	    StoreVO storeInfo = reviewService.selectStoreInfo(reviewVO.getStoreId());

	    if(reservationId != null && reservationId != 0) {
			mav.addObject("reservationId", reservationId);
	    } else if(waitingId != null && waitingId != 0) {
	    	mav.addObject("waitingId", waitingId);
	    }

	    mav.addObject("memberId", memberId);
	    mav.addObject("review", reviewVO);
	    mav.addObject("storeInfo", storeInfo);

	    return mav;
	}

	@RequestMapping(value="/modifyReviewForm")
	public ModelAndView modifyReviewForm(@ModelAttribute ReviewVO reviewVO, HttpServletRequest req, HttpServletResponse res) throws Exception {
        String viewName = (String) req.getAttribute("viewName");
        ModelAndView mav = ViewUtil.layout(viewName);

        long reviewId = reviewVO.getReviewId();
        ReviewVO review = reviewService.getRivew(reviewId);
        List<ImageFileVO> imglist = reviewService.getImageFile(reviewId);

        long storeId = review.getStoreId();
        StoreVO store = reviewService.selectStoreInfo(storeId);

        mav.addObject("storeInfo", store);
        mav.addObject("review", review);
        mav.addObject("imglist", imglist);
        return mav;
	}

	@Override
	@RequestMapping(value="/addReview" , method=RequestMethod.POST)
	public ModelAndView addReview(@ModelAttribute ReviewVO review, MultipartHttpServletRequest multiReq) throws Exception {
		ModelAndView mav = new ModelAndView();

		Long regId = review.getMemberId();
		Long storeId= review.getStoreId();

		System.out.println(regId+","+storeId);

		Long reservationId = review.getReservationId();
		Long waitingId = review.getWaitingId();

		if (reservationId != null && reservationId != 0) {

			try {
				reviewService.addReservationReview(review);

				List<ImageFileVO> imgList = upload(multiReq, "review");

				// 각 이미지 객체에 필요한 정보를 설정합니다.
				for (int i = 0; i < imgList.size(); i++) {
					ImageFileVO imageFile = imgList.get(i);
					imageFile.setRegId(regId);
					imageFile.setStoreId(storeId);
					imageFile.setReviewId(review.getReviewId());
					imageFile.setDisplayNo(i); // displayNo를 0부터 순차적으로 설정
				}

				// 이미지 정보를 DB에 저장합니다.
				reviewService.addReviewImageFiles(imgList);

				mav = ViewUtil.layout("/member/mypage");

			} catch (Exception e) {
			// 오류 처리
				e.printStackTrace();
				mav.addObject("error", true);
				mav.setViewName("redirect:/review/reviewForm?memberId=" + regId + "&storeId=" + storeId + "&reservationId=" + reservationId);
			}

		} else if (waitingId != null && waitingId != 0) {
			try {
				reviewService.addWaitingReview(review);

				List<ImageFileVO> imgList = upload(multiReq, "review");

				// 각 이미지 객체에 필요한 정보를 설정합니다.
				for (int i = 0; i < imgList.size(); i++) {
					ImageFileVO imageFile = imgList.get(i);
					imageFile.setRegId(regId);
					imageFile.setStoreId(storeId);
					imageFile.setReviewId(review.getReviewId());
					imageFile.setDisplayNo(i); // displayNo를 0부터 순차적으로 설정
				}

				// 이미지 정보를 DB에 저장합니다.
				reviewService.addReviewImageFiles(imgList);

				// 리뷰 작성 완료 후 마이페이지로 리다이렉트합니다.
				mav = ViewUtil.layout("/member/mypage");

			} catch (Exception e) {
				// 오류 처리
				e.printStackTrace();
				mav.addObject("error", true);
				mav.setViewName("redirect:/review/reviewForm?memberId=" + regId + "&storeId=" + storeId + "&waitingId=" + waitingId);
			}
		}

		return mav;
	}

	@Override
	@PostMapping("/modifyReview")
	public ResponseEntity<?> modifyReview(@ModelAttribute ReviewVO review, MultipartHttpServletRequest multiReq) throws Exception {
	    String directoryName = "review";

	    long reviewId = review.getReviewId();
	    long memberId = review.getMemberId();
	    long storeId = review.getStoreId();

	    String[] deleteFileNames = multiReq.getParameterValues("deleteFileName");
	    List<ImageFileVO> addedFiles = upload(multiReq, directoryName);

	    int deleteCount = deleteFileNames != null ? deleteFileNames.length : 0;
	    int addCount = addedFiles != null ? addedFiles.size() : 0;

	    try {
	        // 리뷰 정보 수정
	        reviewService.modifyReview(review);

	        int displayNo = 5 - deleteCount;

	        if (deleteCount > 0 && addCount > 0) {
	            int min = Math.min(deleteCount, addCount);

	            for (int i = 0; i < min; i++) {
	            	ImageFileVO oldFile = new ImageFileVO();
	                String oldFileName = deleteFileNames[i];
	                
	                oldFile.setFileName(oldFileName);
	                oldFile.setReviewId(reviewId);
	                
	                long imageId = reviewService.getImageId(oldFile);
	                
	                ImageFileVO newFile = addedFiles.get(i);
	                newFile.setImageId(imageId);
	                newFile.setReviewId(reviewId);

	                reviewService.modifyReviewImage(newFile);
	                deleteFile(oldFileName, directoryName);
	            }

	            for (int i = min; i < addCount; i++) {
	                ImageFileVO newFile = addedFiles.get(i);
	                populateFileMeta(newFile, storeId, reviewId, memberId, displayNo++);
	                reviewService.addReviewImage(newFile);
	            }

	            for (int i = min; i < deleteCount; i++) {
	                String oldFileName = deleteFileNames[i];
	                reviewService.deleteReviewImage(oldFileName);
	                deleteFile(oldFileName, directoryName);
	            }

	        } else if (deleteCount > 0) {
	            for (String fileName : deleteFileNames) {
	                reviewService.deleteReviewImage(fileName);
	                deleteFile(fileName, directoryName);
	            }

	        } else if (addCount > 0) {
	            for (ImageFileVO newFile : addedFiles) {
	                populateFileMeta(newFile, storeId, reviewId, memberId, displayNo++);
	                reviewService.addReviewImage(newFile);
	            }
	        }

	        // 성공 응답 (선택: 필요한 데이터 포함 가능)
	        return ResponseEntity.ok().body(Map.of(
	            "status", "success",
	            "reviewId", reviewId,
	            "memberId", memberId
	        ));

	    } catch (Exception e) {
	        e.printStackTrace(); // 실제로는 로그 처리

	        // 실패 응답
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
	            "status", "error",
	            "message", "리뷰 수정 중 오류 발생"
	        ));
	    }
	}

	// 공통 메타 설정 함수
	private void populateFileMeta(ImageFileVO file, long storeId, long reviewId, long memberId, int displayNo) {
	    file.setStoreId(storeId);
	    file.setReviewId(reviewId);
	    file.setRegId(memberId);
	    file.setDisplayNo(displayNo);
	}

}
