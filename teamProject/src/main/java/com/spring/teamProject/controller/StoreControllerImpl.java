package com.spring.teamProject.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.service.StoreService;
import com.spring.teamProject.vo.StoreVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller("storeController")
@RequestMapping(value="/store")
public class StoreControllerImpl implements StoreController {
	
	@Autowired
	private StoreService storeService;
	
	private String root="layout/layout";
	
	@Override
	@RequestMapping(value="/storeRegionList.do", method=RequestMethod.POST)
	public ModelAndView storeRegionList(@RequestParam("region") String region, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");
		List<StoreVO> storelist = storeService.storeRegionList(region);
		
		ModelAndView mav = new ModelAndView(root);
		mav.addObject("body", viewName);
		mav.addObject("storelist", storelist);
		return mav;
		
	}
	
	@Override
	@RequestMapping(value="/keywordSearchStore.do", method=RequestMethod.GET)
	public ModelAndView keywordSearchStore(@RequestParam("keyword") String keyword, HttpServletRequest req, HttpServletResponse res) throws Exception{
		String viewName = (String)req.getAttribute("viewName");
		
		keyword = "%"+keyword+"%";
		
		List<StoreVO> storelist = storeService.keywordSearchStore(keyword);
		ModelAndView mav = new ModelAndView(root);
		mav.addObject("body", viewName);
		mav.addObject("storelist",storelist);
		
		return mav;
	}

}
