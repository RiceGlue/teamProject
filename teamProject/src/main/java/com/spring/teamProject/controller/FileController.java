package com.spring.teamProject.controller;

import com.spring.teamProject.service.FtpService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Controller
public class FileController {

    private static final Logger logger = LoggerFactory.getLogger(FileController.class);

    @Autowired
    private FtpService ftpService;

    /**
     * 프로필 이미지 요청을 처리하는 핸들러입니다.
     * FTP 연결 실패 시, 로컬에 저장된 기본 프로필 이미지로 대체하여 응답합니다.
     * URL 예시: /profile-images/profile/uuid.png
     */
    @GetMapping("/profile-images/{subDirectory}/{fileName}")
    @ResponseBody
    public ResponseEntity<byte[]> getProfileImage(@PathVariable String subDirectory, @PathVariable String fileName) {
        try {
            // 1. FTP 서버에서 원본 이미지를 가져오려고 시도합니다.
            byte[] fileContent = ftpService.downloadFile(subDirectory, fileName);
            return createResponseEntity(fileName, fileContent);
        } catch (IOException e) {
            // 2. FTP에서 이미지를 가져오는데 실패하면, catch 블록이 실행됩니다.
            logger.warn("FTP에서 프로필 이미지 ({}/{}) 로드 실패. 대체 이미지를 사용합니다.", subDirectory, fileName);
            try {
                // 3. 프로젝트 내부의 static 폴더에서 '프로필'용 대체 이미지 파일을 읽어옵니다.
                byte[] fallbackContent = loadFallbackImage("static/images/default_profile.png");
                return createResponseEntity("default_profile.png", fallbackContent);
            } catch (IOException ex) {
                logger.error("대체 프로필 이미지 로드 실패", ex);
                return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }
    }

    /**
     * 배너 이미지 요청을 처리하는 핸들러입니다.
     * FTP 연결 실패 시, 로컬에 저장된 기본 배너 이미지로 대체하여 응답합니다.
     * URL 예시: /banner-images/uuid.png
     */
    @GetMapping("/banner-images/{fileName}")
    @ResponseBody
    public ResponseEntity<byte[]> getBannerImage(@PathVariable String fileName) {
        try {
            // 1. FTP 서버의 'banners' 폴더에서 원본 이미지를 가져오려고 시도합니다.
            byte[] fileContent = ftpService.downloadFile("banners", fileName);
            return createResponseEntity(fileName, fileContent);
        } catch (IOException e) {
            // 2. FTP에서 이미지를 가져오는데 실패하면, catch 블록이 실행됩니다.
            logger.warn("FTP에서 배너 이미지 ({}) 로드 실패. 대체 이미지를 사용합니다.", fileName);
            try {
                // 3. 프로젝트 내부의 static 폴더에서 '배너'용 대체 이미지 파일을 읽어옵니다.
                byte[] fallbackContent = loadFallbackImage("static/images/banners/fallback_banner.png");
                return createResponseEntity("fallback_banner.png", fallbackContent);
            } catch (IOException ex) {
                logger.error("대체 배너 이미지 로드 실패", ex);
                return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }
    }
    
    /**
     * [수정됨] 가게, 리뷰 등 일반적인 이미지 요청을 처리하는 범용 핸들러입니다.
     * FTP 연결 실패 시, 대체 이미지를 응답합니다.
     * URL 예시: /images/store/uuid.png, /images/review/uuid.png
     */
    @GetMapping("/images/{subDirectory}/{fileName}")
    @ResponseBody
    public ResponseEntity<byte[]> getImage(@PathVariable String subDirectory, @PathVariable String fileName) {
        try {
            byte[] fileContent = ftpService.downloadFile(subDirectory, fileName);
            return createResponseEntity(fileName, fileContent);
        } catch (IOException e) {
            logger.warn("FTP에서 일반 이미지 ({}/{}) 로드 실패. 대체 이미지를 사용합니다.", subDirectory, fileName);
            // 대체 이미지로 400x300 크기의 회색 배경 이미지를 반환합니다.
            String placeholderText = URLEncoder.encode(subDirectory + "/" + fileName, StandardCharsets.UTF_8);
            String placeholderUrl = "https://placehold.co/400x300/e2e8f0/64748b?text=Image\\nNot+Found";
            
            HttpHeaders headers = new HttpHeaders();
            headers.add("Location", placeholderUrl);
            return new ResponseEntity<>(headers, HttpStatus.FOUND); // 302 Found 리다이렉트
        }
    }

    /**
     * 파일 이름과 내용(byte 배열)을 받아, 적절한 HTTP 응답을 생성하는 헬퍼 메소드입니다.
     */
    private ResponseEntity<byte[]> createResponseEntity(String fileName, byte[] content) {
        HttpHeaders headers = new HttpHeaders();
        
        // 파일 확장자를 기반으로 이미지의 Content-Type을 자동으로 감지합니다.
        String mimeType = URLConnection.guessContentTypeFromName(fileName);
        if (mimeType == null) {
            // 감지 실패 시, 일반적인 바이너리 스트림으로 설정
            mimeType = MediaType.APPLICATION_OCTET_STREAM_VALUE;
        }
        headers.setContentType(MediaType.parseMediaType(mimeType));
        
        // 브라우저 캐시를 설정하여 성능을 향상시킵니다. (1년 동안 캐시)
        headers.setCacheControl("public, max-age=31536000");

        return new ResponseEntity<>(content, headers, HttpStatus.OK);
    }

    /**
     * 프로젝트 내부(classpath)에서 대체(Fallback) 이미지 파일을 읽어오는 헬퍼 메소드입니다.
     */
    private byte[] loadFallbackImage(String path) throws IOException {
        ClassPathResource resource = new ClassPathResource(path);
        try (InputStream inputStream = resource.getInputStream()) {
            return FileCopyUtils.copyToByteArray(inputStream);
        }
    }
}
