package com.spring.teamProject.controller;

import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public interface StoreController {
	public ModelAndView storeRegionList(@RequestParam("region") String region, HttpServletRequest req, HttpServletResponse res) throws Exception;
	public ModelAndView keywordSearchStore(@RequestParam("keyword") String keyword, HttpServletRequest req, HttpServletResponse res) throws Exception;
}
