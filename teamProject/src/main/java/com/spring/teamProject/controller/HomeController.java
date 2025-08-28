package com.spring.teamProject.controller;

import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.spring.teamProject.service.BannerService;
import com.spring.teamProject.vo.BannerEntity;
import com.spring.teamProject.vo.UserDetailsVO;

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
    public String main(@AuthenticationPrincipal UserDetailsVO userDetailsVO, Model model) {
        logger.info("HomeController: / 요청 처리됨 (개발자용)");
        
        if (userDetailsVO != null) {
			Long memberId = (long) userDetailsVO.getMemberVO().getMemberId();
			model.addAttribute("memberId", memberId);
		}
        
        
        List<BannerEntity> bannerList = bannerService.getActiveBanners();
        model.addAttribute("bannerList", bannerList);
        model.addAttribute("body", "index.jsp");
        return "layout/layout"; // 기존 레이아웃 사용
    }

    /**
     * 실제 사용자용 메인 페이지
     * URL: /main
     */
    @GetMapping("/main")
    public String showMainPage(Model model) {
        logger.info("HomeController: /main 요청 처리됨 (사용자용)");
        
        List<BannerEntity> bannerList = bannerService.getActiveBanners();
        model.addAttribute("bannerList", bannerList);
        
        model.addAttribute("body", "main.jsp"); 
        
        // ✨ --- 여기가 핵심 수정 부분입니다 --- ✨
        // 새로 만든 main_layout.jsp를 사용하도록 변경합니다.
        return "layout/main_layout"; 
    }
}
