package com.spring.teamProject.jpa.dao;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.spring.teamProject.vo.CommissionRateEntity;

@Repository
public interface CommissionRateRepository extends JpaRepository<CommissionRateEntity, Long> {

    // 현재 시점에 유효한 최신 수수료율을 조회
    @Query("SELECT cr FROM CommissionRateEntity cr WHERE cr.effectiveStartDate <= :now ORDER BY cr.effectiveStartDate DESC")
    Optional<CommissionRateEntity> findCurrentRate(@Param("now") LocalDateTime now);
}