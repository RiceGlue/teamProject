package com.spring.teamProject.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.teamProject.jpa.dao.PromotionRepository;
import com.spring.teamProject.vo.PromotionEntity;

@Service
public class PromotionServiceImpl implements PromotionService {
    @Autowired
    private PromotionRepository promotionRepository;

    @Override
    public PromotionEntity getPromotionById(Long promotionId) {
        // JPA 레포지토리를 사용하여 ID로 프로모션 조회
        return promotionRepository.findByPromotionId(promotionId);
    }
}
