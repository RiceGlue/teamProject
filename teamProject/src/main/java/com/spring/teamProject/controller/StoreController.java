package com.spring.teamProject.controller;

import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public interface StoreController {
	
	public ModelAndView SelectRegionStoreList (@RequestParam("region") String region, HttpServletRequest req, HttpServletResponse res) throws Exception;
	public ModelAndView storeDetail(@RequestParam("storeId") long storeId, HttpServletRequest req, HttpServletResponse res) throws Exception;
}
