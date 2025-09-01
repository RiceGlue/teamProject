package com.spring.teamProject.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.teamProject.dao.PaymentDAO;
import com.spring.teamProject.dao.StoreDAO;
import com.spring.teamProject.jpa.dao.SettlementsRepository;
import com.spring.teamProject.vo.PaymentVO;
import com.spring.teamProject.vo.SettlementStatus;
import com.spring.teamProject.vo.SettlementsEntity;
import com.spring.teamProject.vo.StoreVO;

@Service
@Transactional(readOnly = true)
public class SettlementServiceImpl implements SettlementService {

    private final SettlementsRepository settlementsRepository;
    private final StoreDAO storeDAO;
    private final PaymentDAO paymentDAO;

    // 생성자 주입
    public SettlementServiceImpl(SettlementsRepository settlementsRepository, StoreDAO storeDAO, PaymentDAO paymentDAO) {
        this.settlementsRepository = settlementsRepository;
        this.storeDAO = storeDAO;
        this.paymentDAO = paymentDAO;
    }

    @Override
    public List<SettlementsEntity> getSettlementHistoryByOwnerId(long ownerId) {
        // 이 메서드는 전체 기간 조회용으로 남겨둡니다.
        List<StoreVO> stores = storeDAO.selectStoresByOwnerId(ownerId);
        List<Long> storeIds = stores.stream()
                                    .map(StoreVO::getStoreId)
                                    .collect(Collectors.toList());

        if (storeIds.isEmpty()) {
            return List.of();
        }

        return settlementsRepository.findByStoreIdIn(storeIds);
    }

    @Override
    public List<SettlementsEntity> getSettlementHistoryByOwnerIdAndDateRange(long ownerId, LocalDate startDate, LocalDate endDate) {
        // 1. MyBatis DAO를 사용하여 점주의 모든 매장 VO를 조회합니다.
        List<StoreVO> stores = storeDAO.selectStoresByOwnerId(ownerId);

        // 2. 매장 VO 목록에서 매장 ID만 추출합니다.
        List<Long> storeIds = stores.stream()
                                    .map(StoreVO::getStoreId)
                                    .collect(Collectors.toList());

        if (storeIds.isEmpty()) {
            return List.of(); // 매장이 없으면 빈 리스트 반환
        }

        // 3. 날짜를 LocalDateTime으로 변환하여 범위를 설정합니다.
        // 시작일은 그날 00:00:00부터, 종료일은 23:59:59까지 포함하도록 설정합니다.
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(23, 59, 59);

        // 4. JPA Repository를 사용하여 매장 ID 리스트와 기간에 해당하는 정산 내역을 조회합니다.
        return settlementsRepository.findByStoreIdInAndCreatedAtBetween(storeIds, startDateTime, endDateTime);
    }

    @Override
    @Transactional
    public void calculateAndSaveSettlement(long storeId, String startDate, String endDate) {
        try {
            List<PaymentVO> payments = paymentDAO.selectPaymentsByStoreIdAndDateRange(storeId, startDate, endDate);

            if (payments.isEmpty()) {
                return;
            }

            Long totalRevenueLong = payments.stream()
                                        .map(PaymentVO::getAmount)
                                        .reduce(0L, Long::sum);

            BigDecimal totalCommission = payments.stream()
                                                .map(PaymentVO::getCommissionFee)
                                                .reduce(BigDecimal.ZERO, BigDecimal::add);

            BigDecimal totalRevenue = new BigDecimal(totalRevenueLong);
            BigDecimal finalSettlementAmount = totalRevenue.subtract(totalCommission);

            SettlementsEntity settlement = new SettlementsEntity();
            settlement.setStoreId(storeId);
            settlement.setSettlementPeriodStart(LocalDate.parse(startDate));
            settlement.setSettlementPeriodEnd(LocalDate.parse(endDate));
            settlement.setTotalRevenueAmount(totalRevenue);
            settlement.setTotalCommissionAmount(totalCommission);
            settlement.setFinalSettlementAmount(finalSettlementAmount);
            settlement.setStatus(SettlementStatus.PENDING);

            settlementsRepository.save(settlement);

        } catch (Exception e) {
            throw new RuntimeException("정산 데이터 생성 중 오류가 발생했습니다.", e);
        }
    }
}