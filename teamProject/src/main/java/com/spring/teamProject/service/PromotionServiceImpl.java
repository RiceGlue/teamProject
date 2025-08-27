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
}
