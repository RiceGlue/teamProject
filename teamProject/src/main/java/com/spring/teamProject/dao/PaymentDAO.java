// src/main/java/com/spring/teamProject/dao/PaymentDAO.java

package com.spring.teamProject.dao;

import com.spring.teamProject.vo.PaymentVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

@Mapper
@Repository
public interface PaymentDAO {
    void insertPayment(PaymentVO payment);
    PaymentVO selectByTransactionId(String transactionId);
    void updatePaymentStatus(@Param("paymentId") Long paymentId, @Param("status") String status);
}