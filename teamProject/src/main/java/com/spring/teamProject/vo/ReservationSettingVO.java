// src/main/java/com/spring/teamProject/vo/ReservationSettingVO.java
package com.spring.teamProject.vo;

import java.time.LocalTime; // SQL TIME 타입에 매핑

public class ReservationSettingVO {
    private Long settingId;
    private Long storeId;
    private int dayOfWeek; // 요일 (1:일, 2:월, ..., 7:토)
    private LocalTime timeSlot; // 활성화할 특정 예약 시간 (예: 18:00:00)
    private boolean isActive; // 해당 슬롯 활성화 여부

    public ReservationSettingVO() {}

    // 모든 필드를 포함하는 생성자 (선택 사항)
    public ReservationSettingVO(Long settingId, Long storeId, int dayOfWeek, LocalTime timeSlot, boolean isActive) {
        this.settingId = settingId;
        this.storeId = storeId;
        this.dayOfWeek = dayOfWeek;
        this.timeSlot = timeSlot;
        this.isActive = isActive;
    }

    // Getter, Setter
    public Long getSettingId() {
        return settingId;
    }

    public void setSettingId(Long settingId) {
        this.settingId = settingId;
    }

    public Long getStoreId() {
        return storeId;
    }

    public void setStoreId(Long storeId) {
        this.storeId = storeId;
    }

    public int getDayOfWeek() {
        return dayOfWeek;
    }

    public void setDayOfWeek(int dayOfWeek) {
        this.dayOfWeek = dayOfWeek;
    }

    public LocalTime getTimeSlot() {
        return timeSlot;
    }

    public void setTimeSlot(LocalTime timeSlot) {
        this.timeSlot = timeSlot;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    @Override
    public String toString() {
        return "ReservationSettingVO{" +
                "settingId=" + settingId +
                ", storeId=" + storeId +
                ", dayOfWeek=" + dayOfWeek +
                ", timeSlot=" + timeSlot +
                ", isActive=" + isActive +
                '}';
    }
}