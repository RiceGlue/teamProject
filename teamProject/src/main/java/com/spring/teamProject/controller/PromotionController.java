package com.spring.teamProject.controller;

import com.spring.teamProject.service.PromotionService;
import com.spring.teamProject.vo.PromotionEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

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
}
