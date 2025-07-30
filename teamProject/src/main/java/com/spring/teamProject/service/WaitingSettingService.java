package com.spring.teamProject.service;

import java.util.List;

import com.spring.teamProject.vo.WaitingSettingVO;

public interface WaitingSettingService {

    List<WaitingSettingVO> getAllSettingsByStoreId(Long storeId);

    // 기존의 dayOfWeek와 timeSlot을 사용하던 메서드는 제거하거나 시그니처를 변경해야 합니다.
    // 아래와 같이 storeId만 받는 메서드로 변경하는 것을 권장합니다.
    // WaitingSettingVO getSetting(Long storeId, int dayOfWeek, String timeSlot); // <-- 이 줄을 제거하거나 아래처럼 변경

    WaitingSettingVO getSetting(Long storeId); // <-- 매장 ID로 단일 설정 가져오는 메서드 추가 (혹은 다른 이름으로)


    void insertSetting(WaitingSettingVO setting);

    void updateSetting(WaitingSettingVO setting);

    void deleteSetting(Long settingId);

    WaitingSettingVO getSettingById(Long settingId);
}