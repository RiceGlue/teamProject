package com.spring.teamProject.controller;

import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public interface StoreController {
	
	public ModelAndView storeList (@RequestParam("option") String option, @RequestParam("keyword") String keyword, HttpServletRequest req, HttpServletResponse res) throws Exception;
	public ModelAndView storeDetail(@RequestParam("storeId") long storeId, HttpServletRequest req, HttpServletResponse res) throws Exception;
}
