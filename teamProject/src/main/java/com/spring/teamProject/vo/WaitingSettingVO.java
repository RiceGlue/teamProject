package com.spring.teamProject.vo;

public class WaitingSettingVO {
	private Long settingId;
    private Long storeId;
    private int dayOfWeek;
    private String timeSlot;
    private int maxTeams;
    private boolean active;

    public Long getSettingId() { return settingId; }
    public void setSettingId(Long settingId) { this.settingId = settingId; }

    public Long getStoreId() { return storeId; }
    public void setStoreId(Long storeId) { this.storeId = storeId; }

    public int getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(int dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }

    public int getMaxTeams() { return maxTeams; }
    public void setMaxTeams(int maxTeams) { this.maxTeams = maxTeams; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
