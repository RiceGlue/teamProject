package com.spring.teamProject.service;

import java.util.List;

import com.spring.teamProject.vo.WishlistEntity;

public interface WishlistService {

    /**
     * 특정 회원의 위시리스트 목록을 조회합니다.
     * @param memberId 회원 ID
     * @return 위시리스트 엔티티 리스트
     */
    List<WishlistEntity> getWishlistByMemberId(Long memberId);

    /**
     * 위시리스트에 가게를 추가하거나 이미 있으면 삭제합니다.
     * @param memberId 회원 ID
     * @param storeId 가게 ID
     */
    void toggleWishlist(Long memberId, Long storeId);

    /**
     * 특정 가게가 위시리스트에 추가되었는지 확인합니다.
     * @param memberId 회원 ID
     * @param storeId 가게 ID
     * @return 위시리스트에 존재하면 true, 아니면 false
     */
    boolean isWishlisted(Long memberId, Long storeId);

 // 💡 위시리스트 추가와 삭제를 위한 메소드 추가
    void addWishlist(Long memberId, Long storeId);
    void removeWishlist(Long memberId, Long storeId);
}
