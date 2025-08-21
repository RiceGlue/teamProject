package com.spring.teamProject.common;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.spring.teamProject.vo.ImageFileVO;

@Controller
public abstract class BaseController {

    private static final String CURR_IMAGE_REPO_PATH = "C:\\project\\file_repo";

    protected List<ImageFileVO> upload(MultipartHttpServletRequest req, String directoryName) throws Exception {
        List<MultipartFile> files = req.getFiles("fileName[]"); // name 속성 기준으로 파일 전체 가져오기
        List<ImageFileVO> fileList = new ArrayList<>();

        File tempDir = new File(CURR_IMAGE_REPO_PATH + File.separator + directoryName);
        if (!tempDir.exists()) {
            tempDir.mkdirs(); // temp 폴더 생성
        }

        for (MultipartFile file : files) {
            // 디버깅 출력
            System.out.println("파일 파라미터 이름: fileName");

            if (file != null && !file.isEmpty()) {
                System.out.println(" → 실제 파일 이름: " + file.getOriginalFilename());
                System.out.println(" → 파일 크기: " + file.getSize());

                String originalFileName = file.getOriginalFilename();

                ImageFileVO imageFileVO = new ImageFileVO();
                imageFileVO.setFileName(originalFileName);
                fileList.add(imageFileVO);

                // 저장 경로
                File saveFile = new File(tempDir, originalFileName);
                file.transferTo(saveFile);
            } else {
                System.out.println(" → 파일이 비어 있거나 null입니다.");
            }
        }

        System.out.println("총 파일 수집 개수: " + fileList.size());

        return fileList;
    }
    
    protected void modifyUpload(MultipartHttpServletRequest req, String directoryName) throws Exception {
        List<MultipartFile> files = req.getFiles("fileName"); // name 속성 기준으로 파일 전체 가져오기
        
        File tempDir = new File(CURR_IMAGE_REPO_PATH + File.separator + directoryName);
        if (!tempDir.exists()) {
            tempDir.mkdirs(); // temp 폴더 생성
        }

        for (MultipartFile file : files) {
            // 디버깅 출력
            System.out.println("파일 파라미터 이름: fileName");

            if (file != null && !file.isEmpty()) {
                System.out.println(" → 실제 파일 이름: " + file.getOriginalFilename());
                System.out.println(" → 파일 크기: " + file.getSize());

                String originalFileName = file.getOriginalFilename();

                // 저장 경로
                File saveFile = new File(tempDir, originalFileName);
                file.transferTo(saveFile);
            } else {
                System.out.println(" → 파일이 비어 있거나 null입니다.");
            }
        }

    }

    protected void deleteFile(String fileName, String directoryName) {
        File file = new File(CURR_IMAGE_REPO_PATH + File.separator + directoryName + File.separator + fileName);
        System.out.println("파일 삭제 시도 경로: " + file.getAbsolutePath());
        try {
            if (!file.exists()) {
                System.out.println("삭제 실패: 파일이 존재하지 않습니다.");
            } else if (!file.canWrite()) {
                System.out.println("삭제 실패: 파일에 쓰기 권한이 없습니다.");
            } else if (file.delete()) {
                System.out.println("삭제 성공: " + file.getAbsolutePath());
            } else {
                System.out.println("삭제 실패: 이유 불명 (파일이 잠겨있을 수 있음)");
            }
        } catch (Exception e) {
            System.out.println("삭제 중 예외 발생:");
            e.printStackTrace();
        }
    }


}
