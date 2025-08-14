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
import com.spring.teamProject.vo.PaymentVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;

@Service
@Transactional
public class ReservationServiceImpl implements ReservationService {

    @Autowired
    private ReservationDAO reservationDAO;

    @Autowired
    private StoreTableDAO storeTableDAO;

    // PaymentService를 추가로 주입합니다.
    @Autowired
    private PaymentService paymentService;

    public enum ReservationStatus {
        PENDING,     // 결제대기
        CONFIRMED,   // 예약확정
        CANCELLED,   // 예약취소
        COMPLETED,   // 이용완료
        NO_SHOW      // 미방문(노쇼)
    }

    @Override
    public void addReservation(ReservationVO reservation) throws Exception {
        // 예약 생성 시 초기 상태를 PENDING으로 설정
        reservation.setStatus(ReservationStatus.PENDING.name());
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

        // ⭐⭐ 수정된 부분: PENDING(결제 대기) 상태의 예약도 함께 조회합니다. ⭐⭐
        List<ReservationVO> existingReservations = reservationDAO.selectReservationsByStoreIdAndDateAndStatuses(
            storeId,
            date,
            List.of(ReservationStatus.CONFIRMED.name(), ReservationStatus.PENDING.name())
        );

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

    @Override
    public StoreTableVO getStoreTableInfoById(Long tableId) throws Exception {
        return storeTableDAO.selectStoreTableById(tableId);
    }

    @Override
    public List<StoreTableVO> getAllTables(int storeId) {
        // TODO Auto-generated method stub
        return null;
    }

    /**
     * 사용자 예약 취소 및 환불 메서드
     * @param reservationId 취소할 예약 ID
     * @throws Exception 예약이 존재하지 않거나, 이미 취소/완료된 예약인 경우
     */
    @Override
    public void cancelReservationByUser(Long reservationId) throws Exception {
        // 1. 예약 ID로 예약 정보를 조회합니다.
        ReservationVO reservation = reservationDAO.selectReservationById(reservationId);

        // 2. 예약 정보가 없으면 예외 처리합니다.
        if (reservation == null) {
            throw new Exception("예약 정보를 찾을 수 없습니다.");
        }

        // 3. 이미 취소되었거나 완료된 예약은 취소할 수 없도록 상태를 확인합니다.
        if (reservation.getStatus().equals(ReservationStatus.CANCELLED.name()) ||
            reservation.getStatus().equals(ReservationStatus.COMPLETED.name())) {
            throw new IllegalStateException("이미 취소되었거나 완료된 예약은 취소할 수 없습니다.");
        }

        // 4. 결제 정보를 조회합니다.
        PaymentVO payment = paymentService.getPaymentByReservationId(reservationId);

        if (payment == null) {
            throw new Exception("해당 예약에 대한 결제 정보를 찾을 수 없습니다.");
        }

        // 5. PaymentService의 환불 메서드를 호출합니다.
        // 이 메서드 내부에서 결제 시스템에 환불 요청을 보내고 PaymentVO의 상태를 업데이트합니다.
        paymentService.refundPayment(payment.getPaymentId());

        // 6. 환불이 성공하면, 예약 상태를 'CANCELLED'로 업데이트하고, 취소 사유를 함께 저장합니다.
        reservationDAO.updateReservationStatusAndReason(
            reservationId,
            ReservationStatus.CANCELLED.name(),
            "사용자 취소"
        );
    }

    /**
     * [신규] 사용자 ID로 예약 목록을 조회하는 메서드
     * @param memberId 사용자 ID
     * @return 해당 사용자의 예약 목록
     */
    @Override
    public List<ReservationVO> getReservationsByMemberId(Long memberId) {
        // ReservationDAO를 통해 memberId로 예약 목록을 조회합니다.
        return reservationDAO.selectReservationsByMemberId(memberId);
    }
}
