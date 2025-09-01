package com.spring.teamProject.jpa.dao;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.spring.teamProject.vo.SettlementsEntity;

@Repository
public interface SettlementsRepository extends JpaRepository<SettlementsEntity, Long> {

    /**
     * 매장 ID 리스트를 받아 해당 매장들의 모든 정산 내역을 조회합니다.
     * @param storeIds 조회할 매장 ID 리스트
     * @return 정산 내역 리스트
     */
    List<SettlementsEntity> findByStoreIdIn(List<Long> storeIds);

    /**
     * 특정 매장 ID 리스트와 생성일(createdAt) 기간에 해당하는 정산 데이터를 조회합니다.
     * @param storeIds 매장 ID 리스트
     * @param startDate 조회 시작 시간
     * @param endDate 조회 종료 시간
     * @return 정산 데이터 리스트
     */
    List<SettlementsEntity> findByStoreIdInAndCreatedAtBetween(List<Long> storeIds, LocalDateTime startDate, LocalDateTime endDate);
}