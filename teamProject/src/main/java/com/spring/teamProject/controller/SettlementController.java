package com.spring.teamProject.controller;

import com.spring.teamProject.service.SettlementService;
import com.spring.teamProject.vo.SettlementsEntity;
import com.spring.teamProject.vo.UserDetailsVO;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/settlement")
public class SettlementController {

    private final SettlementService settlementService;

    public SettlementController(SettlementService settlementService) {
        this.settlementService = settlementService;
    }

    @GetMapping("/history")
    public String getSettlementHistory(
            @AuthenticationPrincipal Object principal,
            @RequestParam(value = "startDate", required = false) String startDateStr,
            @RequestParam(value = "endDate", required = false) String endDateStr,
            Model model) {

        if (principal == null || !(principal instanceof UserDetailsVO)) {
            return "redirect:/member/login";
        }

        UserDetailsVO userDetailsVO = (UserDetailsVO) principal;
        long ownerId = userDetailsVO.getMemberVO().getMemberId();

        LocalDate endDate = (endDateStr != null) ? LocalDate.parse(endDateStr) : LocalDate.now();
        LocalDate startDate = (startDateStr != null) ? LocalDate.parse(startDateStr) : endDate.minusMonths(1);

        List<SettlementsEntity> settlementList = settlementService.getSettlementHistoryByOwnerIdAndDateRange(ownerId, startDate, endDate);

        List<Map<String, Object>> displayList = new ArrayList<>();
        for (SettlementsEntity entity : settlementList) {
            Map<String, Object> map = new HashMap<>();
            map.put("settlementId", entity.getSettlementId());
            map.put("storeId", entity.getStoreId());

            // LocalDate를 Date로 변환 (널 체크 불필요, `atStartOfDay`가 처리)
            map.put("settlementPeriodStart", Date.from(entity.getSettlementPeriodStart().atStartOfDay(ZoneId.systemDefault()).toInstant()));
            map.put("settlementPeriodEnd", Date.from(entity.getSettlementPeriodEnd().atStartOfDay(ZoneId.systemDefault()).toInstant()));

            map.put("totalRevenueAmount", entity.getTotalRevenueAmount());
            map.put("totalCommissionAmount", entity.getTotalCommissionAmount());
            map.put("finalSettlementAmount", entity.getFinalSettlementAmount());
            map.put("status", entity.getStatus());

            // settledAt 필드가 null인 경우에 대한 널 체크 추가
            if (entity.getSettledAt() != null) {
                map.put("settledAt", Date.from(entity.getSettledAt().atZone(ZoneId.systemDefault()).toInstant()));
            } else {
                map.put("settledAt", null); // 또는 "N/A" 같은 문자열로 처리
            }

            displayList.add(map);
        }

        model.addAttribute("settlementList", displayList);
        model.addAttribute("body", "settlement/settlement_history.jsp");
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);

        return "owner/owner_layout";
    }

    @GetMapping("/calculate")
    public String calculateSettlement(
            @RequestParam("storeId") long storeId,
            @RequestParam("startDate") String startDate,
            @RequestParam("endDate") String endDate) {

        settlementService.calculateAndSaveSettlement(storeId, startDate, endDate);

        return "redirect:/settlement/history?startDate=" + startDate + "&endDate=" + endDate;
    }
}