package com.spring.teamProject.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller; // <<-- @RestController 대신 @Controller 사용
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping; // 현재 이 컨트롤러에서 직접 사용되진 않지만, API용이라면 필요
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping; // 현재 이 컨트롤러에서 직접 사용되진 않지만, API용이라면 필요
import org.springframework.web.bind.annotation.RequestBody; // 현재 이 컨트롤러에서 직접 사용되진 않지만, API용이라면 필요
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
// import org.springframework.web.bind.annotation.RestController; // <<-- 제거

import com.spring.teamProject.service.WaitingSettingService;
import com.spring.teamProject.vo.WaitingSettingVO;

@Controller // <<-- 변경
@RequestMapping("/waiting/owner")
public class WaitingOwnerController {

    @Autowired
    private WaitingSettingService settingService;

    // 웨이팅 설정 목록 페이지 (JSP 반환)
    // URL: /waiting/owner/settings?storeId=1
    @GetMapping("/settings")
    public String listSettings(@RequestParam("storeId") Long storeId, Model model) {
        List<WaitingSettingVO> settings = settingService.getAllSettingsByStoreId(storeId);
        model.addAttribute("settings", settings);
        model.addAttribute("storeId", storeId); // JSP에서 storeId를 다시 사용할 수 있도록 추가
        return "waiting/owner/settingList"; // 실제 JSP 파일 경로 (예: /WEB-INF/views/waiting/owner/settingList.jsp)
    }

    // 새 웨이팅 설정 추가 폼 페이지 (JSP 반환)
    // URL: /waiting/owner/settings/addForm?storeId=1
    @GetMapping("/settings/addForm") // 폼을 보여주는 GET 요청
    public String showAddSettingForm(@RequestParam("storeId") Long storeId, Model model) {
        model.addAttribute("storeId", storeId); // 폼에 storeId를 전달
        model.addAttribute("waitingSettingVO", new WaitingSettingVO()); // 빈 VO 객체 전달 (폼 바인딩용)
        return "waiting/owner/settingAddForm"; // 새 설정 추가 폼 JSP (이름을 명확하게 변경)
    }

    // 웨이팅 설정 추가 처리 (폼 제출)
    // URL: /waiting/owner/settings/add (POST)
    @PostMapping("/settings/add")
    public String addSetting(@ModelAttribute WaitingSettingVO settingVO) {
        settingService.insertSetting(settingVO);
        return "redirect:/waiting/owner/settings?storeId=" + settingVO.getStoreId();
    }

    // 웨이팅 설정 수정 폼 페이지 (JSP 반환)
    // URL: /waiting/owner/settings/editForm/{settingId}?storeId=1
    @GetMapping("/settings/editForm/{settingId}") // 폼을 보여주는 GET 요청
    public String editSettingForm(@PathVariable Long settingId, @RequestParam("storeId") Long storeId, Model model) {
        WaitingSettingVO settingVO = settingService.getSettingById(settingId);
        model.addAttribute("waitingSettingVO", settingVO);
        model.addAttribute("storeId", storeId); // JSP에 storeId 전달
        return "waiting/owner/settingEditForm"; // 설정 수정 폼 JSP (이름을 명확하게 변경)
    }

    // 웨이팅 설정 수정 처리 (폼 제출)
    // URL: /waiting/owner/settings/edit (POST)
    @PostMapping("/settings/edit")
    public String editSetting(@ModelAttribute WaitingSettingVO settingVO) {
        settingService.updateSetting(settingVO);
        return "redirect:/waiting/owner/settings?storeId=" + settingVO.getStoreId();
    }

    // 웨이팅 설정 삭제 처리
    // URL: /waiting/owner/settings/delete/{settingId}?storeId=1
    @GetMapping("/settings/delete/{settingId}") // GET 요청으로 삭제하는 경우
    public String deleteSetting(@PathVariable Long settingId, @RequestParam Long storeId) {
        settingService.deleteSetting(settingId);
        return "redirect:/waiting/owner/settings?storeId=" + storeId;
    }

    // --- (선택 사항) 만약 REST API 엔드포인트가 필요하다면, 별도의 클래스나 명확한 경로를 사용 ---
    // 예: @RestController @RequestMapping("/api/owner/waiting/settings")
    // 여기서는 기존 API 관련 메서드는 일단 주석 처리하거나 제거했습니다.
    // @GetMapping
    // public List<WaitingSettingVO> getAllWaitings() { /* ... */ }
    // @PostMapping
    // public void insertWaiting(@RequestBody WaitingSettingVO setting) { /* ... */ }
    // ...
}