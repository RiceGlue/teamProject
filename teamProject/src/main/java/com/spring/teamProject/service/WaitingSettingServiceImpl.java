package com.spring.teamProject.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.spring.teamProject.dao.WaitingSettingDAO;
import com.spring.teamProject.vo.WaitingSettingVO;

@Service
public class WaitingSettingServiceImpl implements WaitingSettingService {

    private final WaitingSettingDAO settingDAO;

    public WaitingSettingServiceImpl(WaitingSettingDAO settingDAO) {
        this.settingDAO = settingDAO;
    }

    @Override
    public List<WaitingSettingVO> getAllSettingsByStoreId(Long storeId) {
        return settingDAO.getAllSettingsByStoreId(storeId);
    }

    @Override
    public WaitingSettingVO getSetting(Long storeId, int dayOfWeek, String timeSlot) {
        return settingDAO.getSetting(storeId, dayOfWeek, timeSlot);
    }

    @Override
    public void insertSetting(WaitingSettingVO setting) {
        settingDAO.insertSetting(setting);
    }

    @Override
    public void updateSetting(WaitingSettingVO setting) {
        settingDAO.updateSetting(setting);
    }

    @Override
    public void deleteSetting(Long settingId) {
        settingDAO.deleteSetting(settingId);
    }
}
