package com.spring.teamProject.controller;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.spring.teamProject.service.WaitingService;

@Mapper
@RequestMapping("/waiting")
public class UserWaitingController {

	
	private final WaitingService waitingService;

    public UserWaitingController(WaitingService waitingService) {
        this.waitingService = waitingService;
    }

    // 사용자: 특정 가게의 웨이팅 현황 보기
    @GetMapping("/view/{storeId}")
    public String viewWaitingSlots(@PathVariable Long storeId, Model model) {
        model.addAttribute("waitingList", waitingService.getWaitingSlotsByStore(storeId));
        return "user/waiting/waitingStatus"; // JSP: /WEB-INF/views/user/waiting/waitingStatus.jsp
    }

    // 사용자: 웨이팅 신청 폼 등도 추가 가능
    
	
	
}
