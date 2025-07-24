package com.spring.teamProject.service;

import java.util.List;

import com.spring.teamProject.vo.WaitingSettingVO;

public interface WaitingSettingService {
	List<WaitingSettingVO> getAllSettingsByStoreId(Long storeId);
    WaitingSettingVO getSetting(Long storeId, int dayOfWeek, String timeSlot);
    void insertSetting(WaitingSettingVO setting);
    void updateSetting(WaitingSettingVO setting);
    void deleteSetting(Long settingId);
}
