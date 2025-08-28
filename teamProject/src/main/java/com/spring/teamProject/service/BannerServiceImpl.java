package com.spring.teamProject.service;

import com.spring.teamProject.jpa.dao.BannerRepository;
import com.spring.teamProject.vo.BannerEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import java.util.Optional;

@Service
public class BannerServiceImpl implements BannerService {

    @Autowired
    private BannerRepository bannerRepository;
    
    @Autowired
    private FtpService ftpService;

    @Value("${file.upload-dir}")
    private String tempDir;

    // 메인 페이지용 기능
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
    public void saveBanner(BannerEntity banner, MultipartFile pcImageFile, MultipartFile mobileImageFile) {
        // 1. PC용 이미지 처리 (필수)
        if (pcImageFile != null && !pcImageFile.isEmpty()) {
            String savedPcFileName = uploadAndValidateBannerImage(pcImageFile, 1200, 400);
            // 전체 가상 경로 저장 "경로주소" + savedPcFileName 으로 할경우 경로를 포함한 파일명으로 저장 가능합니다
            banner.setImagePath(savedPcFileName);
        } else {
            throw new IllegalArgumentException("PC용 배너 이미지는 필수입니다.");
        }

        // 2. 모바일용 이미지 처리 (선택)
        if (mobileImageFile != null && !mobileImageFile.isEmpty()) {
            String savedMobileFileName = uploadAndValidateBannerImage(mobileImageFile, 1200, 400);
            // 전체 가상 경로 저장 "경로주소" + savedPcFileName 으로 할경우 경로를 포함한 파일명으로 저장 가능합니다
            banner.setMobileImagePath(savedMobileFileName);
        }
        
        // 3. DB에 저장하기 전, 필수 값들을 설정합니다.
        banner.setBannerId(UUID.randomUUID().toString());
        banner.setMemberId(1L); // TODO: 현재 로그인한 관리자 ID로 설정해야 함

        // 4. JPA Repository를 통해 DB에 최종 저장합니다.
        bannerRepository.save(banner);
    }

    // ID로 배너를 조회하는 로직 구현
    @Override
    public BannerEntity getBannerById(String bannerId) {
        // JPA Repository의 findById 메소드는 Optional을 반환하므로, 없으면 null을 반환하도록 처리합니다.
        Optional<BannerEntity> banner = bannerRepository.findById(bannerId);
        return banner.orElse(null);
    }

    // 배너 수정 로직 구현
    @Override
    @Transactional
    public void updateBanner(BannerEntity banner, MultipartFile pcImageFile, MultipartFile mobileImageFile) {
        // 1. DB에서 수정할 기존 배너 정보를 가져옵니다.
        BannerEntity existingBanner = bannerRepository.findById(banner.getBannerId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 배너입니다. ID: " + banner.getBannerId()));

        // 2. 새로운 PC 이미지가 업로드되었으면, 기존 파일을 삭제하고 새 파일로 교체합니다.
        if (pcImageFile != null && !pcImageFile.isEmpty()) {
            // 2-1. 기존 파일이 있다면 FTP에서 삭제
            ftpService.deleteFile("banners", existingBanner.getImagePath());
            // 2-2. 새 파일 업로드 후 파일명 저장
            String savedPcFileName = uploadAndValidateBannerImage(pcImageFile, 1200, 400);
            existingBanner.setImagePath(savedPcFileName);
        }

        // 3. 새로운 모바일 이미지가 업로드되었으면, 기존 파일을 삭제하고 새 파일로 교체합니다.
        if (mobileImageFile != null && !mobileImageFile.isEmpty()) {
            ftpService.deleteFile("banners", existingBanner.getMobileImagePath());
            String savedMobileFileName = uploadAndValidateBannerImage(mobileImageFile, 1200, 400);
            existingBanner.setMobileImagePath(savedMobileFileName);
        }

        // 4. 폼에서 넘어온 나머지 정보들을 업데이트합니다.
        existingBanner.setText(banner.getText());
        existingBanner.setStartAt(banner.getStartAt());
        existingBanner.setEndAt(banner.getEndAt());
        existingBanner.setStatus(banner.getStatus());
        existingBanner.setPromotionId(banner.getPromotionId());
        existingBanner.setLinkUrl(banner.getLinkUrl());
        
        // 5. JPA의 변경 감지(Dirty Checking) 기능에 의해, 메소드가 끝나면 자동으로 DB에 UPDATE 쿼리가 실행됩니다.
        bannerRepository.save(existingBanner);
    }

    // ✨ --- [신규] 배너 삭제 로직 구현 --- ✨
    @Override
    @Transactional
    public void deleteBanner(String bannerId) {
        // 1. 삭제할 배너 정보를 DB에서 먼저 조회하여 파일 경로를 확보합니다.
        BannerEntity bannerToDelete = bannerRepository.findById(bannerId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 배너입니다. ID: " + bannerId));

        String pcImagePath = bannerToDelete.getImagePath();
        String mobileImagePath = bannerToDelete.getMobileImagePath();

        // 2. (DB 먼저) 데이터베이스에서 배너 정보를 삭제합니다.
        bannerRepository.deleteById(bannerId);

        // 3. (파일은 나중에) DB 삭제가 성공하면, FTP 서버에서 관련 이미지 파일들을 삭제합니다.
        if (pcImagePath != null) {
            ftpService.deleteFile("banners", pcImagePath);
        }
        if (mobileImagePath != null) {
            ftpService.deleteFile("banners", mobileImagePath);
        }
    }

    /**
     * 배너 이미지를 검증하고, 임시 폴더에 저장한 뒤, FTP 서버로 업로드하는 헬퍼 메소드입니다.
     * @param multipartFile 사용자가 업로드한 원본 파일
     * @param maxWidth 최대 허용 가로 해상도
     * @param maxHeight 최대 허용 세로 해상도
     * @return FTP 서버에 저장된 고유한 파일 이름
     */
    private String uploadAndValidateBannerImage(MultipartFile multipartFile, int maxWidth, int maxHeight) {
        // --- 1. 파일 유효성 검사 ---
        validateFile(multipartFile, maxWidth, maxHeight);

        // --- 2. 파일 저장 로직 ---
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
    
    /**
     * 업로드된 파일의 확장자, 용량, 해상도를 검증하는 헬퍼 메소드입니다.
     */
    private void validateFile(MultipartFile file, int maxWidth, int maxHeight) {
        // 확장자 검사
        List<String> allowedExtensions = Arrays.asList(".jpg", ".jpeg", ".png", ".gif");
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();
        if (!allowedExtensions.contains(extension)) {
            throw new IllegalArgumentException("허용되지 않는 파일 형식입니다. (JPG, PNG, GIF만 가능)");
        }

        // 용량 검사 (2MB)
        long maxSizeInBytes = 2 * 1024 * 1024;
        if (file.getSize() > maxSizeInBytes) {
            throw new IllegalArgumentException("파일 용량은 2MB를 초과할 수 없습니다.");
        }

        // 해상도 검사
        try {
            BufferedImage image = ImageIO.read(file.getInputStream());
            if (image == null) {
                throw new IllegalArgumentException("올바른 이미지 파일이 아닙니다.");
            }
            if (image.getWidth() > maxWidth || image.getHeight() > maxHeight) {
                throw new IllegalArgumentException("이미지 해상도는 " + maxWidth + "x" + maxHeight + " 픽셀을 초과할 수 없습니다.");
            }
        } catch (IOException e) {
            throw new RuntimeException("이미지 파일을 읽는 중 오류가 발생했습니다.", e);
        }
    }
}
