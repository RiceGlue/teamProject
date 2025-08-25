package com.spring.teamProject.controller;

import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.UserDetailsVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public interface StoreController {

	public ModelAndView storeList (@RequestParam("option") String option, @RequestParam("keyword") String keyword, HttpServletRequest req, HttpServletResponse res) throws Exception;
	//public ModelAndView storeDetail(@ModelAttribute StoreVO storeVO, HttpServletRequest req, HttpServletResponse res) throws Exception;
	ModelAndView storeDetail(StoreVO storeVO, UserDetailsVO userDetailsVO, HttpServletRequest req,
			HttpServletResponse res) throws Exception;
}
