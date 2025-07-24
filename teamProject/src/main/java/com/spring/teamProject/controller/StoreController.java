package com.spring.teamProject.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.StoreService;
import com.spring.teamProject.vo.StoreVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller
@RequestMapping(value="/store")
public class StoreController {
	
	@Autowired
	private StoreService storeService;
	
	@GetMapping(value="/storeRegionList.do")
	public ModelAndView storeRegionList(@RequestParam("region") String region, HttpServletRequest req, HttpServletResponse res) throws Exception {
		List<StoreVO> storelist = storeService.storeRegionList(region);
		List<Long> imagelist = storeService.storeImageRegionList(region);
		ModelAndView mav = ViewUtil.layout("store/storeRegionList.jsp");
		mav.addObject("storelist", storelist);
		mav.addObject("imagelist", imagelist);
		
		return mav;
		
	}

}
