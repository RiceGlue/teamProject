package com.spring.teamProject.service;

import com.spring.teamProject.vo.PaymentVO;

public interface PaymentService {
    void addPayment(PaymentVO payment) throws Exception;
    PaymentVO getPaymentByTransactionId(String transactionId) throws Exception;
    void updatePaymentStatus(PaymentVO payment) throws Exception;
    // ⭐ 추가해야 할 메서드
    PaymentVO getPaymentByReservationId(Long reservationId) throws Exception;
}