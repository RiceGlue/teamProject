package com.spring.teamProject.service;

import com.spring.teamProject.vo.BannerEntity;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface BannerService {

    /**
     * 현재 활성화된 배너 목록을 조회 (사용자용)
     */
    List<BannerEntity> getActiveBanners();

    /**
     * 모든 배너 목록을 조회 (관리자용)
     */
    List<BannerEntity> getAllBanners();

    /**
     * 배너 정보와 이미지 파일을 저장
     */
    void saveBanner(BannerEntity banner, MultipartFile imageFile);
}
