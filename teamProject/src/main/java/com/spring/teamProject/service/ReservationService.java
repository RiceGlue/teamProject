package com.spring.teamProject.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;

public interface ReservationService {
    // 예약 정보를 추가하는 메서드
    void addReservation(ReservationVO reservation) throws Exception;

    // 매장 ID로 예약 목록을 조회하는 메서드
    List<ReservationVO> getReservationsByStoreId(Long storeId) throws Exception;

    // 예약 ID와 상태로 예약 상태를 업데이트하는 메서드
    void updateReservationStatus(Long reservationId, String status) throws Exception;

    // 예약 ID로 특정 예약 정보를 조회하는 메서드
    ReservationVO getReservationById(Long reservationId) throws Exception;

    // 특정 날짜에 사용 가능한 테이블 목록을 조회하는 메서드
    Map<String, List<StoreTableVO>> getAvailableTimeSlots(Long storeId, LocalDate date) throws Exception;

    // 특정 시간대에 사용 가능한 테이블을 찾는 메서드
    Optional<Long> findAvailableTable(Long storeId, LocalDateTime reservationTime, int guestCount);
}