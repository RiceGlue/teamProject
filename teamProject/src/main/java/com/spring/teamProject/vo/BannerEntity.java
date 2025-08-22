package com.spring.teamProject.vo;


import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Getter // 👈 이 두 어노테이션을 @Data 대신 사용해 보세요.
@Setter // 👈 @Data는 @Getter와 @Setter를 모두 포함합니다.
@Entity // 이 클래스가 JPA 엔티티임을 명시
@Table(name = "banners") // 매핑될 테이블 이름을 지정
public class BannerEntity {

    @Id // 기본 키(Primary Key)임을 명시
    @Column(name = "banner_id") // DB 컬럼명과 필드명 불일치 시 명시
    private String bannerId;

    @Column(name = "member_id")
    private Long memberId;

    @Column(name = "image_path") // 💡 image_path 컬럼과 imagePath 필드 매핑
    private String imagePath;

    @Column(name = "text")
    private String text;

    @Column(name = "price")
    private int price;

    @Column(name = "start_at") // 💡 start_at 컬럼과 startAt 필드 매핑
    private LocalDate startAt;

    @Column(name = "end_at") // 💡 end_at 컬럼과 endAt 필드 매핑
    private LocalDate endAt;

    @Column(name = "create_at")
    private LocalDateTime createAt;

    @Column(name = "update_at")
    private LocalDateTime updateAt;

    @Column(name = "status")
    private String status;

    @Column(name = "order_index")
    private int orderIndex;

    @Column(name = "click_count")
    private int clickCount;

    @Column(name = "view_count")
    private int viewCount;
}
