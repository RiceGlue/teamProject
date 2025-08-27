package com.spring.teamProject.service;

import com.spring.teamProject.jpa.dao.BannerRepository;
import com.spring.teamProject.vo.BannerEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
public class BannerServiceImpl implements BannerService {

    @Autowired
    private BannerRepository bannerRepository;
    
    @Autowired
    private FtpService ftpService;

    @Value("${file.upload-dir}")
    private String tempDir;

    // 기존 메인 페이지용 기능
    @Override
    public List<BannerEntity> getActiveBanners() {
        return bannerRepository.findByStatusAndStartAtLessThanEqualAndEndAtGreaterThanEqualOrderByOrderIndexAsc("active", LocalDate.now(), LocalDate.now());
    }

    // 관리자 페이지용 기능
    @Override
    public List<BannerEntity> getAllBanners() {
        return bannerRepository.findAll();
    }

    @Override
    @Transactional
    public void saveBanner(BannerEntity banner, MultipartFile imageFile) {
        if (imageFile != null && !imageFile.isEmpty()) {
            String savedFilename = uploadBannerImageToFtp(imageFile);
            banner.setImagePath(savedFilename);
        }
        
        banner.setBannerId(UUID.randomUUID().toString());
        banner.setMemberId(1L); // TODO: 현재 로그인한 관리자 ID로 설정해야 함

        bannerRepository.save(banner);
    }

    private String uploadBannerImageToFtp(MultipartFile multipartFile) {
        String originalFilename = multipartFile.getOriginalFilename();
        String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        String savedFilename = UUID.randomUUID().toString() + extension;
        File tempLocalFile = new File(tempDir + savedFilename);

        try {
            multipartFile.transferTo(tempLocalFile);
            boolean success = ftpService.uploadFile(tempLocalFile, "banners", savedFilename);
            if (!success) {
                throw new RuntimeException("FTP 서버에 배너 이미지 저장 실패");
            }
            return savedFilename;
        } catch (IOException e) {
            throw new RuntimeException("배너 이미지 파일 처리 중 오류 발생", e);
        } finally {
            if (tempLocalFile.exists()) {
                tempLocalFile.delete();
            }
        }
    }
}
