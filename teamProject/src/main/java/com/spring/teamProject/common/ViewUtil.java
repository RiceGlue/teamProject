package com.spring.teamProject.common;

import org.springframework.web.servlet.ModelAndView;

public class ViewUtil {
	public static ModelAndView layout(String viewName) {
		viewName = viewName+".jsp";
		ModelAndView mav = new ModelAndView("layout/layout");
		mav.addObject("body", viewName);
		return mav;
	}
	
	public static ModelAndView ownerLayout(String viewName) {
		viewName = viewName+".jsp";
		ModelAndView mav = new ModelAndView("owner/owner_layout");
		mav.addObject("body", viewName);
		return mav;
	}
	
	public static ModelAndView adminLayout(String viewName) {
		viewName = viewName+".jsp";
		ModelAndView mav = new ModelAndView("admin/admin_layout");
		mav.addObject("body", viewName);
		return mav;
	}

}
