package com.spring.teamProject.controller;

import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

public interface AdminStoreController {
	
	public ModelAndView addStoreInfo(MultipartHttpServletRequest multiReq) throws Exception;
	public ModelAndView addMenuInfo(MultipartHttpServletRequest multiReq) throws Exception;
}
