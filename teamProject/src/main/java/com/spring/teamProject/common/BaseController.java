package com.spring.teamProject.common;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.spring.teamProject.vo.ImageFileVO;

public abstract class BaseController {
	
	private static final String CURR_FILE_REPO_PATH = "C:\\project\\file_repo";
	
	protected List<ImageFileVO> upload (MultipartHttpServletRequest multireq) throws Exception {
		int maxFileCount = 10;
		int filecount = 0;
		
		List<ImageFileVO> fileList = new ArrayList<>();
		Iterator<String> fileNames = multireq.getFileNames();
		
		while (fileNames.hasNext()) {
			
			if(++filecount>maxFileCount ) {
				throw new IllegalStateException("최대 " + maxFileCount + "개의 파일만 업로드 할 수 있습니다.");
			}
			ImageFileVO imgfileVO = new ImageFileVO();
			String fileName = fileNames.next();
			
			imgfileVO.setFileName(fileName);
			MultipartFile mFile = multireq.getFile(fileName);
			String originalFileName = mFile.getOriginalFilename();
			imgfileVO.setFileName(originalFileName);
			fileList.add(imgfileVO);
			
			File file = new File(CURR_FILE_REPO_PATH + File.separator + fileName);
			if(mFile.getSize()!=0) {
				if(!file.exists()) {
					if(file.getParentFile().mkdir()) {
						file.createNewFile();
					}
				}
				mFile.transferTo(new File(CURR_FILE_REPO_PATH+ File.separator +"temp" + File.separator + originalFileName));
			}
		}
		return fileList;
	}
	
	protected void deleteFile(String fileName) {
		File file = new File(CURR_FILE_REPO_PATH + File.separator+fileName);
		try {
			file.delete();
		} catch (Exception e) { e.printStackTrace(); }
	}
	
	@Bean
	public TomcatServletWebServerFactory tomcatFactory() {
	    return new TomcatServletWebServerFactory() {
	        @Override
	        protected void customizeConnector(org.apache.catalina.connector.Connector connector) {
	            super.customizeConnector(connector);
	            connector.setMaxPostSize(50 * 1024 * 1024); // 50MB
	        }
	    };
	}
}
