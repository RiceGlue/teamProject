package com.spring.teamProject.jpa.dao; // 💡 dao 패키지로 이동
import java.time.LocalDate;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.spring.teamProject.vo.BannerEntity;

@Repository
public interface BannerRepository extends JpaRepository<BannerEntity, String> {

    /**
     * [기존] 현재 날짜에 활성화된 배너 목록을 조회합니다. (메인 페이지용)
     * - 상태가 'active'이고, 시작일과 종료일 사이에 있는 배너를 조회하고, orderIndex 순으로 정렬
     */
    List<BannerEntity> findByStatusAndStartAtLessThanEqualAndEndAtGreaterThanEqualOrderByOrderIndexAsc(String status, LocalDate startAt, LocalDate endAt);

    /**
     * ✨ --- [신규] 현재 게시 중인 배너 목록을 페이징하여 조회합니다. (관리자용) --- ✨
     * - orderIndex 오름차순, 같을 경우엔 최종 수정일 내림차순으로 정렬하여 순서를 보장합니다.
     */
    @Query("SELECT b FROM BannerEntity b WHERE b.status = 'active' AND b.startAt <= :currentDate AND b.endAt >= :currentDate ORDER BY b.orderIndex ASC, b.updateAt DESC")
    Page<BannerEntity> findActiveBannersForAdmin(@Param("currentDate") LocalDate currentDate, Pageable pageable);

    /**
     * ✨ --- [신규] 게시 예정인 배너 목록을 페이징하여 조회합니다. (관리자용) --- ✨
     * - 시작일이 빠른 순서대로 정렬합니다.
     */
    @Query("SELECT b FROM BannerEntity b WHERE b.startAt > :currentDate ORDER BY b.startAt ASC")
    Page<BannerEntity> findScheduledBanners(@Param("currentDate") LocalDate currentDate, Pageable pageable);

    /**
     * ✨ --- [신규] 게시 종료된 배너 목록을 페이징하여 조회합니다. (관리자용) --- ✨
     * - 종료일이 최신인 순서대로 정렬합니다.
     */
    @Query("SELECT b FROM BannerEntity b WHERE b.endAt < :currentDate ORDER BY b.endAt DESC")
    Page<BannerEntity> findEndedBanners(@Param("currentDate") LocalDate currentDate, Pageable pageable);
}