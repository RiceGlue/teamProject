package com.spring.teamProject.dao;

import com.spring.teamProject.vo.PaymentVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface PaymentDAO {
    void insertPayment(PaymentVO payment) throws Exception;
    void updatePaymentStatus(@Param("paymentId") Long paymentId, @Param("status") String status) throws Exception;
    PaymentVO selectByTransactionId(@Param("transactionId") String transactionId) throws Exception;

    // ⭐ 추가해야 할 메서드
    PaymentVO selectByReservationId(@Param("reservationId") Long reservationId) throws Exception;
}