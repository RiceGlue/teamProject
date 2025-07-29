package com.spring.teamProject.controller;

import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.teamProject.service.WaitingService;
import com.spring.teamProject.service.WaitingSettingService;
import com.spring.teamProject.vo.WaitingSettingVO;
import com.spring.teamProject.vo.StoreVO; // StoreVO 임포트 (더미 데이터용)


@Controller
@RequestMapping("/waiting/owner")
public class WaitingOwnerController {

    private static final Logger logger = LoggerFactory.getLogger(WaitingOwnerController.class);

    @Autowired
    private WaitingSettingService settingService;

    @Autowired
    private WaitingService waitingService;

    // 더미 StoreVO 메소드 (이전과 동일하게 유지)
    private StoreVO getDummyStoreInfo(Long storeId) {
        StoreVO store = new StoreVO();
        store.setStoreId(storeId);
        store.setStoreName("더미 매장 " + storeId);
        store.setAddress("서울시 가짜구 더미동 " + storeId + "번지");
        return store;
    }

    // 웨이팅 설정 목록 페이지 (JSP 반환)
    @GetMapping("/settings")
    public String listSettings(@RequestParam("storeId") Long storeId, Model model) {
        List<WaitingSettingVO> settings = settingService.getAllSettingsByStoreId(storeId);
        model.addAttribute("settings", settings);
        model.addAttribute("storeId", storeId);
        model.addAttribute("store", getDummyStoreInfo(storeId));
        return "waiting/owner/settingList";
    }

    // 새 웨이팅 설정 추가 폼 페이지 (JSP 반환)
    @GetMapping("/settings/addForm")
    public String showAddSettingForm(@RequestParam("storeId") Long storeId, Model model) {
        WaitingSettingVO waitingSettingVO = new WaitingSettingVO();
        waitingSettingVO.setStoreId(storeId);

        model.addAttribute("waitingSettingVO", waitingSettingVO);
        model.addAttribute("storeId", storeId);
        model.addAttribute("store", getDummyStoreInfo(storeId));
        return "waiting/owner/settingAddForm";
    }

    // 웨이팅 설정 추가 처리 (폼 제출)
    @PostMapping("/settings/add")
    public String addSetting(@ModelAttribute WaitingSettingVO settingVO) {
        logger.info("웨이팅 설정 추가 시도: {}", settingVO);
        try {
            settingService.insertSetting(settingVO);
            logger.info("웨이팅 설정 성공적으로 추가됨: {}", settingVO);
        } catch (Exception e) {
            logger.error("웨이팅 설정 추가 실패: {}", e.getMessage(), e);
            return "redirect:/waiting/owner/settings/addForm?storeId=" + settingVO.getStoreId() + "&error=true";
        }

        return "redirect:/waiting/owner/settings?storeId=" + settingVO.getStoreId();
    }

    // 웨이팅 설정 수정 폼 페이지 (JSP 반환)
    @GetMapping("/settings/editForm/{settingId}")
    public String editSettingForm(
            @PathVariable("settingId") Long settingId,
            @RequestParam("storeId") Long storeId,
            Model model) {
        WaitingSettingVO settingVO = settingService.getSettingById(settingId);
        model.addAttribute("waitingSettingVO", settingVO);
        model.addAttribute("storeId", storeId);
        model.addAttribute("store", getDummyStoreInfo(storeId));
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
    public String deleteSetting(
            @PathVariable("settingId") Long settingId,
            @RequestParam("storeId") Long storeId) {
        settingService.deleteSetting(settingId);
        return "redirect:/waiting/owner/settings?storeId=" + storeId;
    }

    // --- 실시간 웨이팅 관리 관련 메소드 (향후 추가될 예정) ---
    // 이 부분은 time_slot 제거 후 실시간 대기열을 관리하기 위해 필요할 것입니다.

    // 실시간 웨이팅 현황 페이지 (고객 대기열)
    @GetMapping("/currentWaiting")
    public String showCurrentWaiting(@RequestParam("storeId") Long storeId, Model model) {
        logger.info("실시간 웨이팅 현황 요청 - storeId: {}", storeId);
        model.addAttribute("storeId", storeId);
        model.addAttribute("store", getDummyStoreInfo(storeId));

        // TODO: 여기서 waitingService를 사용하여 현재 대기 중인 고객 목록을 가져와 모델에 추가
        // List<WaitingVO> currentWaitings = waitingService.getCurrentWaitings(storeId);
        // model.addAttribute("currentWaitings", currentWaitings);

        return "waiting/owner/currentWaitingList"; // 새로운 JSP 파일이 필요
    }

    // API: 웨이팅 상태 업데이트 (기존 로직 유지)
    @PostMapping("/api/updateStatus")
    @ResponseBody
    public ResponseEntity<?> updateWaitingStatusFromOwner(@RequestBody Map<String, Object> payload) {
        try {
            Long waitingId = Long.parseLong(payload.get("waitingId").toString());
            String newStatus = (String) payload.get("status");
            Long storeId = Long.parseLong(payload.get("storeId").toString());

            logger.info("점주 요청: 웨이팅 ID {}의 상태를 {}로 업데이트 (매장 ID: {})", waitingId, newStatus, storeId);

            waitingService.updateWaitingStatus(waitingId, newStatus);

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