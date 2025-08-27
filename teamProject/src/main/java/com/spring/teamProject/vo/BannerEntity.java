package com.spring.teamProject.vo;

import java.time.LocalDate;
import java.time.LocalDateTime;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter // ?? 이 두 어노테이션을 @Data 대신 사용해 보세요.
@Setter // ?? @Data는 @Getter와 @Setter를 모두 포함합니다.
@Entity // 이 클래스가 JPA 엔티티임을 명시
@Table(name = "banners") // 매핑될 테이블 이름을 지정
public class BannerEntity {

    @Id
    @Column(name = "banner_id")
    private String bannerId;

    @Column(name = "member_id")
    private Long memberId;

    @Column(name = "image_path") // ?? image_path 컬럼과 imagePath 필드 매핑
    private String imagePath;

    @Column(name = "mobile_image_path")
    private String mobileImagePath;

    @Column(name = "text")
    private String text;

    @Column(name = "price")
    private int price;

    @Column(name = "start_at") // ?? start_at 컬럼과 startAt 필드 매핑
    private LocalDate startAt;

    @Column(name = "end_at") // ?? end_at 컬럼과 endAt 필드 매핑
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

    @Column(name = "promotion_id")
    private Long promotionId;

    // ? --- [수정] DB의 link_url 컬럼과 매핑될 필드를 추가합니다. --- ?
    @Column(name = "link_url")
    private String linkUrl;
    
    // Lombok의 @Setter가 모든 필드에 대한 set 메소드를 자동으로 생성해주므로,
    // 수동으로 작성했던 불필요한 메소드는 제거합니다.
}
