// src/main/java/com/spring/teamProject/service/ReservationService.java
package com.spring.teamProject.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;

public interface ReservationService {
    void addReservation(ReservationVO reservation) throws Exception;

    List<ReservationVO> getReservationsByStoreId(Long storeId) throws Exception;
    void updateReservationStatus(Long reservationId, String status) throws Exception;
    ReservationVO getReservationById(Long reservationId) throws Exception;
    Map<String, List<StoreTableVO>> getAvailableTimeSlots(Long storeId, LocalDate date) throws Exception;
 // **추가해야 할 메서드**
    public Optional<Long> findAvailableTable(Long storeId, LocalDateTime reservationTime, int guestCount);

}