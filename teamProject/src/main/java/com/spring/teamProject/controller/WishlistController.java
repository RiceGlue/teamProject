package com.spring.teamProject.controller;

import com.spring.teamProject.service.WishlistService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/wishlist")
@RequiredArgsConstructor
public class WishlistController {

	private final WishlistService wishlistService;

	@PostMapping("/add")
	public ResponseEntity<String> addWishlist(@RequestParam("memberId") Long memberId, @RequestParam("storeId") Long storeId) {
		try {
			wishlistService.addWishlist(memberId, storeId);
			return ResponseEntity.ok("위시리스트에 추가되었습니다.");
		} catch (IllegalArgumentException e) {
			return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
		} catch (Exception e) {
			// 다른 예상치 못한 오류를 잡기 위한 로깅
			e.printStackTrace();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("위시리스트 추가 중 오류가 발생했습니다.");
		}
	}

	@DeleteMapping("/remove")
	public ResponseEntity<String> removeWishlist(@RequestParam("memberId") Long memberId, @RequestParam("storeId") Long storeId) {
		try {
			wishlistService.removeWishlist(memberId, storeId);
			return ResponseEntity.ok("위시리스트에서 삭제되었습니다.");
		} catch (IllegalArgumentException e) {
			return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
		} catch (Exception e) {
			e.printStackTrace();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("위시리스트 삭제 중 오류가 발생했습니다.");
		}
	}

	@GetMapping("/isWishlisted")
	public ResponseEntity<Boolean> isWishlisted(@RequestParam("memberId") Long memberId, @RequestParam("storeId") Long storeId) {
		boolean result = wishlistService.isWishlisted(memberId, storeId);
		return ResponseEntity.ok(result);
	}
}
