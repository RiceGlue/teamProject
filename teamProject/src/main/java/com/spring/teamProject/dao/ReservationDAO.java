package com.spring.teamProject.dao;

import java.util.List;
import java.util.Optional;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Repository;

import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;

@Mapper
@Repository
public interface ReservationDAO {

    // 매장-날짜-상태로 예약 목록 조회
    List<ReservationVO> selectReservationsByStoreIdAndDateAndStatuses(@Param("storeId") long storeId, @Param("date") String date, @Param("statuses") List<String> statuses);

    // 새로운 예약 정보 삽입
    int insertReservation(ReservationVO reservation);

    // reservation_table 테이블에 예약-테이블 연결 정보 삽입
    int insertReservationTables(@Param("reservationId") long reservationId, @Param("tableIds") List<Long> tableIds);

    // 매장 ID로 예약 목록 조회
    List<ReservationVO> selectReservationsByStoreId(long storeId);

    // 예약 상태 업데이트
    int updateReservationStatus(@Param("reservationId") long reservationId, @Param("status") String status);

    // 예약 ID로 예약 정보 조회
    ReservationVO selectReservationById(long reservationId);

    // 매장 ID와 날짜로 예약 목록 조회
    List<ReservationVO> selectReservationsByStoreIdAndDate(@Param("storeId") long storeId, @Param("date") String date);

    // 매장 ID로 모든 테이블 조회
    List<StoreTableVO> selectAllTablesByStoreId(long storeId);

    StoreTableVO selectStoreTableById(long tableId);

    int updateReservationStatusAndReason(@Param("reservationId") long reservationId, @Param("status") String status, @Param("cancelledReason") String cancelledReason);

    // 회원 ID로 예약 목록 조회
    List<ReservationVO> selectReservationsByMemberId(long memberId);

    // 결제 ID로 PENDING 상태의 예약을 조회
    Optional<ReservationVO> selectPendingReservationByPaymentId(@Param("paymentId") String paymentId);

    // 임시 예약에 연결된 테이블 정보 삭제
    int deleteReservationTables(@Param("reservationId") long reservationId);

    // 임시 예약 정보 삭제
    int deleteReservation(@Param("reservationId") long reservationId);
    
    //사용자 벌점 제도
    void increaseUserTemperatureByReservation (long reservationId) throws DataAccessException;
    void decreaseUserTemperatureByReservation (long reservationId) throws DataAccessException;
}
