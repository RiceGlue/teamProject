package com.spring.teamProject.service;

import java.time.LocalDate;
import java.util.List;

import com.spring.teamProject.vo.SettlementsEntity;

public interface SettlementService {

    /**
     * 특정 점주 ID로 모든 매장의 정산 내역을 조회합니다.
     * @param ownerId 점주의 고유 ID
     * @return 해당 점주가 소유한 모든 매장의 정산 내역 리스트
     */
    List<SettlementsEntity> getSettlementHistoryByOwnerId(long ownerId);

    /**
     * 지정된 기간 동안의 매장 정산 금액을 계산하고 저장합니다.
     * 이 메서드는 스케줄러 등을 통해 주기적으로 실행됩니다.
     */
    void calculateAndSaveSettlement(long storeId, String startDate, String endDate);

    /**
     * 특정 점주의 정산 내역을 기간별로 조회합니다.
     * @param ownerId 점주 고유 ID
     * @param startDate 조회 시작일
     * @param endDate 조회 종료일
     * @return 정산 내역 리스트
     */
    List<SettlementsEntity> getSettlementHistoryByOwnerIdAndDateRange(long ownerId, LocalDate startDate, LocalDate endDate);

    /**
     * 특정 정산 데이터를 'COMPLETED' 상태로 변경하고 정산일을 기록합니다.
     * @param settlementId 정산 ID
     */
    void approveSettlement(long settlementId);

}