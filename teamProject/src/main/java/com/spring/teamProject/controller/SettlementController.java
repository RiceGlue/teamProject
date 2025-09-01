package com.spring.teamProject.controller;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory; // ✨ 로깅을 위한 import
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.spring.teamProject.service.SettlementService;
import com.spring.teamProject.service.StoreService;
import com.spring.teamProject.vo.SettlementsEntity;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.UserDetailsVO;

@Controller
@RequestMapping("/settlement")
public class SettlementController {

    private static final Logger logger = LoggerFactory.getLogger(SettlementController.class); // ✨ Logger 생성

    private final SettlementService settlementService;
    private final StoreService storeService;

    public SettlementController(SettlementService settlementService, StoreService storeService) {
        this.settlementService = settlementService;
        this.storeService = storeService;
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

            map.put("settlementPeriodStart", Date.from(entity.getSettlementPeriodStart().atStartOfDay(ZoneId.systemDefault()).toInstant()));
            map.put("settlementPeriodEnd", Date.from(entity.getSettlementPeriodEnd().atStartOfDay(ZoneId.systemDefault()).toInstant()));

            map.put("totalRevenueAmount", entity.getTotalRevenueAmount());
            map.put("totalCommissionAmount", entity.getTotalCommissionAmount());
            map.put("finalSettlementAmount", entity.getFinalSettlementAmount());
            map.put("status", entity.getStatus());

            if (entity.getSettledAt() != null) {
                map.put("settledAt", Date.from(entity.getSettledAt().atZone(ZoneId.systemDefault()).toInstant()));
            } else {
                map.put("settledAt", null);
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
        @AuthenticationPrincipal Object principal,
        @RequestParam("startDate") String startDate,
        @RequestParam("endDate") String endDate) {

        // ✨ 테스트용 로그 추가
        logger.info("정산 데이터 생성 요청. 시작일: {}, 종료일: {}", startDate, endDate);

        if (principal == null || !(principal instanceof UserDetailsVO)) {
            logger.warn("로그인하지 않은 사용자가 정산 데이터 생성을 시도했습니다.");
            return "redirect:/member/login";
        }

        UserDetailsVO userDetailsVO = (UserDetailsVO) principal;
        long ownerId = userDetailsVO.getMemberVO().getMemberId();

        // ✨ ownerId 값 콘솔 출력
        logger.info("로그인한 점주(ownerId): {}", ownerId);

        try {
            List<StoreVO> stores = storeService.getStoresByOwnerId(ownerId);

            // ✨ 조회된 매장 목록 콘솔 출력
            if (stores.isEmpty()) {
                logger.warn("점주(ownerId: {})에게 연결된 매장이 없습니다. 정산이 생성되지 않습니다.", ownerId);
            } else {
                logger.info("조회된 매장 수: {}", stores.size());
            }

            for (StoreVO store : stores) {
                // ✨ 정산이 실행되는 매장 ID 콘솔 출력
                logger.info("매장 ID {}에 대한 정산을 시작합니다.", store.getStoreId());
                settlementService.calculateAndSaveSettlement(store.getStoreId(), startDate, endDate);
            }

        } catch (Exception e) {
            logger.error("정산 데이터 생성 중 오류 발생", e); // ✨ 예외 발생 시 로그 출력
            e.printStackTrace();
        }

        return "redirect:/settlement/history?startDate=" + startDate + "&endDate=" + endDate;
    }
}