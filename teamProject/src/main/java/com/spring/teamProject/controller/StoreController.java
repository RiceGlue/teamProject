package com.spring.teamProject.controller;

import org.springframework.ui.Model;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.UserDetailsVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public interface StoreController {

	// 가게 상세보기
	public ModelAndView storeDetail( StoreVO storeVO, UserDetailsVO userDetailsVO, HttpServletRequest req, HttpServletResponse res ) throws Exception;
}
