package com.spring.teamProject.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.vo.ManageReviewVO;
import com.spring.teamProject.vo.ReviewVO;

public interface ReviewController {
	
	public ModelAndView addReview(@ModelAttribute ReviewVO review, MultipartHttpServletRequest multiReq) throws Exception;
	public ModelAndView modifyReview(@ModelAttribute ReviewVO review, MultipartHttpServletRequest multiReq) throws Exception;
	public ModelAndView deleteReview(@RequestParam("reviewId") long reviewId) throws Exception;
    public ResponseEntity<Map<String, Object>> getBestReview() throws Exception;
    public String requestReviewManage(@ModelAttribute ManageReviewVO manageReviewVO) throws Exception;
    public String updateReviewManageStatus(@ModelAttribute ManageReviewVO manageReviewVO) throws Exception;
}
