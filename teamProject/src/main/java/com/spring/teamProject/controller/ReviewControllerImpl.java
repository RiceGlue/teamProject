package com.spring.teamProject.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
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
	@RequestMapping(value = "/modifyReview", method = RequestMethod.POST)
	public ModelAndView modifyReview(@ModelAttribute ReviewVO review, MultipartHttpServletRequest multiReq) throws Exception {
	    ModelAndView mav = new ModelAndView();
	    String directoryName = "review";
	    long reviewId = review.getReviewId();
	    
	    String[] deleteFileNames = multiReq.getParameterValues("deleteFileName");
	    List<ImageFileVO> addedFiles = upload(multiReq, directoryName); // 새로 추가된 파일 목록

	    
	    try {
	        // 1. 리뷰 본문 및 평점 수정
	        reviewService.modifyReview(review);

	        int deleteCount = (deleteFileNames != null) ? deleteFileNames.length : 0;
	        int addCount = (addedFiles != null) ? addedFiles.size() : 0;
	        
	        System.out.println("deleteCount:"+deleteCount+"addCount"+addCount);

	        // --- 1. 이미지 추가만 (삭제 없음, 추가만 있음) ---
	        if (deleteCount == 0 && addCount > 0) {
	        	reviewService.addReviewImageFiles(addedFiles);
	        }
	        // --- 2. 삭제 후 추가 (삭제 > 추가) ---
	        else if (deleteCount > addCount && addCount > 0) {
	            // 1. 교체 가능한 범위 내에서는 update
	            for (int i = 0; i < addCount; i++) {
	                String oldFileName = deleteFileNames[i];
	                ImageFileVO newFile = addedFiles.get(i);

	                long imageId = reviewService.getImageId(oldFileName);
	                newFile.setImageId(imageId);
	                newFile.setReviewId(reviewId);

	                reviewService.modifyReviewImage(newFile); // 이미지 교체 (update)
	                deleteFile(oldFileName, directoryName);   // 기존 파일 삭제
	            }

	            // 2. 남은 삭제 대상은 실제 삭제 처리
	            for (int i = addCount; i < deleteCount; i++) {
	                String oldFileName = deleteFileNames[i];

	                reviewService.deleteReviewImage(oldFileName); // DB 이미지 삭제
	                deleteFile(oldFileName, directoryName);   // 파일 삭제
	            }
	        }

	        // --- 3. 삭제 후 추가 (삭제 < 추가) ---
	        else if (deleteCount < addCount && deleteCount > 0) {
	        	int displayNo= 5-deleteCount;
	        	
	            // 삭제 이미지 만큼 기존 이미지 수정 (update)
	            for (int i = 0; i < deleteCount; i++) {
	                String oldFileName = deleteFileNames[i];
	                ImageFileVO newFile = addedFiles.get(i);

	                long imageId = reviewService.getImageId(oldFileName);
	                newFile.setImageId(imageId);
	                newFile.setReviewId(reviewId);

	                reviewService.modifyReviewImage(newFile); // update
	                deleteFile(oldFileName, directoryName);  // 기존 파일 삭제
	            }
	            // 남은 추가 이미지들은 새로 insert
	            for (int i = deleteCount; i < addCount; i++) {
	                ImageFileVO newFile = new ImageFileVO();
	                
	                newFile.setFileName(addedFiles.get(i).getFileName());
	                newFile.setDisplayNo(displayNo);
	                newFile.setRegId(review.getMemberId());
	                newFile.setStoreId(review.getStoreId());
	                newFile.setReviewId(reviewId);
	                
	                reviewService.addReviewImage(newFile);
	                displayNo++;
	            }
	        }
	        // --- 4. 이미지 삭제만 (삭제 있음, 추가 없음) ---
	        else if (deleteCount > 0 && addCount == 0) {
	            for (String oldFileName : deleteFileNames) {
	                reviewService.deleteReviewImage(oldFileName); // DB 삭제
	                deleteFile(oldFileName, directoryName);   // 파일 삭제
	            }
	        }
	        // --- 5. 이미지 수정 안 함 (삭제 없음, 추가 없음) ---
	        else {
	            // 아무것도 안함
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	        mav.setViewName("redirect:/review/reviewForm?error=true");
	        return mav;
	    }

	    mav.setViewName("redirect:/member/myPage");
	    return mav;
	}

}
