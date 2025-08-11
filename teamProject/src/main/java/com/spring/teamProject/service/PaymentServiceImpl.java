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
    private ReservationDAO reservationDAO;

    @Override
    public void addPayment(PaymentVO payment) throws Exception {
        paymentDAO.insertPayment(payment);
    }

    @Override
    public PaymentVO getPaymentByTransactionId(String transactionId) throws Exception {
        return paymentDAO.selectByTransactionId(transactionId);
    }

    // ⭐ 추가해야 할 메서드 구현
    @Override
    public PaymentVO getPaymentByReservationId(Long reservationId) throws Exception {
        return paymentDAO.selectByReservationId(reservationId);
    }

    @Override
    public void updatePaymentStatus(PaymentVO payment) throws Exception {
        paymentDAO.updatePaymentStatus(payment.getPaymentId(), payment.getStatus());

        if ("COMPLETED".equals(payment.getStatus())) {
            reservationDAO.updateReservationStatus(payment.getReservationId(), "CONFIRMED");
        } else if ("CANCELED".equals(payment.getStatus()) || "FAILED".equals(payment.getStatus()) || "REFUNDED".equals(payment.getStatus())) {
            reservationDAO.updateReservationStatus(payment.getReservationId(), "CANCELLED");
        }
    }
}