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

    // 프로필 이미지 요청을 처리하는 핸들러
    @GetMapping("/profile-images/{subDirectory}/{fileName}")
    @ResponseBody
    public ResponseEntity<byte[]> getProfileImage(@PathVariable String subDirectory, @PathVariable String fileName) {
        try {
            // FtpService를 통해 FTP 서버에서 파일 내용을 byte 배열로 가져옵니다.
            byte[] fileContent = ftpService.downloadFile(subDirectory, fileName);

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
            
            // 브라우저 캐시를 설정하여 성능을 향상시킵니다.
            headers.setCacheControl("public, max-age=31536000"); // 1년 동안 캐시

            return new ResponseEntity<>(fileContent, headers, HttpStatus.OK);

        } catch (IOException e) {
            // 파일을 찾지 못했거나 오류 발생 시 404 Not Found 응답을 보냅니다.
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
}
