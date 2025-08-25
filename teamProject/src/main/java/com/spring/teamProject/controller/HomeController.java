package com.spring.teamProject.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.spring.teamProject.vo.BannerEntity; // 💡 올바른 클래스 임포트
import com.spring.teamProject.service.BannerService;

@Controller
public class HomeController {

    private final BannerService bannerService;

    @Autowired
    public HomeController(BannerService bannerService) {
        this.bannerService = bannerService;
    }

    @GetMapping("/")
    public String index(Model model) {
        // 1. 서비스에서 활성화된 배너 목록을 가져옵니다.
        List<BannerEntity> activeBanners = bannerService.getActiveBanners();

        // 2. 모델에 배너 목록을 추가합니다.
        model.addAttribute("bannerList", activeBanners);
        model.addAttribute("body", "index.jsp");

        // 3. 뷰를 반환합니다.
        return "layout/layout";
    }
}