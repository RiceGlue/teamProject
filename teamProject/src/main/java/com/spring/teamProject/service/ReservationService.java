package com.spring.teamProject.service;

import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface ReservationService {

    /**
     * 새로운 예약 정보를 추가합니다.
     * @param reservation 예약 정보 VO
     * @throws Exception DB 처리 오류 발생 시
     */
    void addReservation(ReservationVO reservation) throws Exception;

    /**
     * 매장 ID로 예약 목록을 조회합니다.
     * @param storeId 매장 ID
     * @return 해당 매장의 모든 예약 목록
     * @throws Exception DB 처리 오류 발생 시
     */
    List<ReservationVO> getReservationsByStoreId(Long storeId) throws Exception;

    /**
     * 예약 ID와 상태로 예약 상태를 업데이트합니다.
     * @param reservationId 예약 ID
     * @param status 변경할 예약 상태 (예: PENDING, CONFIRMED 등)
     * @throws Exception DB 처리 오류 발생 시
     */
    void updateReservationStatus(Long reservationId, String status) throws Exception;

    /**
     * 예약 ID로 특정 예약 정보를 조회합니다.
     * @param reservationId 예약 ID
     * @return 예약 정보 VO
     * @throws Exception DB 처리 오류 발생 시
     */
    ReservationVO getReservationById(Long reservationId) throws Exception;

    /**
     * 특정 날짜에 사용 가능한 테이블 목록을 시간대별로 조회합니다.
     * @param storeId 매장 ID
     * @param date 조회할 날짜 문자열 (YYYY-MM-DD 형식)
     * @return 시간대(키)와 사용 가능한 테이블 목록(값)을 담은 맵
     */
    Map<String, List<StoreTableVO>> getAvailableTimeSlots(long storeId, String date);

    /**
     * tableId로 테이블 상세 정보를 조회합니다.
     * @param tableId 테이블 ID
     * @return 테이블 정보 VO
     * @throws Exception DB 처리 오류 발생 시
     */
    StoreTableVO getStoreTableInfoById(Long tableId) throws Exception;

    /**
     * 사용자가 예약을 취소합니다.
     * @param reservationId 예약 ID
     * @throws Exception 예약 정보가 없거나 이미 취소된 경우
     */
    void cancelReservationByUser(Long reservationId) throws Exception;

    /**
     * 사용자 ID로 예약 목록을 조회합니다.
     * @param memberId 사용자 ID
     * @return 해당 사용자의 예약 목록
     */
    List<ReservationVO> getReservationsByMemberId(Long memberId);

	/**
	 * 특정 시간대에 사용 가능한 테이블을 찾습니다.
	 * @param storeId 매장 ID
	 * @param reservationTime 예약 시간
	 * @param guestCount 예약 인원 수
	 * @return 사용 가능한 테이블 ID를 담은 Optional 객체
	 */
	Optional<Long> findAvailableTable(Long storeId, LocalDateTime reservationTime, int guestCount);

	/**
	 * 매장 ID로 모든 테이블 목록을 가져옵니다.
	 * @param storeId 매장 ID
	 * @return 매장의 모든 테이블 목록
	 */
	List<StoreTableVO> getAllTables(int storeId);

    /**
     * 결제 ID를 사용하여 PENDING 상태의 예약을 CONFIRMED로 업데이트합니다.
     * @param paymentId 결제 ID
     * @return 성공 여부 (true: 성공, false: 실패)
     */
    boolean updateReservationToConfirmed(String paymentId);

    /**
     * transactionId를 사용하여 임시 예약 및 관련 결제 정보를 삭제합니다.
     * @param transactionId 임시 예약의 transactionId
     * @return 삭제 성공 여부
     */
    boolean deleteTempReservationByTransactionId(String transactionId);
}
