package com.spring.teamProject.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

	/**
	 * 메인 페이지("/") 요청을 처리합니다.
	 * @param model View에 데이터를 전달하기 위한 Model 객체
	 * @return layout.jsp를 사용하여 렌더링할 뷰 경로
	 */
	@GetMapping("/")
	public String index(Model model) {
		System.out.println("HomeController: / 요청 처리됨");
		
		model.addAttribute("body", "index.jsp");
		
		// (수정) ViewResolver를 거치지 않고, JSP의 전체 경로를 직접 반환하여 경로 문제를 해결합니다.
		return "layout/layout"; 
	}

}
