package com.spring.teamProject.controller;

import com.spring.teamProject.service.BannerService;
import com.spring.teamProject.service.PromotionService;
import com.spring.teamProject.vo.BannerEntity;
import com.spring.teamProject.vo.PromotionEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.util.List;

@Controller
@RequestMapping("/admin/banners")
public class AdminBannerController {

    @Autowired
    private BannerService bannerService;

    // ? --- 1. PromotionRepository 대신 PromotionService를 주입받습니다. --- ?
    @Autowired
    private PromotionService promotionService;

    @GetMapping("")
    public String listBanners(Model model) {
        // 1. BannerService를 통해 DB에 저장된 모든 배너 목록을 가져옵니다.
        List<BannerEntity> bannerList = bannerService.getAllBanners();
        
        // 2. 가져온 목록을 "bannerList"라는 이름으로 모델에 담아 JSP로 전달합니다.
        model.addAttribute("bannerList", bannerList);
        
        model.addAttribute("body", "admin/banner_list.jsp");
        return "admin/admin_layout";
    }

    @GetMapping("/form")
    public String showBannerForm(Model model) {
        // ? --- 2. Service를 사용하여 프로모션 목록을 조회합니다. --- ?
        List<PromotionEntity> promotionList = promotionService.getAllPromotions();
        model.addAttribute("promotionList", promotionList);
        model.addAttribute("body", "admin/banner_form.jsp");
        return "admin/admin_layout";
    }

    // ? --- 3. 배너 등록/수정을 처리하는 메소드 --- ?
    @PostMapping("/form")
    public String saveBanner(@ModelAttribute BannerEntity banner,
                             @RequestParam("pcImageFile") MultipartFile pcImageFile,
                             @RequestParam(value = "mobileImageFile", required = false) MultipartFile mobileImageFile, // 모바일 이미지는 선택 사항
                             @RequestParam("linkType") String linkType,
                             RedirectAttributes redirectAttributes) {
        
        // '커스텀 주소'가 선택된 경우, promotionId를 null로 설정합니다.
        if ("custom".equals(linkType)) {
            banner.setPromotionId(null);
        } else { // '프로모션'이 선택된 경우, linkUrl을 null로 설정합니다.
            banner.setLinkUrl(null);
        }

        try {
            bannerService.saveBanner(banner, pcImageFile, mobileImageFile);
            redirectAttributes.addFlashAttribute("msg", "배너가 성공적으로 저장되었습니다.");
        } catch (IllegalArgumentException e) {
            // 서비스에서 유효성 검사 실패 시 보낸 메시지를 그대로 사용합니다.
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/banners/form"; // 실패 시 폼으로 다시 이동
        }
        
        return "redirect:/admin/banners";
    }
}
