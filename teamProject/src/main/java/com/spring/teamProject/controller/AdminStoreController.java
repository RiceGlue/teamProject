package com.spring.teamProject.controller;

import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

public interface AdminStoreController {
	
	public ModelAndView addStoreInfo(MultipartHttpServletRequest multiReq) throws Exception;
	public ModelAndView addMenu(MultipartHttpServletRequest multiReq) throws Exception;
	public ModelAndView modifyStoreInfo(MultipartHttpServletRequest multiReq) throws Exception;
	public ModelAndView modifyMenu(MultipartHttpServletRequest multiReq) throws Exception;
	public ModelAndView deleteMenu(@RequestParam("menuId") long menuId, @RequestParam("storeId") long storeId, @RequestParam("fileName") String fileName) throws Exception;
}
