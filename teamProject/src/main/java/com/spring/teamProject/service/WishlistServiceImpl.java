package com.spring.teamProject.service;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.teamProject.jpa.dao.WishlistRepository;
import com.spring.teamProject.vo.WishlistEntity;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class WishlistServiceImpl implements WishlistService {

    private final WishlistRepository wishlistRepository;

    @Override
    public List<WishlistEntity> getWishlistByMemberId(Long memberId) {
        return wishlistRepository.findByMemberId(memberId);
    }

    @Override
    @Transactional
    public void toggleWishlist(Long memberId, Long storeId) {
        Optional<WishlistEntity> existingWishlist = wishlistRepository.findByMemberIdAndStoreId(memberId, storeId);

        if (existingWishlist.isPresent()) {
            // 이미 찜한 상태라면, 삭제합니다.
            wishlistRepository.delete(existingWishlist.get());
        } else {
            // 찜하지 않은 상태라면, 새로 추가합니다.
            WishlistEntity wishlist = new WishlistEntity();
            wishlist.setMemberId(memberId);
            wishlist.setStoreId(storeId);
            wishlistRepository.save(wishlist);
        }
    }

    @Override
    public boolean isWishlisted(Long memberId, Long storeId) {
        return wishlistRepository.findByMemberIdAndStoreId(memberId, storeId).isPresent();
    }

 // 💡 위시리스트 추가 메소드 구현
    @Override
    @Transactional
    public void addWishlist(Long memberId, Long storeId) {
        // 이미 찜한 상태인지 확인
        if (wishlistRepository.findByMemberIdAndStoreId(memberId, storeId).isPresent()) {
            throw new IllegalArgumentException("Already wishlisted.");
        }
        WishlistEntity wishlist = new WishlistEntity();
        wishlist.setMemberId(memberId);
        wishlist.setStoreId(storeId);
        wishlistRepository.save(wishlist);
    }

    // 💡 위시리스트 삭제 메소드 구현
    @Override
    @Transactional
    public void removeWishlist(Long memberId, Long storeId) {
        Optional<WishlistEntity> existingWishlist = wishlistRepository.findByMemberIdAndStoreId(memberId, storeId);
        if (existingWishlist.isPresent()) {
            wishlistRepository.delete(existingWishlist.get());
        } else {
            throw new IllegalArgumentException("Wishlist item not found.");
        }
    }
}
