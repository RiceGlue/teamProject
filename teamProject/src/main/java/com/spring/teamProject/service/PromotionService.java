package com.spring.teamProject.service;

import com.spring.teamProject.vo.PromotionEntity;
import java.util.List;

public interface PromotionService {

	PromotionEntity getPromotionById(Long promotionId);

    // ✨ --- [신규] 모든 프로모션 목록을 조회하는 메소드 --- ✨
    List<PromotionEntity> getAllPromotions();
	
}
