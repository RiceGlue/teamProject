package com.spring.teamProject.controller;

import com.spring.teamProject.service.BannerService;
import com.spring.teamProject.service.PromotionService; // ✨ --- [수정] PromotionRepository 대신 PromotionService를 사용합니다. --- ✨
import com.spring.teamProject.vo.BannerEntity;
import com.spring.teamProject.vo.PromotionEntity;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/admin/banners")
public class AdminBannerController {

    @Autowired
    private BannerService bannerService;

    // ✨ --- [수정] Repository를 직접 사용하는 대신, Service 계층을 통해 데이터를 조회합니다. --- ✨
    @Autowired
    private PromotionService promotionService;

    // 배너 목록 페이지
    @GetMapping("")
    public String listBanners(@RequestParam(name = "tab", defaultValue = "active") String tab,
                              @PageableDefault(size = 10, sort = "orderIndex") Pageable pageable,
                              Model model) {
        
        Page<BannerEntity> bannerPage;
        if ("scheduled".equals(tab)) {
            bannerPage = bannerService.getScheduledBanners(pageable);
        } else if ("ended".equals(tab)) {
            bannerPage = bannerService.getEndedBanners(pageable);
        } else {
            bannerPage = bannerService.getActiveBannersForAdmin(pageable);
        }
        
        model.addAttribute("bannerPage", bannerPage);
        model.addAttribute("currentTab", tab);
        model.addAttribute("body", "admin/banner_list.jsp");
        return "admin/admin_layout";
    }

    // 배너 등록 폼 페이지
    @GetMapping("/form")
    public String bannerForm(Model model) {
        // ✨ --- [수정] Service를 통해 프로모션 목록을 가져옵니다. --- ✨
        List<PromotionEntity> promotionList = promotionService.getAllPromotions();
        model.addAttribute("banner", new BannerEntity());
        model.addAttribute("promotionList", promotionList);
        model.addAttribute("body", "admin/banner_form.jsp");
        return "admin/admin_layout";
    }

    // 배너 수정 폼 페이지
    @GetMapping("/form/{bannerId}")
    public String bannerEditForm(@PathVariable String bannerId, Model model) {
        BannerEntity banner = bannerService.getBannerById(bannerId);
        // ✨ --- [수정] Service를 통해 프로모션 목록을 가져옵니다. --- ✨
        List<PromotionEntity> promotionList = promotionService.getAllPromotions();
        model.addAttribute("banner", banner);
        model.addAttribute("promotionList", promotionList);
        model.addAttribute("body", "admin/banner_form.jsp");
        return "admin/admin_layout";
    }

    // 배너 저장 (신규 등록 및 수정)
    @PostMapping("/save")
    public String saveBanner(@ModelAttribute BannerEntity banner,
                             @RequestParam("linkType") String linkType, // ✨ --- [신규] linkType 파라미터를 받습니다. --- ✨
                             @RequestParam(value = "pcImageFile", required = false) MultipartFile pcImageFile, // ✨ --- [수정] 파일을 선택적으로 받도록 변경 --- ✨
                             @RequestParam(value = "mobileImageFile", required = false) MultipartFile mobileImageFile,
                             RedirectAttributes redirectAttributes) {
        
        try {
            // ✨ --- [신규] linkType에 따라 promotionId 또는 linkUrl을 null로 설정하여 데이터 정합성을 보장합니다. --- ✨
            if ("promotion".equals(linkType)) {
                banner.setLinkUrl(null); 
            } else {
                banner.setPromotionId(null);
            }

            // ✨ --- [수정] bannerId의 존재 여부로 신규 등록과 수정을 구분합니다. --- ✨
            if (StringUtils.hasText(banner.getBannerId())) {
                bannerService.updateBanner(banner, pcImageFile, mobileImageFile);
                redirectAttributes.addFlashAttribute("msg", "배너가 성공적으로 수정되었습니다.");
            } else {
                bannerService.saveBanner(banner, pcImageFile, mobileImageFile);
                redirectAttributes.addFlashAttribute("msg", "배너가 성공적으로 등록되었습니다.");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "작업 중 오류가 발생했습니다: " + e.getMessage());
            // ✨ --- [수정] 오류 발생 시, 수정 중이었다면 수정 폼으로, 신규 등록 중이었다면 등록 폼으로 돌아갑니다. --- ✨
            if (StringUtils.hasText(banner.getBannerId())) {
                return "redirect:/admin/banners/form/" + banner.getBannerId();
            } else {
                return "redirect:/admin/banners/form";
            }
        }
        return "redirect:/admin/banners";
    }

    // 배너 삭제
    @PostMapping("/delete/{bannerId}")
    public String deleteBanner(@PathVariable String bannerId, RedirectAttributes redirectAttributes) {
        try {
            bannerService.deleteBanner(bannerId);
            redirectAttributes.addFlashAttribute("msg", "배너가 성공적으로 삭제되었습니다.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "삭제 중 오류가 발생했습니다: " + e.getMessage());
        }
        return "redirect:/admin/banners";
    }
    
    // 순서 변경 페이지
    @GetMapping("/order")
    public String bannerOrderForm(Model model) {
        List<BannerEntity> bannerList = bannerService.getActiveBannersForOrdering();
        model.addAttribute("bannerList", bannerList);
        model.addAttribute("body", "admin/banner_order_form.jsp");
        return "admin/admin_layout";
    }

    // 변경된 순서 저장
    @PostMapping("/update-order")
    @ResponseBody
    public String updateBannerOrder(@RequestBody List<String> bannerIds) {
        try {
            bannerService.updateBannerOrder(bannerIds);
            return "success";
        } catch (Exception e) {
            return "error";
        }
    }
    
    // ? --- [신규] 기본 배너 업로드 처리 --- ?
    @PostMapping("/upload-default")
    public String uploadDefaultBanner(@RequestParam("defaultImageFile") MultipartFile defaultImageFile,
                                      RedirectAttributes redirectAttributes) {
        try {
            bannerService.saveDefaultBanner(defaultImageFile);
            redirectAttributes.addFlashAttribute("msg", "기본 배너가 성공적으로 변경되었습니다.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "기본 배너 업로드 중 오류가 발생했습니다: " + e.getMessage());
        }
        return "redirect:/admin/banners";
    }
}