package com.spring.teamProject.vo;

import java.time.LocalDateTime;

public class WaitingVO {
	private Long waitingId;
    private Long memberId; // 기존 member_id(bigint) 필드는 DB 스키마 그대로 유지
    private Long storeId;
    private int guestCount;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private String fcmToken;
    private String loginId; // 새로운 필드 추가

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

    public String getLoginId() { return loginId; }
    public void setLoginId(String loginId) { this.loginId = loginId; }
}