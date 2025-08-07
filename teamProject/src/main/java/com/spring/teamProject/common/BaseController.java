package com.spring.teamProject.common;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.spring.teamProject.vo.ImageFileVO;

public class BaseController {
	private static final String CURR_FILE_REPO_PATH = "C://project//file_repo";

	
	protected List<ImageFileVO> upload(MultipartHttpServletRequest multiReq) throws Exception {
	    List<ImageFileVO> imageFileList = new ArrayList<>();

	    Iterator<String> fileNames = multiReq.getFileNames();
	    while (fileNames.hasNext()) {
	        String fileName = fileNames.next();
	        MultipartFile file = multiReq.getFile(fileName);

	        if (file != null && !file.isEmpty()) {
	            String originalName = file.getOriginalFilename();
	            String storedFileName = UUID.randomUUID().toString() + "_" + originalName;

	            // 파일 저장: temp 폴더
	            File tempFile = new File(CURR_FILE_REPO_PATH + "\\temp\\" + storedFileName);
	            if (!tempFile.getParentFile().exists()) tempFile.getParentFile().mkdirs();
	            file.transferTo(tempFile);

	            // DB용 VO
	            ImageFileVO image = new ImageFileVO();
	            image.setFileName(storedFileName);
	            imageFileList.add(image);
	        }
	    }
	    return imageFileList;
	}


	protected void deleteFile(String fileName) {
		File file = new File(CURR_FILE_REPO_PATH + File.separator + fileName);
	    try {
	    	file.delete();
	    } catch (Exception e) { e.printStackTrace(); }
	    
	}

}
