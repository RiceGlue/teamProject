package com.spring.teamProject.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.spring.teamProject.service.WaitingService;
import com.spring.teamProject.vo.WaitingVO;

@Controller
@RequestMapping("/waiting")
public class WaitingController {

	
	@Autowired
	private WaitingService waitingService;
	
	// 관리자용 - 특정 가게의 웨이팅 슬롯 보기
    @GetMapping("/store/{storeId}")
    public String getStoreWaitingSlots(@PathVariable Long storeId, Model model) {
        List<WaitingVO> slots = waitingService.getWaitingSlotsByStore(storeId);
        model.addAttribute("slots", slots);
        return "waiting/slotList"; // JSP: /WEB-INF/views/waiting/slotList.jsp
    }

    // 관리자용 - 웨이팅 슬롯 등록
    @PostMapping("/add")
    public String addWaitingSlot(@ModelAttribute WaitingVO vo) {
        waitingService.insertWaitingSlot(vo);
        return "redirect:/waiting/store/" + vo.getStore_id();
    }

    // 관리자용 - 웨이팅 슬롯 삭제
    @PostMapping("/delete/{id}")
    public String deleteWaitingSlot(@PathVariable("id") Long waitingId, @RequestParam Long storeId) {
        waitingService.deleteWaitingSlot(waitingId);
        return "redirect:/waiting/store/" + storeId;
    }
	
	
	
}
