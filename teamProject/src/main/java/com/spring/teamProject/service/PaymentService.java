// src/main/java/com/spring/teamProject/service/PaymentService.java

package com.spring.teamProject.service;

import com.spring.teamProject.vo.PaymentVO;

import java.math.BigDecimal;

public interface PaymentService {
    void addPayment(PaymentVO payment) throws Exception;
    PaymentVO getPaymentByTransactionId(String transactionId) throws Exception;
    void updatePaymentStatus(PaymentVO payment) throws Exception;

    // 이 메서드는 이제 사용하지 않습니다.
    // boolean verifyAndUpdatePayment(PaymentVO paymentVO);
}