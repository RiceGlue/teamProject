package com.spring.teamProject.vo;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 위시리스트 테이블 (wishlists)과 매핑되는 JPA 엔티티 클래스입니다.
 * DAO 패턴에서도 사용 가능하도록 단순한 VO 형태로 구성했습니다.
 * Lombok을 사용하여 Getter, Setter, NoArgsConstructor를 자동으로 생성합니다.
 */
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "wishlists", uniqueConstraints = {
    // (member_id, store_id) 조합이 유일함을 보장하는 UNIQUE KEY 설정
    @UniqueConstraint(columnNames = {"member_id", "store_id"})
})
public class WishlistEntity {

    /**
     * 위시리스트 고유 ID (기본 키)
     */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "wishlist_id")
    private Long wishlistId;

    /**
     * 회원 ID (members 테이블의 member_id)
     */
    @Column(name = "member_id", nullable = false)
    private Long memberId;

    /**
     * 가게 ID (stores 테이블의 store_id)
     */
    @Column(name = "store_id", nullable = false)
    private Long storeId;

    /**
     * 위시리스트에 추가한 날짜
     */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}
