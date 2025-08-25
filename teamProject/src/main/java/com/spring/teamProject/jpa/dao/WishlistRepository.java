package com.spring.teamProject.jpa.dao;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.spring.teamProject.vo.WishlistEntity;

@Repository
public interface WishlistRepository extends JpaRepository<WishlistEntity, Long> {

    /**
     * 특정 회원의 위시리스트 목록을 조회합니다.
     * @param memberId 회원 ID
     * @return 위시리스트 엔티티 리스트
     */
    List<WishlistEntity> findByMemberId(Long memberId);

    /**
     * 특정 회원과 가게 조합으로 위시리스트 항목이 존재하는지 확인합니다.
     * @param memberId 회원 ID
     * @param storeId 가게 ID
     * @return Optional<WishlistEntity>
     */
    Optional<WishlistEntity> findByMemberIdAndStoreId(Long memberId, Long storeId);
}
