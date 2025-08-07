package com.spring.teamProject.common;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpServletResponse;

@Controller
public class FileDownloadController {
	
	private static final String CURR_FILE_REPO_PATH = "C:\\project\\file_repo";
	
	@RequestMapping("/download")
	protected void download(@RequestParam("fileName") String fileName, HttpServletResponse res) throws Exception {
		OutputStream out = res.getOutputStream();
		String downFile = CURR_FILE_REPO_PATH + "\\"+ fileName;
		File file = new File(downFile);
		
		res.setHeader("Cache-Control", "no-cache");
		res.addHeader("Content-disposition","attachment;fileName=" + fileName);
		FileInputStream in = new FileInputStream(file);
		byte[] buffer = new byte[1024*8];
		
		while(true) {
			int count = in.read(buffer);
			if(count==-1) break;
			out.write(buffer,0,count);
		}
		in.close();
		out.close();
		
	}
}
