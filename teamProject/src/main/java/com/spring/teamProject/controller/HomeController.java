package com.spring.teamProject.controller;

import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.spring.teamProject.service.BannerService;
import com.spring.teamProject.vo.BannerEntity;

@Controller
public class HomeController {

    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    @Autowired
    private BannerService bannerService;

    /**
     * 개발자 테스트용 메인 페이지 (기존 index.jsp)
     * URL: /
     */
    @RequestMapping(value = "/")
    public String main(Model model) {
        logger.info("HomeController: / 요청 처리됨 (개발자용)");
        List<BannerEntity> bannerList = bannerService.getActiveBanners();
        model.addAttribute("bannerList", bannerList);
        model.addAttribute("body", "index.jsp");
        return "layout/layout";
    }

    /**
     * ✨ --- [신규] 실제 사용자용 메인 페이지 --- ✨
     * URL: /main
     */
    @GetMapping("/main")
    public String showMainPage(Model model) {
        logger.info("HomeController: /main 요청 처리됨 (사용자용)");
        
        // 1. BannerService를 통해 현재 활성화된 배너 목록을 DB에서 조회합니다.
        List<BannerEntity> bannerList = bannerService.getActiveBanners();
        
        // 2. 조회된 배너 목록을 "bannerList"라는 이름으로 모델에 담아 JSP로 전달합니다.
        //    (main.jsp에서는 이 목록을 PC용과 모바일용으로 나누어 사용하게 됩니다.)
        model.addAttribute("bannerList", bannerList);
        
        // 3. 새로 만든 main.jsp 파일을 본문(body)으로 지정합니다.
        model.addAttribute("body", "main.jsp"); 
        return "layout/layout";
    }
}
