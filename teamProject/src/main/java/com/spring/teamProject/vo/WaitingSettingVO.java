package com.spring.teamProject.vo;

// import java.time.LocalTime;    // <-- 이 임포트도 이제 필요 없습니다.
import java.time.LocalDateTime;

public class WaitingSettingVO {
	private Long settingId;
    private Long storeId;
    // private int dayOfWeek; // 불필요
    // private LocalTime timeSlot; // 불필요
    private int maxTeams;
    private boolean active;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;


    public Long getSettingId() { return settingId; }
    public void setSettingId(Long settingId) { this.settingId = settingId; }

    public Long getStoreId() { return storeId; }
    public void setStoreId(Long storeId) { this.storeId = storeId; }

    // public int getDayOfWeek() { return dayOfWeek; }
    // public void setDayOfWeek(int dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    // public LocalTime getTimeSlot() { return timeSlot; } // <-- 이 게터도 제거합니다.
    // public void setTimeSlot(LocalTime timeSlot) { this.timeSlot = timeSlot; } // <-- 이 세터도 제거합니다.

    public int getMaxTeams() { return maxTeams; }
    public void setMaxTeams(int maxTeams) { this.maxTeams = maxTeams; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "WaitingSettingVO{" +
                "settingId=" + settingId +
                ", storeId=" + storeId +
                // ", dayOfWeek=" + dayOfWeek +
                // ", timeSlot=" + timeSlot +
                ", maxTeams=" + maxTeams +
                ", active=" + active +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}