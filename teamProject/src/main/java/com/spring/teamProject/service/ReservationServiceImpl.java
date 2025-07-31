// src/main/java/com/spring/teamProject/service/ReservationServiceImpl.java
package com.spring.teamProject.service;

import com.spring.teamProject.dao.ReservationDAO;
import com.spring.teamProject.vo.ReservationVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class ReservationServiceImpl implements ReservationService {

    @Autowired
    private ReservationDAO reservationDAO;

    @Override
    public void addReservation(ReservationVO reservation) throws Exception {
        // 예약 유효성 검사 등 비즈니스 로직 추가 가능
        // 예: 해당 테이블이 해당 시간에 예약 가능한지, 인원수 제한 등
        reservationDAO.insertReservation(reservation);
    }

    @Override
    public List<ReservationVO> getReservationsByStoreId(Long storeId) throws Exception {
        return reservationDAO.selectReservationsByStoreId(storeId);
    }

    @Override
    public void updateReservationStatus(Long reservationId, String status) throws Exception {
        // 상태 업데이트 전 유효성 검사 등 비즈니스 로직 추가 가능
        reservationDAO.updateReservationStatus(reservationId, status);
    }

    @Override
    public ReservationVO getReservationById(Long reservationId) throws Exception {
        return reservationDAO.selectReservationById(reservationId);
    }
}