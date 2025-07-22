package com.spring.teamProject.controller;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.spring.teamProject.service.WaitingService;
import com.spring.teamProject.vo.WaitingVO;

@Mapper
@RequestMapping("/admin/waiting")
public class AdminWaitingController {
	
	@Autowired
	private WaitingService waitingService;
	
	
	// 관리자: 특정 가게의 웨이팅 슬롯 조회
    @GetMapping("/store/{storeId}")
    public String getStoreWaitingSlots(@PathVariable Long storeId, Model model) {
        List<WaitingVO> slots = waitingService.getWaitingSlotsByStore(storeId);
        model.addAttribute("slots", slots);
        return "admin/waiting/slotList"; // JSP: /WEB-INF/views/admin/waiting/slotList.jsp
    }

    // 관리자: 웨이팅 슬롯 추가
    @PostMapping("/add")
    public String addWaitingSlot(@ModelAttribute WaitingVO vo) {
        waitingService.insertWaitingSlot(vo);
        return "redirect:/admin/waiting/store/" + vo.getStoreId();
    }

    // 관리자: 웨이팅 슬롯 삭제
    @PostMapping("/delete/{id}")
    public String deleteWaitingSlot(@PathVariable("id") Long waitingId, @RequestParam Long storeId) {
        waitingService.deleteWaitingSlot(waitingId);
        return "redirect:/admin/waiting/store/" + storeId;
    }
}
