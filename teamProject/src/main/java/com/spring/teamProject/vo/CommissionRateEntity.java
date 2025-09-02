package com.spring.teamProject.vo;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "commission_rates")
public class CommissionRateEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "rate", nullable = false, precision = 5, scale = 4)
    private BigDecimal rate; // 예: 0.0500 (5%)

    @Column(name = "effective_start_date", nullable = false)
    private LocalDateTime effectiveStartDate; // 적용 시작일

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    // 기본 생성자
    public CommissionRateEntity() {}

    // Getter and Setter
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public BigDecimal getRate() { return rate; }
    public void setRate(BigDecimal rate) { this.rate = rate; }
    public LocalDateTime getEffectiveStartDate() { return effectiveStartDate; }
    public void setEffectiveStartDate(LocalDateTime effectiveStartDate) { this.effectiveStartDate = effectiveStartDate; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}