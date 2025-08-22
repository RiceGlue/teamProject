package com.spring.teamProject.jpa.dao; // 💡 dao 패키지로 이동
import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.spring.teamProject.vo.BannerEntity;

@Repository
public interface BannerRepository extends JpaRepository<BannerEntity, String> {

    // 💡 JPA가 자동으로 쿼리를 생성하는 메소드
    // 상태가 'active'이고, 시작일과 종료일 사이에 있는 배너를 조회하고, orderIndex 순으로 정렬
    List<BannerEntity> findByStatusAndStartAtLessThanEqualAndEndAtGreaterThanEqualOrderByOrderIndexAsc(String status, LocalDate startAt, LocalDate endAt);
}