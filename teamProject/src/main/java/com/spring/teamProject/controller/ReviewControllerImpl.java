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
		ModelAndView mav = new ModelAndView();
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

}
