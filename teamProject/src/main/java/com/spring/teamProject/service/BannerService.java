package com.spring.teamProject.service;

import com.spring.teamProject.vo.BannerEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

/**
 * 배너 관련 비즈니스 로직을 정의하는 인터페이스입니다.
 */
public interface BannerService {
    
    /**
     * 현재 날짜에 활성화된 배너 목록을 조회합니다. (메인 페이지용)
     */
    List<BannerEntity> getActiveBanners();

    /**
     * PC와 모바일 이미지를 함께 받아 새로운 배너를 저장합니다.
     * @param banner 배너 정보가 담긴 엔티티
     * @param pcImageFile 업로드된 PC용 이미지 파일 (필수)
     * @param mobileImageFile 업로드된 모바일용 이미지 파일 (선택)
     */
    void saveBanner(BannerEntity banner, MultipartFile pcImageFile, MultipartFile mobileImageFile);
    
    /**
     * 배너 ID로 특정 배너 정보를 조회합니다.
     * @param bannerId 조회할 배너의 ID
     * @return 조회된 BannerEntity, 없으면 null
     */
    BannerEntity getBannerById(String bannerId);

    /**
     * 기존 배너 정보를 수정합니다.
     * @param banner 수정할 정보가 담긴 엔티티
     * @param pcImageFile 새로 업로드된 PC용 이미지 파일 (선택)
     * @param mobileImageFile 새로 업로드된 모바일용 이미지 파일 (선택)
     */
    void updateBanner(BannerEntity banner, MultipartFile pcImageFile, MultipartFile mobileImageFile);
    
    /**
     * 배너 ID로 배너 정보와 관련 파일을 모두 삭제합니다.
     * @param bannerId 삭제할 배너의 ID
     */
    void deleteBanner(String bannerId);

    /**
     * 현재 게시 중인 배너 목록을 페이징하여 조회합니다. (관리자용)
     * @param pageable 페이징 정보
     * @return 페이징된 배너 목록
     */
    Page<BannerEntity> getActiveBannersForAdmin(Pageable pageable);

    /**
     * 게시 예정인 배너 목록을 페이징하여 조회합니다. (관리자용)
     * @param pageable 페이징 정보
     * @return 페이징된 배너 목록
     */
    Page<BannerEntity> getScheduledBanners(Pageable pageable);

    /**
     * 게시 종료된 배너 목록을 페이징하여 조회합니다. (관리자용)
     * @param pageable 페이징 정보
     * @return 페이징된 배너 목록
     */
    Page<BannerEntity> getEndedBanners(Pageable pageable);

    /**
     * 순서 변경을 위해 '게시 중'인 모든 배너 목록을 조회합니다. (페이징 없음)
     * @return 활성화된 모든 배너 목록
     */
    List<BannerEntity> getActiveBannersForOrdering();

    /**
     * 변경된 배너 순서를 DB에 일괄 업데이트합니다.
     * @param bannerIds 순서가 변경된 배너 ID 목록
     */
    void updateBannerOrder(List<String> bannerIds);

    /**
     * 관리자가 업로드한 기본 배너 이미지를 저장합니다.
     * @param defaultImageFile 업로드된 기본 배너 이미지 파일
     */
    void saveDefaultBanner(MultipartFile defaultImageFile);
}