// src/main/java/com/spring/teamProject/service/PaymentServiceImpl.java

package com.spring.teamProject.service;

import com.spring.teamProject.dao.PaymentDAO;
import com.spring.teamProject.dao.ReservationDAO;
import com.spring.teamProject.vo.PaymentVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@Transactional
public class PaymentServiceImpl implements PaymentService {

    @Autowired
    private PaymentDAO paymentDAO;

    @Autowired
    private ReservationDAO reservationDAO; // 예약 상태 업데이트를 위해 ReservationDAO 주입

    @Override
    public void addPayment(PaymentVO payment) throws Exception {
        paymentDAO.insertPayment(payment);
    }

    @Override
    public PaymentVO getPaymentByTransactionId(String transactionId) throws Exception {
        return paymentDAO.selectByTransactionId(transactionId);
    }

    @Override
    public void updatePaymentStatus(PaymentVO payment) throws Exception {
        // 결제 상태 업데이트 (paidAt은 이전에 Controller에서 설정)
        paymentDAO.updatePaymentStatus(payment.getPaymentId(), payment.getStatus());

        // 결제 상태에 따라 예약 상태도 업데이트합니다.
        if ("COMPLETED".equals(payment.getStatus())) {
            reservationDAO.updateReservationStatus(payment.getReservationId(), "CONFIRMED");
        } else if ("FAILED".equals(payment.getStatus()) || "REFUNDED".equals(payment.getStatus())) {
            reservationDAO.updateReservationStatus(payment.getReservationId(), payment.getStatus());
        }
    }
}