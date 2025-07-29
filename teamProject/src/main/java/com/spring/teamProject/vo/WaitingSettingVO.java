package com.spring.teamProject.vo;

import java.time.LocalTime;
import java.time.LocalDateTime;

public class WaitingSettingVO {
	private Long settingId;
    private Long storeId;
    private int dayOfWeek; // 요일 정보를 int로 관리하는 것으로 보입니다. (예: 1=월, 7=일 또는 Calendar.MONDAY 등)
    private LocalTime timeSlot;
    private int maxTeams;
    private boolean active;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Long getSettingId() { return settingId; }
    public void setSettingId(Long settingId) { this.settingId = settingId; }

    public Long getStoreId() { return storeId; }
    public void setStoreId(Long storeId) { this.storeId = storeId; }

    public int getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(int dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public LocalTime getTimeSlot() { return timeSlot; }
    public void setTimeSlot(LocalTime timeSlot) { this.timeSlot = timeSlot; }

    public int getMaxTeams() { return maxTeams; }
    public void setMaxTeams(int maxTeams) { this.maxTeams = maxTeams; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    // 오타 수정: voidSetUpdatedAt 메소드를 제거하고 아래 메소드만 남깁니다.
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // 필요하다면 toString() 메소드를 추가하여 로깅 시 객체 내용을 쉽게 확인할 수 있도록 합니다.
    @Override
    public String toString() {
        return "WaitingSettingVO{" +
                "settingId=" + settingId +
                ", storeId=" + storeId +
                ", dayOfWeek=" + dayOfWeek +
                ", timeSlot=" + timeSlot +
                ", maxTeams=" + maxTeams +
                ", active=" + active +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}