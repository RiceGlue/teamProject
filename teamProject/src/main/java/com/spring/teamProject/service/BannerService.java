package com.spring.teamProject.service;

import com.spring.teamProject.vo.BannerEntity;
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
    
    // ✨ --- [신규] 배너 ID로 배너 정보와 관련 파일을 모두 삭제하는 메소드 --- ✨
    void deleteBanner(String bannerId);
}
