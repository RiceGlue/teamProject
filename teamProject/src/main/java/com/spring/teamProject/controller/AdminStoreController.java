package com.spring.teamProject.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public interface AdminStoreController {
	
	public ResponseEntity addStoreInfo (@RequestParam("storeId")long storeId, MultipartHttpServletRequest multiReq, HttpServletResponse res) throws Exception;
	public ModelAndView SelectRegionStoreList (@RequestParam("region") String region, HttpServletRequest req, HttpServletResponse res) throws Exception;
}
