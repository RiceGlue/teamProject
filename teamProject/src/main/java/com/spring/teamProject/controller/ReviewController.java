package com.spring.teamProject.controller;

import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.vo.ReviewVO;

public interface ReviewController {
	
	public ModelAndView addReview(@ModelAttribute ReviewVO review, MultipartHttpServletRequest multiReq) throws Exception;

}
