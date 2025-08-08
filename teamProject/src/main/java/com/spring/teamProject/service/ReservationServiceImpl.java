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
        List<StoreTableVO> availableTables = reservationDAO.findAvailableTables(storeId, reservationTime, guestCount);

        return availableTables.stream()
                .findFirst()
                .map(StoreTableVO::getTableId);
    }
}