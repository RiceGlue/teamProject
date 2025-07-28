package com.spring.teamProject.vo;

import java.time.LocalTime;    // time_slot을 위해 import
import java.time.LocalDateTime; // created_at, updated_at을 위해 import

public class WaitingSettingVO {
	private Long settingId;
    private Long storeId;
    private int dayOfWeek;
    private LocalTime timeSlot; // MySQL TIME 타입에 맞춰 LocalTime으로 변경
    private int maxTeams;
    private boolean active;

    // DDL에 있는 created_at, updated_at 컬럼에 대한 필드 추가
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;


    public Long getSettingId() { return settingId; }
    public void setSettingId(Long settingId) { this.settingId = settingId; }

    public Long getStoreId() { return storeId; }
    public void setStoreId(Long storeId) { this.storeId = storeId; }

    public int getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(int dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    // String에서 LocalTime으로 getter/setter 타입 변경
    public LocalTime getTimeSlot() { return timeSlot; }
    public void setTimeSlot(LocalTime timeSlot) { this.timeSlot = timeSlot; }

    public int getMaxTeams() { return maxTeams; }
    public void setMaxTeams(int maxTeams) { this.maxTeams = maxTeams; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    // createdAt, updatedAt에 대한 getter/setter 추가
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void voidSetUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; } // 오타 수정: setUpdatedAt
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}