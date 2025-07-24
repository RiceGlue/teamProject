package com.spring.teamProject.controller;

import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.spring.teamProject.service.WaitingSettingService;
import com.spring.teamProject.vo.WaitingSettingVO;

@RestController
@RequestMapping("/waiting-setting")
public class WaitingSettingController {

    private final WaitingSettingService settingService;

    public WaitingSettingController(WaitingSettingService settingService) {
        this.settingService = settingService;
    }

    @GetMapping("/{storeId}")
    public List<WaitingSettingVO> getAllSettingsByStore(@PathVariable Long storeId) {
        return settingService.getAllSettingsByStoreId(storeId);
    }

    @PostMapping
    public void insertSetting(@RequestBody WaitingSettingVO setting) {
        settingService.insertSetting(setting);
    }

    @PutMapping
    public void updateSetting(@RequestBody WaitingSettingVO setting) {
        settingService.updateSetting(setting);
    }

    @DeleteMapping("/{settingId}")
    public void deleteSetting(@PathVariable Long settingId) {
        settingService.deleteSetting(settingId);
    }
}
