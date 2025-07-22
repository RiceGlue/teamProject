package com.spring.teamProject.common;

import org.springframework.web.servlet.ModelAndView;

public class ViewUtil {
	public static ModelAndView layout(String viewName) {
		ModelAndView mav = new ModelAndView("layout/layout");
		mav.addObject("body", viewName);
		return mav;
	}

}
