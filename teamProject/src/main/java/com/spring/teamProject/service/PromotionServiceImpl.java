package com.spring.teamProject.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.teamProject.jpa.dao.PromotionRepository;
import com.spring.teamProject.vo.PromotionEntity;
import java.util.List;

@Service
public class PromotionServiceImpl implements PromotionService {
    @Autowired
    private PromotionRepository promotionRepository;

    @Override
    public PromotionEntity getPromotionById(Long promotionId) {
        // JPA 레포지토리를 사용하여 ID로 프로모션 조회
        return promotionRepository.findByPromotionId(promotionId);
    }

    // ✨ --- [신규] 모든 프로모션 목록을 조회하는 로직 구현 --- ✨
    @Override
    public List<PromotionEntity> getAllPromotions() {
        // JPA Repository의 findAll() 메소드를 사용하여 모든 프로모션을 가져옵니다.
        return promotionRepository.findAll();
    }

    /**
     * 프로모션 정보를 저장하거나 수정합니다.
     * save() 메소드는 ID가 존재하면 수정, 존재하지 않으면 새로 저장합니다.
     * @param promotion 저장할 PromotionEntity 객체
     */
    @Override
    public void savePromotion(PromotionEntity promotion) {
        promotionRepository.save(promotion);
    }

    /**
     * ID를 기준으로 프로모션을 삭제합니다.
     * @param promotionId 삭제할 프로모션의 ID
     */
    @Override
    public void deletePromotion(Long promotionId) {
        promotionRepository.deleteById(promotionId);
    }
}
