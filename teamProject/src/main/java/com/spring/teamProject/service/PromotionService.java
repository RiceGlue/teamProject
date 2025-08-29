package com.spring.teamProject.service;

import com.spring.teamProject.vo.PromotionEntity;
import java.util.List;

public interface PromotionService {

	PromotionEntity getPromotionById(Long promotionId);

    // ✨ --- [신규] 모든 프로모션 목록을 조회하는 메소드 --- ✨
    List<PromotionEntity> getAllPromotions();

    /**
     * 프로모션 정보를 저장하거나 수정합니다.
     * @param promotion 저장할 PromotionEntity 객체
     */
    void savePromotion(PromotionEntity promotion);

    /**
     * ID를 기준으로 프로모션을 삭제합니다.
     * @param promotionId 삭제할 프로모션의 ID
     */
    void deletePromotion(Long promotionId);

}
