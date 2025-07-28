package com.spring.teamProject.controller;

import java.util.List;
import java.util.Map; // Map 임포트 추가

import org.slf4j.Logger; // 로거 임포트 추가
import org.slf4j.LoggerFactory; // 로거 임포트 추가
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus; // HttpStatus 임포트 추가
import org.springframework.http.ResponseEntity; // ResponseEntity 임포트 추가
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody; // @RequestBody 임포트 추가
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody; // @ResponseBody 임포트 추가

import com.spring.teamProject.service.WaitingService; // <<-- WaitingService 임포트 추가
import com.spring.teamProject.service.WaitingSettingService;
import com.spring.teamProject.vo.WaitingSettingVO;

@Controller
@RequestMapping("/waiting/owner")
public class WaitingOwnerController {

    private static final Logger logger = LoggerFactory.getLogger(WaitingOwnerController.class); // 로거 선언

    @Autowired
    private WaitingSettingService settingService; // 웨이팅 설정 관리 서비스

    @Autowired // <<-- WaitingService 주입!
    private WaitingService waitingService; // 실제 웨이팅(고객 대기열) 관리 서비스

    // 웨이팅 설정 목록 페이지 (JSP 반환)
    @GetMapping("/settings")
    public String listSettings(@RequestParam("storeId") Long storeId, Model model) {
        List<WaitingSettingVO> settings = settingService.getAllSettingsByStoreId(storeId);
        model.addAttribute("settings", settings);
        model.addAttribute("storeId", storeId);
        return "waiting/owner/settingList";
    }

    // 새 웨이팅 설정 추가 폼 페이지 (JSP 반환)
    @GetMapping("/settings/addForm")
    public String showAddSettingForm(@RequestParam("storeId") Long storeId, Model model) {
        model.addAttribute("storeId", storeId);
        model.addAttribute("waitingSettingVO", new WaitingSettingVO());
        return "waiting/owner/settingAddForm";
    }

    // 웨이팅 설정 추가 처리 (폼 제출)
    @PostMapping("/settings/add")
    public String addSetting(@ModelAttribute WaitingSettingVO settingVO) {
        settingService.insertSetting(settingVO);
        return "redirect:/waiting/owner/settings?storeId=" + settingVO.getStoreId();
    }

    // 웨이팅 설정 수정 폼 페이지 (JSP 반환)
    @GetMapping("/settings/editForm/{settingId}")
    public String editSettingForm(@PathVariable Long settingId, @RequestParam("storeId") Long storeId, Model model) {
        WaitingSettingVO settingVO = settingService.getSettingById(settingId);
        model.addAttribute("waitingSettingVO", settingVO);
        model.addAttribute("storeId", storeId);
        return "waiting/owner/settingEditForm";
    }

    // 웨이팅 설정 수정 처리 (폼 제출)
    @PostMapping("/settings/edit")
    public String editSetting(@ModelAttribute WaitingSettingVO settingVO) {
        settingService.updateSetting(settingVO);
        return "redirect:/waiting/owner/settings?storeId=" + settingVO.getStoreId();
    }

    // 웨이팅 설정 삭제 처리
    @GetMapping("/settings/delete/{settingId}")
    public String deleteSetting(@PathVariable Long settingId, @RequestParam Long storeId) {
        settingService.deleteSetting(settingId);
        return "redirect:/waiting/owner/settings?storeId=" + storeId;
    }

    // --- 점주 측 웨이팅 상태 업데이트 API 엔드포인트 ---
    // JSP의 JavaScript에서 fetch 요청을 보낼 엔드포인트입니다.
    @PostMapping("/api/updateStatus") // JSP의 fetch 요청 URL과 일치해야 합니다.
    @ResponseBody // 이 메서드는 뷰를 반환하는 대신 JSON 응답을 반환합니다.
    public ResponseEntity<?> updateWaitingStatusFromOwner(@RequestBody Map<String, Object> payload) {
        try {
            Long waitingId = Long.parseLong(payload.get("waitingId").toString());
            String newStatus = (String) payload.get("status");
            Long storeId = Long.parseLong(payload.get("storeId").toString()); // storeId를 함께 받음

            logger.info("점주 요청: 웨이팅 ID {}의 상태를 {}로 업데이트 (매장 ID: {})", waitingId, newStatus, storeId);

            // WaitingService를 통해 DB 및 Firebase 업데이트를 처리합니다.
            waitingService.updateWaitingStatus(waitingId, newStatus);

            // 성공 응답 (JSON)
            return ResponseEntity.ok(Map.of(
                "message", "Waiting status updated successfully",
                "waitingId", waitingId,
                "newStatus", newStatus,
                "storeId", storeId
            ));

        } catch (NumberFormatException e) {
            logger.error("잘못된 ID 형식: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid ID or storeId format"));
        } catch (Exception e) {
            logger.error("웨이팅 상태 업데이트 실패 (WaitingOwnerController): {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                "error", "Failed to update waiting status",
                "details", e.getMessage()
            ));
        }
    }
}