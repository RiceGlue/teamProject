package com.spring.teamProject.common;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.OutputStream;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpServletResponse;

@Controller
public class FileDownloadController {
	
	private static final String CURR_FILE_REPO_PATH = "C:\\project\\file_repo";
	
	@RequestMapping("/download")
	protected void download(@RequestParam("fileName") String fileName,
	                        @RequestParam("directoryName") String directoryName,
	                        HttpServletResponse res) throws Exception {
	    String downFilePath = CURR_FILE_REPO_PATH + File.separator + directoryName + File.separator + fileName;
	    File file = new File(downFilePath);

	    // 1. 경로 확인 로그
	    System.out.println("다운로드 경로: " + file.getAbsolutePath());

	    // 2. 존재 여부와 파일 여부 확인
	    if (!file.exists() || !file.isFile()) {
	        throw new FileNotFoundException("파일을 찾을 수 없거나, 디렉토리일 수 있습니다: " + file.getAbsolutePath());
	    }

	    // 3. 응답 설정
	    res.setHeader("Cache-Control", "no-cache");
	    res.addHeader("Content-disposition", "attachment;filename=" + fileName);

	    // 4. 파일 스트림 전송
	    try (FileInputStream in = new FileInputStream(file);
	         OutputStream out = res.getOutputStream()) {
	        byte[] buffer = new byte[1024 * 8];
	        int count;
	        while ((count = in.read(buffer)) != -1) {
	            out.write(buffer, 0, count);
	        }
	    }
	}

}
