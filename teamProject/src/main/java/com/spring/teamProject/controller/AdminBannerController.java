package com.spring.teamProject.controller;

import com.spring.teamProject.jpa.dao.PromotionRepository;
import com.spring.teamProject.service.BannerService;
import com.spring.teamProject.service.PromotionService;
import com.spring.teamProject.vo.BannerEntity;
import com.spring.teamProject.vo.PromotionEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.util.List;

@Controller
@RequestMapping("/admin/banners")
public class AdminBannerController {

    @Autowired
    private BannerService bannerService;

    @Autowired
    private PromotionService promotionService;

    // 배너 목록 조회
    // 페이징 및 탭 기능 추가
    @GetMapping("")
    public String listBanners(@RequestParam(value = "tab", defaultValue = "active") String tab,
                              @PageableDefault(size = 10, sort = "orderIndex") Pageable pageable,
                              Model model) {
        
        Page<BannerEntity> bannerPage;

        // 1. 'tab' 파라미터 값에 따라 다른 서비스 메소드를 호출합니다.
        if ("scheduled".equals(tab)) {
            bannerPage = bannerService.getScheduledBanners(pageable);
        } else if ("ended".equals(tab)) {
            bannerPage = bannerService.getEndedBanners(pageable);
        } else {
            bannerPage = bannerService.getActiveBannersForAdmin(pageable);
        }

        // 2. 조회된 페이지 정보(배너 목록, 전체 페이지 수 등)를 모델에 담아 전달합니다.
        model.addAttribute("bannerPage", bannerPage);
        model.addAttribute("currentTab", tab); // 현재 활성화된 탭을 알려주기 위한 정보
        model.addAttribute("body", "admin/banner_list.jsp");
        return "admin/admin_layout";
    }

    // ✨ --- [신규] 순서 변경 전용 페이지를 보여주는 메소드 --- ✨
    @GetMapping("/order")
    public String showBannerOrderForm(Model model) {
        // 페이징 없이 '게시 중'인 모든 배너를 가져옵니다.
        List<BannerEntity> bannerList = bannerService.getActiveBannersForOrdering();
        model.addAttribute("bannerList", bannerList);
        model.addAttribute("body", "admin/banner_order_form.jsp");
        return "admin/admin_layout";
    }

    // ✨ --- [신규] 변경된 배너 순서를 저장하는 API --- ✨
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

    // 새 배너 등록 폼
    @GetMapping("/form")
    public String showNewBannerForm(Model model) {
        // Service를 사용하여 프로모션 목록을 조회합니다.
        List<PromotionEntity> promotionList = promotionService.getAllPromotions();
        // 신규 등록 시에도 JSP에서 banner 객체 참조 가능하도록 빈 객체를 전달합니다.
        model.addAttribute("promotionList", promotionList);
        model.addAttribute("banner", new BannerEntity()); 
        model.addAttribute("body", "admin/banner_form.jsp");
        return "admin/admin_layout";
    }

    // 배너 수정 폼
    @GetMapping("/form/{bannerId}")
    public String showEditBannerForm(@PathVariable String bannerId, Model model) {
        // 수정할 배너 정보를 DB에서 가져옵니다.
        BannerEntity banner = bannerService.getBannerById(bannerId);
        // 프로모션 목록도 함께 조회하여 전달
        List<PromotionEntity> promotionList = promotionService.getAllPromotions();

        model.addAttribute("promotionList", promotionList);
        model.addAttribute("banner", banner); // 기존 데이터 세팅
        model.addAttribute("body", "admin/banner_form.jsp");
        return "admin/admin_layout";
    }

    // 배너 저장 및 수정 처리
    @PostMapping("/save")
    public String saveOrUpdateBanner(@ModelAttribute BannerEntity banner,
                                     @RequestParam("pcImageFile") MultipartFile pcImageFile,
                                     @RequestParam(value = "mobileImageFile", required = false) MultipartFile mobileImageFile, // 모바일 이미지는 선택 사항
                                     @RequestParam("linkType") String linkType,
                                     RedirectAttributes redirectAttributes) {
        
        // '커스텀 주소' 선택 시 → promotionId 초기화
        if ("custom".equals(linkType)) {
            banner.setPromotionId(null);
        } else { // '프로모션' 선택 시 → linkUrl 초기화
            banner.setLinkUrl(null);
        }

        try {
            // bannerId 여부로 신규/수정 구분
            if (banner.getBannerId() != null && !banner.getBannerId().isEmpty()) {
                // 기존 배너 수정
                bannerService.updateBanner(banner, pcImageFile, mobileImageFile);
                redirectAttributes.addFlashAttribute("msg", "배너가 성공적으로 수정되었습니다.");
            } else {
                // 신규 배너 저장
                bannerService.saveBanner(banner, pcImageFile, mobileImageFile);
                redirectAttributes.addFlashAttribute("msg", "배너가 성공적으로 저장되었습니다.");
            }
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            // 실패 시 분기: 수정이면 수정폼으로, 신규면 등록폼으로 이동
            if (banner.getBannerId() != null) {
                return "redirect:/admin/banners/form/" + banner.getBannerId();
            }
            return "redirect:/admin/banners/form";
        }
        
        return "redirect:/admin/banners";
    }

    // 배너 삭제를 처리하는 메소드
    @PostMapping("/delete/{bannerId}")
    public String deleteBanner(@PathVariable String bannerId, RedirectAttributes redirectAttributes) {
        try {
            bannerService.deleteBanner(bannerId);
            redirectAttributes.addFlashAttribute("msg", "배너가 성공적으로 삭제되었습니다.");
        } catch (Exception e) {
            // Service에서 오류가 발생했을 경우를 대비
            redirectAttributes.addFlashAttribute("error", "배너 삭제 중 오류가 발생했습니다.");
        }
        return "redirect:/admin/banners";
    }
}
