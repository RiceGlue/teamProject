package com.spring.teamProject.vo;

import java.time.LocalDateTime;
import java.util.List;

public class ReservationVO {
    private Long reservationId;
    private Long memberId;
    private Long storeId;
    private LocalDateTime reservationTime;
    private int guestCount; // int 타입으로 통일
    private String status;
    private LocalDateTime createdAt;
    private String cancelledReason;
    private String paymentId;
    private String storeName;
    // --- 변경점 ---
    // 단일 테이블 ID(tableId) 필드를 제거했습니다.
    // 하나의 예약에 여러 테이블이 할당될 수 있도록 List<StoreTableVO> 필드를 유지합니다.
    private List<StoreTableVO> tables;

    // 기본 생성자
    public ReservationVO() {}

    // --- 변경점: tableId 필드를 제거한 새로운 생성자 ---
    public ReservationVO(Long reservationId, Long memberId, Long storeId, LocalDateTime reservationTime, int guestCount, String status, String cancelledReason, LocalDateTime createdAt) {
        this.reservationId = reservationId;
        this.memberId = memberId;
        this.storeId = storeId;
        this.reservationTime = reservationTime;
        this.guestCount = guestCount;
        this.status = status;
        this.cancelledReason = cancelledReason;
        this.createdAt = createdAt;
    }

    // --- getter/setter 메서드 ---
    // paymentId
    public String getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(String paymentId) {
        this.paymentId = paymentId;
    }

    // tables
    public List<StoreTableVO> getTables() {
        return tables;
    }

    public void setTables(List<StoreTableVO> tables) {
        this.tables = tables;
    }

    // reservationId
    public Long getReservationId() {
        return reservationId;
    }

    public void setReservationId(Long reservationId) {
        this.reservationId = reservationId;
    }

    // memberId
    public Long getMemberId() {
        return memberId;
    }

    public void setMemberId(Long memberId) {
        this.memberId = memberId;
    }

    // storeId
    public Long getStoreId() {
        return storeId;
    }

    public void setStoreId(Long storeId) {
        this.storeId = storeId;
    }

    // reservationTime
    public LocalDateTime getReservationTime() {
        return reservationTime;
    }

    public void setReservationTime(LocalDateTime reservationTime) {
        this.reservationTime = reservationTime;
    }

    // guestCount
    // int 타입으로 통일
    public int getGuestCount() {
        return guestCount;
    }

    public void setGuestCount(int guestCount) {
        this.guestCount = guestCount;
    }

    // status
    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    // cancelledReason
    public String getCancelledReason() {
        return cancelledReason;
    }

    public void setCancelledReason(String cancelledReason) {
        this.cancelledReason = cancelledReason;
    }

    // createdAt
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getStoreName() {
        return storeName;
    }

    public void setStoreName(String storeName) {
        this.storeName = storeName;
    }

}
