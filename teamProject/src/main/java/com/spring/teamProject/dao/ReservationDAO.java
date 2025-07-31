// src/main/java/com/spring/teamProject/dao/ReservationDAO.java
package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import com.spring.teamProject.vo.ReservationVO;

@Mapper
@Repository
public interface ReservationDAO {
    void insertReservation(ReservationVO reservation);
    List<ReservationVO> selectReservationsByStoreId(Long storeId);
    void updateReservationStatus(@Param("reservationId") Long reservationId, @Param("status") String status);
    ReservationVO selectReservationById(Long reservationId);
}