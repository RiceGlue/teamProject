package com.spring.teamProject.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.spring.teamProject.service.BannerService;
import com.spring.teamProject.service.StoreService;
import com.spring.teamProject.vo.BannerEntity; // 💡 올바른 클래스 임포트

@Controller
public class HomeController {

    private final BannerService bannerService;
    
    @Autowired
    private StoreService storeService;

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
    
//    @GetMapping("/")
//    public String getBestReviewByStores(Model model) throws Exception {
//    	Map storeReivew = storeService.getBestReviewByStores();
//    	
//    	model.addAttribute("storeReview", storeReivew);
//    	return "layout/layout";
//    } 
}