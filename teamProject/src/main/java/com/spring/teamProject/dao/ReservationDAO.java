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

    /**
     * 새로운 예약 정보를 삽입합니다. (임시 예약 포함)
     * @param reservation 삽입할 예약 VO
     */
    void insertReservation(ReservationVO reservation);

    /**
     * 특정 매장의 모든 예약을 조회합니다.
     * @param storeId 매장 ID
     * @return 해당 매장의 예약 목록
     */
    List<ReservationVO> selectReservationsByStoreId(Long storeId);

    /**
     * 예약 상태를 업데이트합니다.
     * @param reservationId 예약 ID
     * @param status 변경할 상태
     */
    void updateReservationStatus(@Param("reservationId") Long reservationId, @Param("status") String status);

    /**
     * 예약 ID로 예약 정보를 조회합니다.
     * @param reservationId 예약 ID
     * @return 해당 예약 VO
     */
    ReservationVO selectReservationById(Long reservationId);

    /**
     * 특정 매장, 시간, 인원 수에 맞는 이용 가능한 테이블 목록을 조회합니다.
     * @param storeId 매장 ID
     * @param reservationTime 예약 시간
     * @param guestCount 예약 인원
     * @return 이용 가능한 테이블 목록
     */
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

    // **웹훅 처리를 위해 추가된 메서드**
    /**
     * 결제 ID(paymentId)로 예약 정보를 조회합니다.
     * @param paymentId PortOne에서 전달받은 결제 고유 ID
     * @return 해당 결제 ID에 해당하는 예약 VO, 없으면 null 반환
     */
    ReservationVO selectByPaymentId(@Param("paymentId") String paymentId);

    /**
     * 결제 ID와 status를 기반으로 예약 상태를 업데이트합니다.
     * @param paymentId 결제 ID
     * @param status 변경할 상태
     */
    void updateStatusByPaymentId(@Param("paymentId") String paymentId, @Param("status") String status);

    // tableId로 store_tables 정보를 조회
    /**
     * 테이블 ID로 테이블 정보를 조회합니다.
     * @param tableId 테이블 ID
     * @return 해당 테이블 VO
     */
    StoreTableVO selectStoreTableById(Long tableId);

    // --- **새로 추가된 메서드** ---

    /**
     * 특정 매장, 날짜, 상태에 해당하는 예약 목록을 조회합니다.
     * @param storeId 매장 ID
     * @param date 조회 날짜
     * @param status 조회할 예약 상태 (예: CONFIRMED)
     * @return 조건에 맞는 예약 목록
     */
    List<ReservationVO> selectReservationsByStoreIdAndDateAndStatus(
        @Param("storeId") Long storeId,
        @Param("date") LocalDate date,
        @Param("status") String status
    );

    /**
     * 예약 상태와 취소 사유를 함께 업데이트합니다.
     * @param reservationId 예약 ID
     * @param status 변경할 상태
     * @param cancelledReason 취소 사유
     */
    void updateReservationStatusAndReason(
        @Param("reservationId") Long reservationId,
        @Param("status") String status,
        @Param("cancelledReason") String cancelledReason
    );

    /**
     * [신규] 사용자 ID로 예약 목록을 조회하는 메서드
     * @param memberId 사용자 ID
     * @return 해당 사용자의 예약 목록
     */
    List<ReservationVO> selectReservationsByMemberId(Long memberId);
}
