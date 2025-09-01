package com.spring.teamProject.vo;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 정산 내역 테이블 (settlements)과 매핑되는 JPA 엔티티 클래스입니다.
 * DAO 패턴에서도 사용 가능하도록 단순한 VO 형태로 구성했습니다.
 * Lombok을 사용하여 Getter, Setter, NoArgsConstructor를 자동으로 생성합니다.
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "settlements")
public class SettlementsEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "settlement_id")
    private Long settlementId;

    @Column(name = "store_id", nullable = false)
    private Long storeId; // 매장 ID (단순 외래키)

    @Column(name = "settlement_period_start", nullable = false)
    private LocalDate settlementPeriodStart;

    @Column(name = "settlement_period_end", nullable = false)
    private LocalDate settlementPeriodEnd;

    @Column(name = "total_revenue_amount", precision = 12, scale = 2, nullable = false)
    private BigDecimal totalRevenueAmount;

    @Column(name = "total_commission_amount", precision = 12, scale = 2, nullable = false)
    private BigDecimal totalCommissionAmount;

    @Column(name = "final_settlement_amount", precision = 12, scale = 2, nullable = false)
    private BigDecimal finalSettlementAmount;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private SettlementStatus status;

    @Column(name = "settled_at")
    private LocalDateTime settledAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}