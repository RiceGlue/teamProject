package com.spring.teamProject.vo;

import java.time.LocalDateTime; // DATETIME 타입에 매핑

public class ReservationVO {
    private Long reservationId;
    private Long memberId; // DDL상 NOT NULL
    private Long storeId;
    private Long tableId; // DDL상 NOT NULL
    private LocalDateTime reservationTime; // DATETIME 타입에 매핑
    private int guestCount;
    private String status; // ENUM 값은 PENDING, CONFIRMED, CANCELLED, COMPLETED, NO_SHOW
    private String cancelledReason; // DDL상 DEFAULT NULL

    // DDL에 없는 필드지만, 예약 신청 시 필요할 수 있는 정보 (VO에 유지)
    private String customerName; // 예약자 이름 (DB 저장 시 memberId와 연결 또는 별도 필드 필요)
    private String customerPhoneNumber; // 예약자 연락처 (DB 저장 시 memberId와 연결 또는 별도 필드 필요)
    private String request; // 요청 사항 (DB에 request 컬럼이 없다면 활용 불가)

    public ReservationVO() {}

    // Getter, Setter (Lombok @Data 사용 시 자동 생성)
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

    public int getGuestCount() { return guestCount; }
    public void setGuestCount(int guestCount) { this.guestCount = guestCount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCancelledReason() { return cancelledReason; }
    public void setCancelledReason(String cancelledReason) { this.cancelledReason = cancelledReason; }

    // DDL에 없는 필드들에 대한 Getter, Setter (유지)
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getCustomerPhoneNumber() { return customerPhoneNumber; }
    public void setCustomerPhoneNumber(String customerPhoneNumber) { this.customerPhoneNumber = customerPhoneNumber; }

    public String getRequest() { return request; }
    public void setRequest(String request) { this.request = request; }

    @Override
    public String toString() {
        return "ReservationVO{" +
                "reservationId=" + reservationId +
                ", memberId=" + memberId +
                ", storeId=" + storeId +
                ", tableId=" + tableId +
                ", reservationTime=" + reservationTime +
                ", guestCount=" + guestCount +
                ", status='" + status + '\'' +
                ", cancelledReason='" + cancelledReason + '\'' +
                ", customerName='" + customerName + '\'' +
                ", customerPhoneNumber='" + customerPhoneNumber + '\'' +
                ", request='" + request + '\'' +
                '}';
    }
}