package com.spring.teamProject.controller;

import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.teamProject.vo.StoreVO;

import jakarta.servlet.http.HttpServletRequest;

public interface AdminStoreController {
	
	public String addStoreInfo(@ModelAttribute StoreVO storeVO, HttpServletRequest req, RedirectAttributes reAttr) throws Exception;
//	public ResponseEntity addMenuInfo (MultipartHttpServletRequest multiReq, HttpServletResponse res) throws Exception;
}
