// src/main/java/com/spring/teamProject/service/ReservationServiceImpl.java
package com.spring.teamProject.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.teamProject.dao.ReservationDAO;
import com.spring.teamProject.dao.StoreTableDAO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;

@Service
@Transactional
public class ReservationServiceImpl implements ReservationService {

    @Autowired
    private ReservationDAO reservationDAO;

    @Autowired
    private StoreTableDAO storeTableDAO;

    @Override
    public void addReservation(ReservationVO reservation) throws Exception {
        reservationDAO.insertReservation(reservation);
    }

    @Override
    public List<ReservationVO> getReservationsByStoreId(Long storeId) throws Exception {
        return reservationDAO.selectReservationsByStoreId(storeId);
    }

    @Override
    public void updateReservationStatus(Long reservationId, String status) throws Exception {
        reservationDAO.updateReservationStatus(reservationId, status);
    }

    @Override
    public ReservationVO getReservationById(Long reservationId) throws Exception {
        return reservationDAO.selectReservationById(reservationId);
    }

    @Override
    public Map<String, List<StoreTableVO>> getAvailableTimeSlots(Long storeId, LocalDate date) throws Exception {
        List<StoreTableVO> allTables = storeTableDAO.selectAllTablesByStoreId(storeId);

        List<ReservationVO> existingReservations = reservationDAO.selectReservationsByStoreIdAndDate(storeId, date);

        Map<Long, List<LocalDateTime>> reservedTableSlots = new HashMap<>();
        for (ReservationVO reservation : existingReservations) {
            reservedTableSlots.computeIfAbsent(reservation.getTableId(), k -> new ArrayList<>())
                              .add(reservation.getReservationTime());
        }

        Map<String, List<StoreTableVO>> availableSlots = new LinkedHashMap<>();

        LocalTime startTime = LocalTime.of(11, 0);
        LocalTime endTime = LocalTime.of(22, 0);
        LocalTime currentTimeSlot = startTime;

        while (currentTimeSlot.isBefore(endTime) || currentTimeSlot.equals(endTime)) {
            String timeKey = currentTimeSlot.toString();
            List<StoreTableVO> availableTablesForSlot = new ArrayList<>();
            LocalDateTime currentDateTime = LocalDateTime.of(date, currentTimeSlot);

            for (StoreTableVO table : allTables) {
                boolean isReserved = false;
                if (reservedTableSlots.containsKey(table.getTableId())) {
                    isReserved = reservedTableSlots.get(table.getTableId()).contains(currentDateTime);
                }

                if (!isReserved) {
                    availableTablesForSlot.add(table);
                }
            }

            if (!availableTablesForSlot.isEmpty()) {
                availableSlots.put(timeKey, availableTablesForSlot);
            }

            currentTimeSlot = currentTimeSlot.plusMinutes(30);
        }

        return availableSlots;
    }

    @Override
    public Optional<Long> findAvailableTable(Long storeId, LocalDateTime reservationTime, int guestCount) {
        // DAO를 통해 예약 가능한 테이블을 DB에서 조회하는 로직을 구현합니다.
        // 예를 들어, 예약 시간과 인원수에 맞는 테이블 목록을 가져오는 DAO 메서드를 호출합니다.

        // 이 부분은 예시 코드입니다. 실제로는 `reservationDAO`에 이 로직을 담은 쿼리가 필요합니다.
        List<StoreTableVO> availableTables = reservationDAO.findAvailableTables(storeId, reservationTime, guestCount);

        // 조회된 테이블이 있다면 그 중 첫 번째 테이블의 ID를 반환합니다.
        return availableTables.stream()
                .findFirst()
                .map(StoreTableVO::getTableId);
    }
}