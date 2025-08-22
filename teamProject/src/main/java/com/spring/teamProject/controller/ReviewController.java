package com.spring.teamProject.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.vo.ReviewVO;

public interface ReviewController {
	
	public ResponseEntity<?> addReview(@ModelAttribute ReviewVO review, MultipartHttpServletRequest multiReq) throws Exception;
	public ResponseEntity<?> modifyReview(@ModelAttribute ReviewVO review, MultipartHttpServletRequest multiReq) throws Exception;
	public ModelAndView deleteReview(@RequestParam("reviewId") long reviewId) throws Exception;
}
