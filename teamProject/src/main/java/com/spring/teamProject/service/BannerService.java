package com.spring.teamProject.service;

import java.time.LocalDate;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.teamProject.jpa.dao.BannerRepository;
import com.spring.teamProject.vo.BannerEntity; // 💡 올바른 클래스 임포트

@Service
public class BannerService {

    private final BannerRepository bannerRepository;

    @Autowired
    public BannerService(BannerRepository bannerRepository) {
        this.bannerRepository = bannerRepository;
    }

    /**
     * 현재 활성화된 배너 목록을 조회
     */
    public List<BannerEntity> getActiveBanners() {
        return bannerRepository.findByStatusAndStartAtLessThanEqualAndEndAtGreaterThanEqualOrderByOrderIndexAsc("active", LocalDate.now(), LocalDate.now());
    }
}