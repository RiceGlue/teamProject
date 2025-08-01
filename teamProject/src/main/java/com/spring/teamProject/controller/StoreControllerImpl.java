package com.spring.teamProject.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.StoreServiceImpl;
import com.spring.teamProject.vo.StoreVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller
@RequestMapping(value="/store")
public class StoreControllerImpl implements StoreController {

	@Autowired
	private StoreServiceImpl storeService;

	@Override
	@RequestMapping(value="/storeList", method=RequestMethod.GET)
	public ModelAndView storeList (@RequestParam("option") String option, @RequestParam("keyword") String keyword, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");
		
		List<StoreVO> storelist = null ;
		
		if(option.equals("region")) {
			storelist = storeService.selectStoreByRegion(keyword);
		} else if(option.equals("storeType")) {
			storelist = storeService.selectStoreByType(keyword);
		}

		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("keyword",keyword);
		mav.addObject("storelist",storelist);
		return mav;
	}

	@Override
	@RequestMapping(value="/storeDetail", method=RequestMethod.GET)
	public ModelAndView storeDetail(@RequestParam("storeId") long storeId, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");

		Map storeMap = storeService.storeDetail(storeId);

		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("storeMap", storeMap);
		return mav;
	}

}
