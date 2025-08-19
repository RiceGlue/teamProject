package com.spring.teamProject.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.ReviewServiceImpl;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.WaitingVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller("reviewController")
@RequestMapping(value="/review")
public class ReviewControllerImpl {
	
	@Autowired
	private ReviewServiceImpl reviewService;
	
	
	@RequestMapping(value = "/reviewForm")
	public ModelAndView reviewForm(@ModelAttribute ReviewVO reviewVO, HttpServletRequest req, HttpServletResponse res) throws Exception {
	    String viewName = (String) req.getAttribute("viewName");
	    ModelAndView mav = ViewUtil.layout(viewName);

	    Long reservationId = reviewVO.getReservationId();
	    Long waitingId = reviewVO.getWaitingId();

	    ReservationVO reservation = new ReservationVO();
	    WaitingVO waiting = new WaitingVO();
	    StoreVO storeInfo = reviewService.selectStoreInfo(reviewVO.getStoreId());
	    
	    if(reservationId!=null) {
	    	reservation = reviewService.getReservationById(reservationId);
			mav.addObject("reservation", reservation);
	    } else if(waitingId!=null) {
	    	waiting = reviewService.getWaitingById(waitingId);
	    	mav.addObject("waiting", waiting);
	    }

	    mav.addObject("review", reviewVO);	    

	    return mav;
	}



}
