package com.spring.teamProject.service;

import org.apache.ibatis.annotations.Param;

import com.spring.teamProject.vo.PaymentVO;

public interface PaymentService {
	// 결제 정보 추가 메서드를 하나로 통일
    void addPayment(PaymentVO payment) throws Exception;

    // 결제 상태 업데이트 메서드를 하나로 통일
    void updatePaymentStatus(PaymentVO payment) throws Exception;

    // transactionId로 결제 정보 조회
    PaymentVO getPaymentByTransactionId(String transactionId) throws Exception;

    // reservationId로 결제 정보 조회
    PaymentVO getPaymentByReservationId(Long reservationId) throws Exception;

    // 결제 완료 처리 로직
    boolean completePayment(String paymentId) throws Exception;
}