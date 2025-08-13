package com.spring.teamProject.common;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.spring.teamProject.vo.ImageFileVO;

@Controller
public abstract class BaseController {

    private static final String CURR_IMAGE_REPO_PATH = "C:\\project\\file_repo";

    protected List<ImageFileVO> upload(MultipartHttpServletRequest req) throws Exception {
        List<MultipartFile> files = req.getFiles("fileName"); // name 속성 기준으로 파일 전체 가져오기
        List<ImageFileVO> fileList = new ArrayList<>();

        File tempDir = new File(CURR_IMAGE_REPO_PATH + File.separator + "temp");
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

    protected void deleteFile(String fileName) {
        File file = new File(CURR_IMAGE_REPO_PATH + File.separator + fileName);
        try {
            file.delete();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
