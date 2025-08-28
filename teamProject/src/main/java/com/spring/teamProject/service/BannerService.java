package com.spring.teamProject.service;

import com.spring.teamProject.vo.BannerEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;
import java.time.LocalDate;
import java.util.List;

public interface BannerService {
    
    /**
     * 현재 날짜에 활성화된 배너 목록을 조회합니다. (메인 페이지용)
     */
    List<BannerEntity> getActiveBanners();

    /**
     * 모든 배너 목록을 조회합니다. (관리자 페이지용)
     */
    List<BannerEntity> getAllBanners();
    
    /**
     * PC와 모바일 이미지를 함께 받아 새로운 배너를 저장합니다.
     * @param banner 배너 정보가 담긴 엔티티
     * @param pcImageFile 업로드된 PC용 이미지 파일 (필수)
     * @param mobileImageFile 업로드된 모바일용 이미지 파일 (선택)
     */
    void saveBanner(BannerEntity banner, MultipartFile pcImageFile, MultipartFile mobileImageFile);
    
    // 배너 ID로 특정 배너 정보를 조회하는 메소드
    BannerEntity getBannerById(String bannerId);

    // 기존 배너 정보를 수정하는 메소드
    void updateBanner(BannerEntity banner, MultipartFile pcImageFile, MultipartFile mobileImageFile);
    
    //  배너 ID로 배너 정보와 관련 파일을 모두 삭제하는 메소드
    void deleteBanner(String bannerId);

    // 현재 게시 중인 배너 목록을 페이징하여 조회합니다. (관리자용)
    Page<BannerEntity> getActiveBannersForAdmin(Pageable pageable);

    // 게시 예정인 배너 목록을 페이징하여 조회합니다. (관리자용)
    Page<BannerEntity> getScheduledBanners(Pageable pageable);

    // 게시 종료된 배너 목록을 페이징하여 조회합니다. (관리자용)
    Page<BannerEntity> getEndedBanners(Pageable pageable);

    /**
     * ✨ --- [신규] 순서 변경을 위해 '게시 중'인 모든 배너 목록을 조회합니다. (페이징 없음) --- ✨
     */
    List<BannerEntity> getActiveBannersForOrdering();

    /**
     * ✨ --- [신규] 변경된 배너 순서를 DB에 일괄 업데이트합니다. --- ✨
     * @param bannerIds 정렬된 순서의 배너 ID 목록
     */
    void updateBannerOrder(List<String> bannerIds);
}
