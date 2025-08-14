package com.spring.teamProject.service;

import com.spring.teamProject.dao.ReservationDAO;
import com.spring.teamProject.dao.StoreDAO;
import com.spring.teamProject.vo.PaymentVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class ReservationServiceImpl implements ReservationService {

    @Autowired
    private ReservationDAO reservationDAO;

    @Autowired
    private PaymentService paymentService;

    // ReservationStatus enum은 그대로 사용합니다.
    public enum ReservationStatus {
        PENDING,     // 결제대기
        CONFIRMED,   // 예약확정
        CANCELLED,   // 예약취소
        COMPLETED,   // 이용완료
        NO_SHOW      // 미방문(노쇼)
    }

    @Override
    public void addReservation(ReservationVO reservation) throws Exception {
        reservation.setStatus(ReservationStatus.PENDING.name());
        reservationDAO.insertReservation(reservation);

        if (reservation.getTables() != null && !reservation.getTables().isEmpty()) {
            List<Long> tableIds = reservation.getTables().stream()
                .map(StoreTableVO::getTableId)
                .collect(Collectors.toList());
            reservationDAO.insertReservationTables(reservation.getReservationId(), tableIds);
        }
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

    // 예약 가능 시간대와 테이블을 반환하는 핵심 로직
    @Override
    public Map<String, List<StoreTableVO>> getAvailableTimeSlots(long storeId, String date) {
        // 예약 가능한 시간대 (예시: 10:00부터 21:00까지 30분 간격)
        List<String> timeSlots = new ArrayList<>();
        for (int hour = 10; hour <= 21; hour++) {
            timeSlots.add(String.format("%02d:00", hour));
            if (hour < 21) {
                timeSlots.add(String.format("%02d:30", hour));
            }
        }

        // 해당 매장의 모든 테이블 정보를 가져옴
        List<StoreTableVO> allTables = reservationDAO.selectAllTablesByStoreId(storeId);

        // 해당 날짜에 이미 예약된 예약 정보들을 가져옴 (취소 상태 제외)
        List<String> activeStatuses = Arrays.asList("PENDING", "CONFIRMED");
        List<ReservationVO> reservedReservations = reservationDAO.selectReservationsByStoreIdAndDateAndStatuses(storeId, date, activeStatuses);

        // 시간대별로 예약 가능 테이블 목록을 담을 맵
        Map<String, List<StoreTableVO>> availableSlots = new LinkedHashMap<>();

        // 각 시간대별로 예약 가능한 테이블을 계산
        for (String time : timeSlots) {
            String reservationTimeStr = date + "T" + time;
            // DateTimeFormatter를 사용하려면 import가 필요합니다.
            LocalDateTime currentSlotTime = LocalDateTime.parse(reservationTimeStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);

            List<StoreTableVO> availableTablesInSlot = new ArrayList<>(allTables);

            // 해당 시간대에 예약된 테이블을 걸러냄
            for (ReservationVO reserved : reservedReservations) {
                // 예약 시간과 현재 슬롯 시간이 일치하는 경우
                if (reserved.getReservationTime().equals(currentSlotTime)) {
                    reserved.getTables().forEach(reservedTable ->
                        availableTablesInSlot.removeIf(table -> table.getTableId() == reservedTable.getTableId())
                    );
                }
            }

            // 예약 가능한 테이블이 1개 이상 있을 경우 맵에 추가
            if (!availableTablesInSlot.isEmpty()) {
                availableSlots.put(time, availableTablesInSlot);
            }
        }

        return availableSlots;
    }

    // ReservationService 인터페이스의 불필요한 메서드를 제거합니다.
    @Override
    public StoreTableVO getStoreTableInfoById(Long tableId) throws Exception {
        return reservationDAO.selectStoreTableById(tableId);
    }

    // 이 메서드는 구현이 불완전하고 사용되지 않으므로 제거합니다.
    // getAvailableTimeSlots() 메서드가 더 포괄적인 기능을 제공합니다.
    //@Override
    //public Optional<Long> findAvailableTable(Long storeId, LocalDateTime reservationTime, int guestCount) {
    //    List<StoreTableVO> availableTables = reservationDAO.findAvailableTables(storeId, reservationTime, guestCount);
    //
    //    return availableTables.stream()
    //            .findFirst()
    //            .map(StoreTableVO::getTableId);
    //}

    // 이 메서드는 구현이 불완전하고 사용되지 않으므로 제거합니다.
    //@Override
    //public List<StoreTableVO> getAllTables(int storeId) {
    //    return null;
    //}

    @Override
    public void cancelReservationByUser(Long reservationId) throws Exception {
        ReservationVO reservation = reservationDAO.selectReservationById(reservationId);

        if (reservation == null) {
            throw new Exception("예약 정보를 찾을 수 없습니다.");
        }

        if (reservation.getStatus().equals(ReservationStatus.CANCELLED.name()) ||
            reservation.getStatus().equals(ReservationStatus.COMPLETED.name())) {
            throw new IllegalStateException("이미 취소되었거나 완료된 예약은 취소할 수 없습니다.");
        }

        PaymentVO payment = paymentService.getPaymentByReservationId(reservationId);

        if (payment == null) {
            throw new Exception("해당 예약에 대한 결제 정보를 찾을 수 없습니다.");
        }

        paymentService.refundPayment(payment.getPaymentId());

        reservationDAO.updateReservationStatusAndReason(
            reservationId,
            ReservationStatus.CANCELLED.name(),
            "사용자 취소"
        );
    }

    @Override
    public List<ReservationVO> getReservationsByMemberId(Long memberId) {
        return reservationDAO.selectReservationsByMemberId(memberId);
    }

	@Override
	public Optional<Long> findAvailableTable(Long storeId, LocalDateTime reservationTime, int guestCount) {
		// TODO Auto-generated method stub
		return Optional.empty();
	}

	@Override
	public List<StoreTableVO> getAllTables(int storeId) {
		// TODO Auto-generated method stub
		return null;
	}
}
