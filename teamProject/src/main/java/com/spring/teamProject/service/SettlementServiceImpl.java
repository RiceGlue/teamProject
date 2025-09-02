package com.spring.teamProject.service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

    private static final Logger logger = LoggerFactory.getLogger(SettlementServiceImpl.class);

    private final SettlementsRepository settlementsRepository;
    private final StoreDAO storeDAO;
    private final PaymentDAO paymentDAO;
    private final CommissionRateService commissionRateService; // ✨ 새롭게 추가된 의존성

    // ✨ 생성자 수정: CommissionRateService를 주입받도록 변경
    public SettlementServiceImpl(SettlementsRepository settlementsRepository, StoreDAO storeDAO, PaymentDAO paymentDAO, CommissionRateService commissionRateService) {
        this.settlementsRepository = settlementsRepository;
        this.storeDAO = storeDAO;
        this.paymentDAO = paymentDAO;
        this.commissionRateService = commissionRateService;
    }

    @Override
    public List<SettlementsEntity> getSettlementHistoryByOwnerId(long ownerId) {
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
        List<StoreVO> stores = storeDAO.selectStoresByOwnerId(ownerId);
        List<Long> storeIds = stores.stream()
                                    .map(StoreVO::getStoreId)
                                    .collect(Collectors.toList());

        if (storeIds.isEmpty()) {
            return List.of();
        }

        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(23, 59, 59);

        return settlementsRepository.findByStoreIdInAndCreatedAtBetween(storeIds, startDateTime, endDateTime);
    }

    @Override
    @Transactional
    public void approveSettlement(long settlementId) {
        logger.info("정산 승인 요청. settlementId: {}", settlementId);

        SettlementsEntity settlement = settlementsRepository.findById(settlementId)
                .orElseThrow(() -> new IllegalArgumentException("정산 ID를 찾을 수 없습니다: " + settlementId));

        if (settlement.getStatus() == SettlementStatus.PENDING) {
            settlement.setStatus(SettlementStatus.COMPLETED);
            settlement.setSettledAt(LocalDateTime.now());
            settlementsRepository.save(settlement);
            logger.info("정산 ID {}가 성공적으로 승인되었습니다.", settlementId);
        } else {
            logger.warn("정산 ID {}는 이미 처리된 상태이므로 승인할 수 없습니다. 현재 상태: {}", settlementId, settlement.getStatus());
        }
    }

    @Override
    @Transactional
    public void calculateAndSaveSettlement(long storeId, String startDate, String endDate) {
        try {
            logger.info("매장 ID {}의 정산 데이터 계산 시작. 기간: {} ~ {}", storeId, startDate, endDate);

            List<PaymentVO> payments = paymentDAO.selectPaymentsByStoreIdAndDateRange(storeId, startDate, endDate);

            if (payments.isEmpty()) {
                logger.warn("매장 ID {}에 대해 해당 기간의 결제 데이터가 없습니다. 정산을 건너뜁니다.", storeId);
                return;
            }

            BigDecimal totalRevenue = payments.stream()
                                            .map(p -> new BigDecimal(p.getAmount()))
                                            .reduce(BigDecimal.ZERO, BigDecimal::add);

            // ✨ CommissionRateService에서 동적으로 수수료율을 가져옴
            //BigDecimal commissionRate = commissionRateService.getCommissionRate();
            BigDecimal commissionRate = commissionRateService.getCurrentCommissionRate();

            BigDecimal totalCommission = totalRevenue.multiply(commissionRate);

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
            logger.info("매장 ID {}의 정산 데이터가 성공적으로 생성되었습니다.", storeId);

        } catch (Exception e) {
            logger.error("매장 ID {}의 정산 데이터 생성 중 오류 발생.", storeId, e);
            throw new RuntimeException("정산 데이터 생성 중 오류가 발생했습니다.", e);
        }
    }
}