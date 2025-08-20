package com.spring.teamProject.service;

import com.spring.teamProject.vo.PaymentVO;

public interface PaymentService {

    /**
     * 새로운 결제 정보를 추가합니다.
     */
    void addPayment(PaymentVO payment) throws Exception;

    /**
     * PaymentVO 객체로 결제 상태를 업데이트합니다.
     */
    void updatePaymentStatus(PaymentVO payment) throws Exception;

    /**
     * transactionId로 결제 정보를 조회합니다.
     */
    PaymentVO getPaymentByTransactionId(String transactionId) throws Exception;

    /**
     * reservationId로 결제 정보를 조회합니다.
     */
    PaymentVO getPaymentByReservationId(Long reservationId) throws Exception;

    /**
     * 결제 ID와 상태로 결제 상태를 업데이트합니다.
     * @param paymentId 결제 ID
     * @param status 새로운 상태 ("REFUNDED" 등)
     * @return 업데이트 성공 여부
     */
    boolean updatePaymentStatus(Long paymentId, String status);

    /**
     * 결제 완료 후 최종 처리를 수행합니다.
     */
    boolean completePayment(String paymentId) throws Exception;

    /**
     * 새로운 환불 메서드 추가
     */
    void refundPayment(Long paymentId) throws Exception;

    /**
     * paymentId로 결제 정보를 삭제합니다.
     * @param paymentId 삭제할 결제 ID
     */
    void deletePayment(Long paymentId);
    public PaymentVO getPaymentById(String paymentId);
    public void updatePaymentStatus(String paymentId, String status);
}
