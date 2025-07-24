package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.spring.teamProject.vo.WaitingSettingVO;

public interface WaitingSettingDAO {
	List<WaitingSettingVO> getAllSettingsByStoreId(Long storeId);
    WaitingSettingVO getSetting(@Param("storeId") Long storeId, @Param("dayOfWeek") int dayOfWeek, @Param("timeSlot") String timeSlot);
    WaitingSettingVO getSettingById(Long settingId);
    void insertSetting(WaitingSettingVO setting);
    void updateSetting(WaitingSettingVO setting);
    void deleteSetting(Long settingId);
}
