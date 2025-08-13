package com.spring.teamProject.vo;

import java.time.LocalDateTime;

public class ReservationVO {
    private Long reservationId;
    private Long memberId;
    private Long storeId;
    private Long tableId;
    private LocalDateTime reservationTime;
    private Integer guestCount;
    private String status;
    private String cancelledReason;
    private LocalDateTime createdAt;

    public ReservationVO() {}

    public ReservationVO(Long reservationId, Long memberId, Long storeId, Long tableId, LocalDateTime reservationTime, Integer guestCount, String status, String cancelledReason, LocalDateTime createdAt) {
        this.reservationId = reservationId;
        this.memberId = memberId;
        this.storeId = storeId;
        this.tableId = tableId;
        this.reservationTime = reservationTime;
        this.guestCount = guestCount;
        this.status = status;
        this.cancelledReason = cancelledReason;
        this.createdAt = createdAt;
    }

    public Long getReservationId() { return reservationId; }
    public void setReservationId(Long reservationId) { this.reservationId = reservationId; }

    public Long getMemberId() { return memberId; }
    public void setMemberId(Long memberId) { this.memberId = memberId; }

    public Long getStoreId() { return storeId; }
    public void setStoreId(Long storeId) { this.storeId = storeId; }

    public Long getTableId() { return tableId; }
    public void setTableId(Long tableId) { this.tableId = tableId; }

    public LocalDateTime getReservationTime() { return reservationTime; }
    public void setReservationTime(LocalDateTime reservationTime) { this.reservationTime = reservationTime; }

    public Integer getGuestCount() { return guestCount; }
    public void setGuestCount(Integer guestCount) { this.guestCount = guestCount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCancelledReason() { return cancelledReason; }
    public void setCancelledReason(String cancelledReason) { this.cancelledReason = cancelledReason; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}