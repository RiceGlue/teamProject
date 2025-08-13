package com.spring.teamProject.dao;

import com.spring.teamProject.vo.PaymentVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface PaymentDAO {
    void insertPayment(PaymentVO payment) throws Exception;

    // ⭐⭐ 이 메서드의 매개변수를 'PaymentVO payment'로 변경하면 더 유연하게 사용할 수 있습니다.
    // 기존의 코드와 충돌하지 않도록 새로운 메서드를 추가하는 방식을 선택했습니다.
    void updatePaymentStatus(@Param("paymentId") Long paymentId, @Param("status") String status) throws Exception;

    // ⭐⭐ `PaymentServiceImpl`의 `completePayment` 로직에서 사용되는 메서드입니다.
    PaymentVO selectByTransactionId(@Param("transactionId") String transactionId) throws Exception;

    // `ReservationDAO`와 유사하게 예약 ID로 결제 정보를 조회하는 메서드
    PaymentVO selectByReservationId(@Param("reservationId") Long reservationId) throws Exception;
}