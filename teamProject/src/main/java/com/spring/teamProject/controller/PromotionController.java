package com.spring.teamProject.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.spring.teamProject.service.PromotionService;
import com.spring.teamProject.vo.PromotionEntity;

@Controller
public class PromotionController {

    @Autowired
    private PromotionService promotionService;

    /**
     * 프로모션 상세 페이지를 보여줍니다.
     * URL: /promotion/detail?id=1
     * @param id 조회할 프로모션의 ID
     * @param model 뷰로 전달할 데이터 객체
     * @return 뷰 이름 (promotion/promotionDetail.jsp)
     */
    @GetMapping("/promotion/detail")
    public String showPromotionDetail(@RequestParam("id") Long id, Model model) {
        PromotionEntity promotion = promotionService.getPromotionById(id);

        if (promotion != null) {
            model.addAttribute("promotion", promotion);
            model.addAttribute("body", "promotion/promotionDetail.jsp");
            return "layout/layout";
        } else {
            return "redirect:/"; // 프로모션이 없을 경우
        }
    }

    @PostMapping("/admin/promotion/add")
    public String addPromotion(@ModelAttribute PromotionEntity promotion) {
        promotionService.savePromotion(promotion);
        return "redirect:/admin/promotion/list"; // 추가 후 목록 페이지로 리다이렉트
    }

    @PostMapping("/admin/promotion/delete")
    public String deletePromotion(@RequestParam("id") Long id) {
        promotionService.deletePromotion(id);
        return "redirect:/admin/promotion/list"; // 삭제 후 목록 페이지로 리다이렉트
    }

    // PromotionController.java 에 추가
    @GetMapping("/admin/promotion/list")
    public String showAdminPromotionList(Model model) {
        List<PromotionEntity> promotions = promotionService.getAllPromotions();
        model.addAttribute("promotions", promotions);
        model.addAttribute("body", "promotion/adminPromotionList.jsp");
        return "admin/admin_layout";
    }

    // PromotionController.java 에 추가
    @GetMapping("/admin/promotion/form")
    public String showAdminPromotionForm(@RequestParam(value = "id", required = false) Long id, Model model) {
        if (id != null) {
            // 수정 모드: 기존 프로모션 정보 불러오기
            PromotionEntity promotion = promotionService.getPromotionById(id);
            model.addAttribute("promotion", promotion);
        } else {
            // 추가 모드: 빈 객체 생성
            model.addAttribute("promotion", new PromotionEntity());
        }
        model.addAttribute("body", "promotion/adminPromotionForm.jsp");
        return "admin/admin_layout";
    }


}
