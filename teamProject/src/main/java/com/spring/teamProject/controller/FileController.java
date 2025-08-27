package com.spring.teamProject.controller;

import java.io.IOException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import com.spring.teamProject.service.FtpService;

@Controller
public class FileController {

    @Autowired
    private FtpService ftpService;

    /**
     * 프로필 이미지 요청을 처리하는 핸들러입니다.
     * URL 예시: /profile-images/profile/uuid.png
     */
    @GetMapping("/profile-images/{subDirectory}/{fileName}")
    @ResponseBody
    public ResponseEntity<byte[]> getProfileImage(@PathVariable String subDirectory, @PathVariable String fileName) {
        try {
            // FtpService를 통해 FTP 서버의 'profile' 폴더에서 파일을 가져옵니다.
            byte[] fileContent = ftpService.downloadFile(subDirectory, fileName);
            return createResponseEntity(fileName, fileContent);
        } catch (IOException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    /**
     * ? --- [신규] 배너 이미지 요청을 처리하는 핸들러입니다. --- ?
     * URL 예시: /banner-images/uuid.png
     */
    @GetMapping("/banner-images/{fileName}")
    @ResponseBody
    public ResponseEntity<byte[]> getBannerImage(@PathVariable String fileName) {
        try {
            // FtpService를 통해 FTP 서버의 'banners' 폴더에서 파일을 가져옵니다.
            byte[] fileContent = ftpService.downloadFile("banners", fileName);
            return createResponseEntity(fileName, fileContent);
        } catch (IOException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    /**
     * 이미지 파일의 확장자에 맞춰 적절한 HTTP 응답을 생성하는 헬퍼 메소드입니다.
     */
    private ResponseEntity<byte[]> createResponseEntity(String fileName, byte[] fileContent) {
        HttpHeaders headers = new HttpHeaders();
        
        // 파일 확장자에 따라 적절한 이미지 타입을 설정합니다.
        if (fileName.toLowerCase().endsWith(".png")) {
            headers.setContentType(MediaType.IMAGE_PNG);
        } else if (fileName.toLowerCase().endsWith(".jpg") || fileName.toLowerCase().endsWith(".jpeg")) {
            headers.setContentType(MediaType.IMAGE_JPEG);
        } else if (fileName.toLowerCase().endsWith(".gif")) {
            headers.setContentType(MediaType.IMAGE_GIF);
        } else {
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        }
        
        // 브라우저 캐시를 설정하여 성능을 향상시킵니다. (1년 동안 캐시)
        headers.setCacheControl("public, max-age=31536000");

        return new ResponseEntity<>(fileContent, headers, HttpStatus.OK);
    }
}
