package com.spring.teamProject.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.teamProject.vo.StoreVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public interface AdminStoreController {
	
	public ResponseEntity<String> addStoreInfo(MultipartHttpServletRequest multiReq, HttpServletResponse res) throws Exception;
//	public ResponseEntity addMenuInfo (MultipartHttpServletRequest multiReq, HttpServletResponse res) throws Exception;
}
