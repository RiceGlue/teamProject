package com.spring.teamProject.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.spring.teamProject.service.WaitingSettingService;
import com.spring.teamProject.vo.WaitingSettingVO;

@RestController
@RequestMapping("/waiting/owner")
public class WaitingOwnerController {

	@Autowired
    private WaitingSettingService settingService;

	@GetMapping("/settings")
	public String listSettings(@RequestParam("storeId") Long storeId, Model model) {
	    List<WaitingSettingVO> settings = settingService.getAllSettingsByStoreId(storeId);
	    model.addAttribute("settings", settings);
	    return "waiting/owner/settingList";
	}

	@PostMapping("/settings/add")
	public String addSetting(@ModelAttribute WaitingSettingVO settingVO) {
	    settingService.insertSetting(settingVO);
	    return "redirect:/waiting/owner/settings?storeId=" + settingVO.getStoreId();
	}

	@GetMapping("/settings/edit/{settingId}")
	public String editSettingForm(@PathVariable Long settingId, Model model) {
	    WaitingSettingVO settingVO = settingService.getSettingById(settingId);  // 이 메소드 Service, DAO에 추가 필요
	    model.addAttribute("waitingSettingVO", settingVO);
	    return "waiting/owner/settingForm";
	}

	@PostMapping("/settings/edit")
	public String editSetting(@ModelAttribute WaitingSettingVO settingVO) {
	    settingService.updateSetting(settingVO);
	    return "redirect:/waiting/owner/settings?storeId=" + settingVO.getStoreId();
	}

	@GetMapping("/settings/delete/{settingId}")
	public String deleteSetting(@PathVariable Long settingId, @RequestParam Long storeId) {
	    settingService.deleteSetting(settingId);
	    return "redirect:/waiting/owner/settings?storeId=" + storeId;
	}

}
