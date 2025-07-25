package com.spring.teamProject.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import jakarta.servlet.http.HttpServletResponse;

public interface AdminStoreController {
	
	public ResponseEntity addStoreInfo (@RequestParam("store_id")String store_id, MultipartHttpServletRequest multiReq, HttpServletResponse res) throws Exception;

}
