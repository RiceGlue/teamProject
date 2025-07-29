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
// StoreVO도 필요하다면 임포트
// import com.spring.teamProject.vo.StoreVO;


@Controller
@RequestMapping("/waiting/owner")
public class WaitingOwnerController {

    private static final Logger logger = LoggerFactory.getLogger(WaitingOwnerController.class);

    @Autowired
    private WaitingSettingService settingService;

    @Autowired
    private WaitingService waitingService;

    // (필요하다면) 더미 StoreVO 메소드
    // private StoreVO getDummyStoreInfo(Long storeId) {
    //     StoreVO store = new StoreVO();
    //     store.setStoreId(storeId);
    //     store.setStoreName("더미 매장 " + storeId);
    //     return store;
    // }

    // 웨이팅 설정 목록 페이지 (JSP 반환)
    @GetMapping("/settings")
    public String listSettings(@RequestParam("storeId") Long storeId, Model model) {
        List<WaitingSettingVO> settings = settingService.getAllSettingsByStoreId(storeId);
        model.addAttribute("settings", settings);
        model.addAttribute("storeId", storeId);
        // (선택사항) 매장 정보도 모델에 추가하여 JSP에서 사용
        // model.addAttribute("store", getDummyStoreInfo(storeId));
        return "waiting/owner/settingList";
    }

    // 새 웨이팅 설정 추가 폼 페이지 (JSP 반환)
    @GetMapping("/settings/addForm")
    public String showAddSettingForm(@RequestParam("storeId") Long storeId, Model model) {
        // model.addAttribute("storeId", storeId); // 이 부분은 아래 WaitingSettingVO에 포함되므로 필요없을 수 있습니다.

        // WaitingSettingVO 객체를 생성하고 storeId를 미리 설정합니다.
        WaitingSettingVO waitingSettingVO = new WaitingSettingVO();
        waitingSettingVO.setStoreId(storeId); // <-- 이 부분이 핵심입니다! storeId를 VO에 설정

        model.addAttribute("waitingSettingVO", waitingSettingVO); // 모델에 설정된 VO 추가
        // (선택사항) 매장 정보도 모델에 추가하여 JSP에서 사용
        // model.addAttribute("store", getDummyStoreInfo(storeId));
        return "waiting/owner/settingAddForm";
    }

    // 웨이팅 설정 추가 처리 (폼 제출)
    @PostMapping("/settings/add")
    public String addSetting(@ModelAttribute WaitingSettingVO settingVO) {
        // 이제 settingVO.getStoreId()는 settingAddForm.jsp의 hidden 필드로부터 값을 받게 됩니다.
        // 추가적인 storeId @RequestParam은 필요 없지만, 명시적으로 URL에 storeId를 포함했다면 받을 수도 있습니다.
        // 예를 들어: @PostMapping("/settings/add") public String addSetting(@ModelAttribute WaitingSettingVO settingVO, @RequestParam("storeId") Long storeId)
        // 이 경우, settingVO.setStoreId(storeId); (if null) 로직을 추가하는 것도 안전합니다.

        // 현재 코드에서는 settingVO.getStoreId()가 null이 아니어야 합니다.
        // 만약 여전히 null이라면, settingAddForm.jsp에 hidden input이 없거나 path가 잘못된 것입니다.

        logger.info("웨이팅 설정 추가 시도: {}", settingVO); // 로깅으로 넘어온 VO 확인
        try {
            settingService.insertSetting(settingVO);
            logger.info("웨이팅 설정 성공적으로 추가됨: {}", settingVO);
        } catch (Exception e) {
            logger.error("웨이팅 설정 추가 실패: {}", e.getMessage(), e);
            // 에러 발생 시 처리 (예: 에러 메시지와 함께 폼으로 다시 이동)
            // 에러 시에도 storeId를 다시 전달해야 합니다.
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
        // model.addAttribute("store", getDummyStoreInfo(storeId));
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