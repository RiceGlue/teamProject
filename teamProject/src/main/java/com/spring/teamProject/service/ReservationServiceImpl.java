package com.spring.teamProject.service;

import com.spring.teamProject.dao.ReservationDAO;
import com.spring.teamProject.vo.PaymentVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class ReservationServiceImpl implements ReservationService {

	private static final Logger logger = LoggerFactory.getLogger(ReservationServiceImpl.class);

    @Autowired
    private ReservationDAO reservationDAO;

    // PaymentService를 주입받아 사용합니다.
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

    @Override
    public Map<String, List<StoreTableVO>> getAvailableTimeSlots(long storeId, String date) {

    	// 시간대별로 예약 가능 테이블 목록을 담을 맵
        Map<String, List<StoreTableVO>> availableSlots = new LinkedHashMap<>();

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


//
//        // 각 시간대별로 예약 가능한 테이블을 계산
//        for (String time : timeSlots) {
//            String reservationTimeStr = date + "T" + time;
//            LocalDateTime currentSlotTime = LocalDateTime.parse(reservationTimeStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
//
//            List<StoreTableVO> availableTablesInSlot = new ArrayList<>(allTables);
//
//            // 해당 시간대에 예약된 테이블을 걸러냄
//            for (ReservationVO reserved : reservedReservations) {
//                // 예약 시간과 현재 슬롯 시간이 일치하는 경우
//                if (reserved.getReservationTime().equals(currentSlotTime)) {
//                    reserved.getTables().forEach(reservedTable ->
//                        availableTablesInSlot.removeIf(table -> table.getTableId().equals(reservedTable.getTableId()))
//                    );
//                }
//            }
//
//            // 예약 가능한 테이블이 1개 이상 있을 경우 맵에 추가
//            if (!availableTablesInSlot.isEmpty()) {
//                availableSlots.put(time, availableTablesInSlot);
//            }
//        }

        // --- ⭐ 이 부분부터 로직을 수정합니다. ⭐ ---
        // 모든 시간대를 미리 맵에 추가하고, 값으로 빈 리스트를 넣어둡니다.
        for (String time : timeSlots) {
            availableSlots.put(time, new ArrayList<>());
        }

        // 각 시간대별로 예약 가능한 테이블을 계산
        for (String time : timeSlots) {
            // 모든 테이블로 시작하여, 예약된 테이블을 제외합니다.
            List<StoreTableVO> availableTablesInSlot = new ArrayList<>(allTables);

            // 해당 시간대에 이미 예약된 테이블을 찾아 제거합니다.
            for (ReservationVO reserved : reservedReservations) {
                // 예약 시간과 현재 슬롯 시간이 일치하는 경우
                String reservedTimeStr = reserved.getReservationTime().format(DateTimeFormatter.ofPattern("HH:mm"));
                if (reservedTimeStr.equals(time)) {
                    reserved.getTables().forEach(reservedTable ->
                        availableTablesInSlot.removeIf(table -> table.getTableId().equals(reservedTable.getTableId()))
                    );
                }
            }

            // 계산된 예약 가능 테이블 목록을 해당 시간대 키에 다시 설정합니다.
            availableSlots.put(time, availableTablesInSlot);
        }
        // --- ⭐ 여기까지 로직을 수정합니다. ⭐ ---
        return availableSlots;
    }

    @Override
    public StoreTableVO getStoreTableInfoById(Long tableId) throws Exception {
        return reservationDAO.selectStoreTableById(tableId);
    }

    @Override
    @Transactional
    public void cancelReservationByUser(Long reservationId) throws Exception {
        ReservationVO reservation = reservationDAO.selectReservationById(reservationId);
        if (reservation == null) {
            throw new Exception("예약 정보를 찾을 수 없습니다.");
        }
        if (reservation.getStatus().equals(ReservationStatus.CANCELLED.name()) ||
            reservation.getStatus().equals(ReservationStatus.COMPLETED.name())) {
            throw new IllegalStateException("이미 취소되었거나 완료된 예약은 취소할 수 없습니다.");
        }

        // 결제 정보가 없을 수도 있으므로 Optional로 처리
        PaymentVO payment = paymentService.getPaymentByReservationId(reservationId);
        if (payment != null) {
            paymentService.refundPayment(payment.getPaymentId());
        } else {
            logger.warn("Reservation {} has no payment associated. Skipping refund process.", reservationId);
        }

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
		return Optional.empty();
	}

	@Override
	public List<StoreTableVO> getAllTables(int storeId) {
		return null;
	}

	@Override
    @Transactional
    public boolean updateReservationToConfirmed(String paymentId) {
        try {
            Optional<ReservationVO> pendingReservationOpt = reservationDAO.selectPendingReservationByPaymentId(paymentId);
            if (pendingReservationOpt.isPresent()) {
                ReservationVO reservation = pendingReservationOpt.get();
                reservationDAO.updateReservationStatus(reservation.getReservationId(), ReservationStatus.CONFIRMED.name());
                logger.info("Reservation with ID {} has been confirmed successfully.", reservation.getReservationId());
                return true;
            } else {
                logger.warn("Pending reservation with paymentId {} not found or already processed.", paymentId);
                return false;
            }
        } catch (Exception e) {
            logger.error("Error confirming reservation with paymentId {}: {}", paymentId, e.getMessage());
            throw new RuntimeException("Failed to confirm reservation.", e);
        }
    }

    @Override
    @Transactional
    public boolean deleteTempReservationByTransactionId(String transactionId) {
        try {
            // 1. transactionId로 결제 정보 조회
            PaymentVO payment = paymentService.getPaymentByTransactionId(transactionId);
            if (payment == null) {
                logger.warn("Payment information with transactionId {} not found. It might have been deleted already.", transactionId);
                return true;
            }

            Long reservationId = payment.getReservationId();
            if (reservationId != null) {
                // 2. 예약 테이블 연결 정보 삭제 (외래키 제약조건 때문에 먼저 삭제)
                int tablesDeleted = reservationDAO.deleteReservationTables(reservationId);
                logger.info("Deleted {} reservation tables for reservationId: {}.", tablesDeleted, reservationId);

                // 3. 임시 예약 정보 삭제
                int reservationDeleted = reservationDAO.deleteReservation(reservationId);
                logger.info("Deleted {} temporary reservation for reservationId: {}.", reservationDeleted, reservationId);
            }

            // 4. 결제 정보 삭제
            paymentService.deletePayment(payment.getPaymentId());
            logger.info("Deleted payment for paymentId: {}.", payment.getPaymentId());

            return true; // 모든 작업이 성공적으로 진행되면 true 반환

        } catch (Exception e) {
            logger.error("Error deleting temp reservation with transactionId {}: {}", transactionId, e.getMessage());
            // 예외 발생 시 트랜잭션이 롤백됩니다.
            throw new RuntimeException("Failed to delete temporary reservation due to a database error.", e);
        }
    }


    /**
     * 결제 웹훅(paymentId)에 의해 임시 예약을 취소(상태 업데이트)합니다.
     * @param paymentId 취소할 결제 ID
     * @return 성공 여부
     */
    @Override
    @Transactional
    public boolean cancelReservationByPaymentId(String paymentId) {
        try {
            // 1. paymentId로 결제 정보 조회 (reservationId를 얻기 위함)
            PaymentVO payment = paymentService.getPaymentById(paymentId);
            if (payment == null) {
                logger.warn("Payment with ID {} not found. Cannot proceed with reservation cancellation.", paymentId);
                return false;
            }

            Long reservationId = payment.getReservationId();
            if (reservationId != null) {
                // 2. reservationId로 예약 정보 상태를 'CANCELLED'로 업데이트
                reservationDAO.updateReservationStatus(reservationId, ReservationStatus.CANCELLED.name());
                logger.info("Updated reservation status to CANCELLED for reservationId: {}.", reservationId);

                // 3. 결제 정보 상태도 'CANCELLED'로 업데이트
                paymentService.updatePaymentStatus(payment.getPaymentId(), "CANCELLED");
                logger.info("Updated payment status to CANCELLED for paymentId: {}.", payment.getPaymentId());

                return true;
            } else {
                logger.warn("Reservation ID not found for paymentId: {}. Cannot cancel reservation.", paymentId);
                return false;
            }

        } catch (Exception e) {
            logger.error("Error cancelling reservation with paymentId {}: {}", paymentId, e.getMessage());
            throw new RuntimeException("Failed to cancel reservation due to a database error.", e);
        }
    }

    @Override
    public void increaseUserTemperatureByReservation(long reservationId) throws Exception {
    	reservationDAO.increaseUserTemperatureByReservation(reservationId);
    }

    @Override
    public void decreaseUserTemperatureByReservation(long reservationId) throws Exception {
    	reservationDAO.decreaseUserTemperatureByReservation(reservationId);
    }

    @Override
    public long getReservationCountByStoreId(long storeId) {
        return reservationDAO.selectReservationCountByStoreId(storeId);
    }

    /**
     * 특정 매장의 예약 목록을 상태별, 페이지별로 조회합니다.
     */
    @Override
    public List<ReservationVO> getReservationsByStoreIdAndStatusWithPaging(Long storeId, String status, int page, int size) throws Exception {
        // offset은 DB에서 데이터를 어디부터 가져올지 결정합니다.
        int offset = page * size;
        return reservationDAO.selectReservationsByStoreIdAndStatusWithPaging(storeId, status, size, offset);
    }

    @Override
    public long getTodaysConfirmedReservationCount(Long storeId) throws Exception {
        return reservationDAO.selectTodaysConfirmedReservationCount(storeId);
    }

    @Override
    public long getTotalConfirmedReservationCount(Long storeId) throws Exception {
        return reservationDAO.selectTotalConfirmedReservationCount(storeId);
    }
}
