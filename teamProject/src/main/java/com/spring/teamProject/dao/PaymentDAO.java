package com.spring.teamProject.dao;

import com.spring.teamProject.vo.PaymentVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface PaymentDAO {

    /**
     * 새로운 결제 정보를 추가합니다.
     */
    void insertPayment(PaymentVO payment) throws Exception;

    /**
     * 결제 ID와 상태로 결제 상태를 업데이트합니다.
     * @param paymentId 업데이트할 결제 ID
     * @param status 새로운 상태 값
     */
    void updatePaymentStatus(@Param("paymentId") Long paymentId, @Param("status") String status) throws Exception;

    /**
     * transactionId로 결제 정보를 조회합니다.
     * @param transactionId 포트원에서 받은 고유 거래 ID
     */
    PaymentVO selectByTransactionId(@Param("transactionId") String transactionId) throws Exception;

    /**
     * reservationId로 결제 정보를 조회합니다.
     * @param reservationId 예약 ID
     */
    PaymentVO selectByReservationId(@Param("reservationId") Long reservationId) throws Exception;

    // 	paymentId로 결제 정보 조회 (새로 추가)
    PaymentVO selectById(Long paymentId);

    /**
     * paymentId로 결제 정보를 삭제합니다.
     * @param paymentId 삭제할 결제 ID
     */
    void deletePayment(Long paymentId);
}
