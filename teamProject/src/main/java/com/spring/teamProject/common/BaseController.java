package com.spring.teamProject.common;

import java.io.File;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Iterator;
import java.util.List;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.vo.ImageFileVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class BaseController {
	private static final String CURR_IMAGE_REPO_PATH = "C://project//file_repo";

	protected List<ImageFileVO> upload(MultipartHttpServletRequest multiReq) throws Exception {
		List<ImageFileVO> fileList = new ArrayList<>();
	    Iterator<String> fileNames = multiReq.getFileNames();

	        while (fileNames.hasNext()) {
	            ImageFileVO imageFileVO = new ImageFileVO();
	            String fileName = fileNames.next();
	            imageFileVO.setFileName(fileName);
	            MultipartFile mFile = multiReq.getFile(fileName);
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

	    @RequestMapping(value = "/*.do", method = {RequestMethod.GET, RequestMethod.POST})
	    protected ModelAndView viewForm(HttpServletRequest request, HttpServletResponse response) throws Exception {
	        String viewName = (String) request.getAttribute("viewName");
	        return new ModelAndView(viewName);
	    }


}
