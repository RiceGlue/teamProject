package com.spring.teamProject.vo;

public class WaitingVO {
    private Long waitingId;
    private Long storeId;
    private int dayOfWeek;
    private String timeSlot;
    private int maxTeams;
    private boolean isActive;

    public Long getWaitingId() { return waitingId; }
    public void setWaitingId(Long waitingId) { this.waitingId = waitingId; }

    public Long getStoreId() { return storeId; }
    public void setStoreId(Long storeId) { this.storeId = storeId; }

    public int getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(int dayOfWeek) { this.dayOfWeek = dayOfWeek; }

    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }

    public int getMaxTeams() { return maxTeams; }
    public void setMaxTeams(int maxTeams) { this.maxTeams = maxTeams; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean isActive) { this.isActive = isActive; }
}


