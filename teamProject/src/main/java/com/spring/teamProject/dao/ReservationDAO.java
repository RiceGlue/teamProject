// src/main/java/com/spring/teamProject/dao/ReservationDAO.java
package com.spring.teamProject.dao;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;

@Mapper
@Repository
public interface ReservationDAO {
    void insertReservation(ReservationVO reservation);
    List<ReservationVO> selectReservationsByStoreId(Long storeId);
    void updateReservationStatus(@Param("reservationId") Long reservationId, @Param("status") String status);
    ReservationVO selectReservationById(Long reservationId);


 // **추가해야 할 DAO 메서드**
    List<StoreTableVO> findAvailableTables(@Param("storeId") Long storeId,
                                           @Param("reservationTime") LocalDateTime reservationTime,
                                           @Param("guestCount") int guestCount);
    /**
     * 특정 매장의 특정 날짜에 대한 모든 예약 목록을 조회합니다.
     * @param storeId 매장 ID
     * @param date 조회 날짜
     * @return 해당 날짜의 예약 목록
     */
    List<ReservationVO> selectReservationsByStoreIdAndDate(@Param("storeId") Long storeId, @Param("date") LocalDate date);
}