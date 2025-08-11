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
        List<ImageFileVO> fileList = new ArrayList<>();
        Iterator<String> fileNames = req.getFileNames();

        File tempDir = new File(CURR_IMAGE_REPO_PATH + File.separator + "temp");
        if (!tempDir.exists()) {
            tempDir.mkdirs(); // temp 폴더 생성
        }

        while (fileNames.hasNext()) {
            String paramName = fileNames.next();
            MultipartFile mFile = req.getFile(paramName);

            if (mFile != null && mFile.getSize() > 0) {
                String originalFileName = mFile.getOriginalFilename();

                ImageFileVO imageFileVO = new ImageFileVO();
                imageFileVO.setFileName(originalFileName);
                fileList.add(imageFileVO);

                // 저장 경로
                File saveFile = new File(tempDir, originalFileName);
                mFile.transferTo(saveFile);
            }
        }

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
