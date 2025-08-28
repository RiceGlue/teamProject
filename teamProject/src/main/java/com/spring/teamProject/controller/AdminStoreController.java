package com.spring.teamProject.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.vo.UserDetailsVO;

public interface AdminStoreController {
	
	public ModelAndView addStoreInfo(@AuthenticationPrincipal UserDetailsVO userDetailsVO,MultipartHttpServletRequest multiReq) throws Exception;
	public ModelAndView addMenu(@AuthenticationPrincipal UserDetailsVO userDetailsVO,MultipartHttpServletRequest multiReq) throws Exception;
	public ModelAndView modifyStoreInfo(MultipartHttpServletRequest multiReq) throws Exception;
	public ModelAndView modifyMenu(MultipartHttpServletRequest multiReq) throws Exception;
	public ModelAndView deleteMenu(@RequestParam("menuId") long menuId, @RequestParam("storeId") long storeId, @RequestParam("fileName") String fileName) throws Exception;
}
