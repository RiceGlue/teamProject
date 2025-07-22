package com.spring.teamProject.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

	@GetMapping("/")
	public String index(Model model) {
		model.addAttribute("body", "index.jsp"); // 또는 "index"
		return "layout/layout"; // 즉: /WEB-INF/views/layout/layout.jsp
	}

}
