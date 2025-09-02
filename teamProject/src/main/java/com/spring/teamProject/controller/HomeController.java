package com.spring.teamProject.controller;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import com.spring.teamProject.service.BannerService;
import com.spring.teamProject.service.MemberService;
import com.spring.teamProject.vo.BannerEntity;
import com.spring.teamProject.vo.MemberVO;
import com.spring.teamProject.vo.UserDetailsVO;

@Controller
public class HomeController {

    private static final Logger logger = LoggerFactory.getLogger(HomeController.class);

    @Autowired
    private BannerService bannerService;
    
    @Autowired
    private MemberService memberService;

    /**
     * 사용자용 메인 페이지
     * URL: /
     */
    @RequestMapping(value = "/")
    public String main(@AuthenticationPrincipal UserDetailsVO userDetailsVO, Model model) {
        logger.info("HomeController: / 요청 처리됨 (사용자용 메인)");
        
        // 1. 로그인한 사용자 정보가 있으면 모델에 추가합니다.
        if (userDetailsVO != null) {
            Long memberId = (long) userDetailsVO.getMemberVO().getMemberId();
            MemberVO freshMemberInfo = memberService.getMemberById(memberId); // DB에서 최신 사용자 정보 조회
            model.addAttribute("memberInfo", freshMemberInfo); // JSP로 전달
        }
        
        // 2. BannerService를 통해 현재 활성화된 배너 목록을 DB에서 조회합니다.
        List<BannerEntity> bannerList = bannerService.getActiveBanners();
        
        // 3. 만약 활성화된 배너가 하나도 없다면, 기본 배너 정보를 생성합니다.
        if (bannerList == null || bannerList.isEmpty()) {
            bannerList = new ArrayList<>(); // 비어있는 리스트를 새로 만듭니다.
            BannerEntity defaultBanner = new BannerEntity();
            
            // 3-1. 미리 약속된 기본 이미지 파일명을 설정합니다.
            //      이 파일은 FTP 서버의 /banners/ 폴더에 존재해야 합니다.
            defaultBanner.setImagePath("default_banner.png"); 
            defaultBanner.setText("Yum Table에 오신 것을 환영합니다.");
            // 3-2. 클릭 시 메인 페이지로 이동하도록 링크를 설정합니다.
            defaultBanner.setLinkUrl("/"); 
            
            bannerList.add(defaultBanner);
        }
        
        // 4. 조회된 배너 목록(또는 기본 배너)을 모델에 담아 JSP로 전달합니다.
        model.addAttribute("bannerList", bannerList);
        model.addAttribute("body", "index.jsp");
        return "layout/layout";
    }
}

