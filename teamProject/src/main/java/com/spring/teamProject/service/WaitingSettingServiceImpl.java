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

    // 기존의 dayOfWeek와 timeSlot을 사용하는 getSetting 메서드는 더 이상 필요하지 않거나
    // 매장 ID만으로 단일 설정을 가져오도록 변경해야 합니다.
    // WaitingSettingDAO 인터페이스에서도 해당 메서드 시그니처를 변경하거나 제거해야 합니다.
    // 여기서는 일단 주석 처리하고, 매장당 하나의 '전역' 설정만 가져오는 새로운 메서드를 추가하는 것을 권장합니다.
    /*
    @Override
    public WaitingSettingVO getSetting(Long storeId, int dayOfWeek, String timeSlot) {
        // 이 메서드는 이제 사용되지 않거나, 매장당 하나의 전역 설정만 가져오도록 로직이 변경되어야 합니다.
        // 예를 들어, settingDAO.getSetting(storeId) 와 같이 매장 ID만으로 가져오거나,
        // getAllSettingsByStoreId를 호출하여 첫 번째 설정을 가져오는 식으로 변경해야 합니다.
        return settingDAO.getSetting(storeId, dayOfWeek, timeSlot); // 이 줄은 이제 에러를 발생시킬 것입니다.
    }
    */

    // 매장 ID로 단일 웨이팅 설정을 가져오는 메서드 추가 (필요시)
    // 매장당 웨이팅 설정이 하나만 존재하도록 설계했다면 이 메서드가 더 적절합니다.
    @Override
    public WaitingSettingVO getSetting(Long storeId) {
        // storeId로 여러 설정이 반환될 수 있다면, 첫 번째 설정을 반환하는 식으로 처리하거나
        // 이 메서드를 더 구체적인 이름으로 변경해야 합니다 (예: getSingleSettingByStoreId)
        List<WaitingSettingVO> settings = settingDAO.getAllSettingsByStoreId(storeId);
        if (settings != null && !settings.isEmpty()) {
            return settings.get(0); // 첫 번째 설정을 반환 (단일 설정으로 가정)
        }
        return null; // 설정이 없는 경우
    }


    @Override
    public void insertSetting(WaitingSettingVO setting) {
        // dayOfWeek 필드가 VO에서 제거되었으므로, 관련 로직 필요 없음
        settingDAO.insertSetting(setting);
    }

    @Override
    public void updateSetting(WaitingSettingVO setting) {
        // dayOfWeek 필드가 VO에서 제거되었으므로, 관련 로직 필요 없음
        settingDAO.updateSetting(setting);
    }

    @Override
    public void deleteSetting(Long settingId) {
        settingDAO.deleteSetting(settingId);
    }

    @Override
    public WaitingSettingVO getSettingById(Long settingId) {
        return settingDAO.getSettingById(settingId);
    }

}