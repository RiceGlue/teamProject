// src/main/java/com/spring/teamProject/service/ReservationService.java
package com.spring.teamProject.service;

import java.util.List;

import com.spring.teamProject.vo.ReservationVO;

public interface ReservationService {
    // 고객 예약 신청
    void addReservation(ReservationVO reservation) throws Exception;

    // 점주용 특정 매장의 예약 목록 조회
    List<ReservationVO> getReservationsByStoreId(Long storeId) throws Exception;

    // 점주용 예약 상태 업데이트
    void updateReservationStatus(Long reservationId, String status) throws Exception;

    // 예약 상세 조회 (필요 시)
    ReservationVO getReservationById(Long reservationId) throws Exception;

    // (추가 가능) 예약 가능한 테이블 조회 (reservation_settings와 store_tables 활용)
    // List<TableVO> getAvailableTables(Long storeId, LocalDateTime desiredTime, int guestCount) throws Exception;

    // (추가 가능) 예약 시간 슬롯 조회 (reservation_settings 활용)
    // List<TimeSlotVO> getAvailableTimeSlots(Long storeId, LocalDate date) throws Exception;
}