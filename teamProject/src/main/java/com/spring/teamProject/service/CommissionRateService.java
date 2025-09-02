package com.spring.teamProject.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.teamProject.jpa.dao.CommissionRateRepository;
import com.spring.teamProject.vo.CommissionRateEntity;

@Service
@Transactional
public class CommissionRateService {

 private final CommissionRateRepository commissionRateRepository;

 @Autowired
 public CommissionRateService(CommissionRateRepository commissionRateRepository) {
     this.commissionRateRepository = commissionRateRepository;
 }

 // 현재 수수료율을 조회
 @Transactional(readOnly = true)
 public BigDecimal getCurrentCommissionRate() {
     return commissionRateRepository.findCurrentRate(LocalDateTime.now())
             .map(CommissionRateEntity::getRate)
             .orElse(new BigDecimal("0.05")); // 기본값 5%
 }

 // 새로운 수수료율을 저장
 public void updateCommissionRate(BigDecimal newRate) {
     CommissionRateEntity newCommission = new CommissionRateEntity();
     newCommission.setRate(newRate);
     newCommission.setEffectiveStartDate(LocalDateTime.now());
     newCommission.setCreatedAt(LocalDateTime.now());
     commissionRateRepository.save(newCommission);
 }
}