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
    	
        while (fileNames.hasNext()) {
            ImageFileVO imageFileVO = new ImageFileVO();
            String fileName = fileNames.next();
            MultipartFile mFile = req.getFile(fileName);
            String originalFileName = mFile.getOriginalFilename();
            imageFileVO.setFileName(originalFileName);
            fileList.add(imageFileVO);

            File file = new File(CURR_IMAGE_REPO_PATH + File.separator + fileName);
            if (mFile.getSize() != 0) {
                if (!file.exists()) {
                    if (file.getParentFile().mkdirs()) {
                        file.createNewFile();
                    }
                }
                mFile.transferTo(new File(CURR_IMAGE_REPO_PATH + File.separator + "temp" + File.separator + originalFileName));
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
