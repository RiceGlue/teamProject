package com.spring.teamProject.vo;

import java.time.LocalDateTime;

public class WaitingVO {
	private Long waitingId;
    private Long memberId;
    private Long storeId;
    private int guestCount;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    private String fcmToken; // firebase waiting

    public Long getWaitingId() { return waitingId; }
    public void setWaitingId(Long waitingId) { this.waitingId = waitingId; }

    public Long getMemberId() { return memberId; }
    public void setMemberId(Long memberId) { this.memberId = memberId; }

    public Long getStoreId() { return storeId; }
    public void setStoreId(Long storeId) { this.storeId = storeId; }

    public int getGuestCount() { return guestCount; }
    public void setGuestCount(int guestCount) { this.guestCount = guestCount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public String getFcmToken() { return fcmToken; }
    public void setFcmToken(String fcmToken) { this.fcmToken = fcmToken; }
}


