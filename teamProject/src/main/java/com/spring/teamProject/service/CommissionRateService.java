package com.spring.teamProject.service;

import java.math.BigDecimal;
import org.springframework.stereotype.Service;

@Service
public class CommissionRateService {

    // ✨ 임시로 고정된 수수료율을 저장하는 필드.
    // 실제로는 DB에서 값을 읽어오도록 구현해야 합니다.
    private static BigDecimal currentCommissionRate = new BigDecimal("0.05");

    /**
     * 현재 시스템의 수수료율을 반환합니다.
     * @return 현재 수수료율 (BigDecimal)
     */
    public BigDecimal getCommissionRate() {
        return currentCommissionRate;
    }

    /**
     * 시스템 수수료율을 업데이트합니다.
     * @param newRate 새로운 수수료율
     */
    public void updateCommissionRate(BigDecimal newRate) {
        // ✨ 이 메서드는 관리자 페이지에서 호출됩니다.
        // 실제로는 DB에 값을 업데이트하는 로직을 추가해야 합니다.
        if (newRate.compareTo(BigDecimal.ZERO) >= 0 && newRate.compareTo(BigDecimal.ONE) <= 0) {
            currentCommissionRate = newRate;
        } else {
            throw new IllegalArgumentException("수수료율은 0과 1 사이의 값이어야 합니다.");
        }
    }
}