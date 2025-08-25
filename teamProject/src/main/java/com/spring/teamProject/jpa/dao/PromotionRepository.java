package com.spring.teamProject.jpa.dao;

import com.spring.teamProject.vo.PromotionEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PromotionRepository extends JpaRepository<PromotionEntity, Long> {

    // JPA가 자동으로 쿼리를 생성하여 promotionId로 프로모션을 찾는 메서드
    PromotionEntity findByPromotionId(Long promotionId);
}
