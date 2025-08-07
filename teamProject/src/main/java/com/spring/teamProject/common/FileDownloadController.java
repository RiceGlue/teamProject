package com.spring.teamProject.common;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpServletResponse;
import net.coobird.thumbnailator.Thumbnails;

@Controller
public class FileDownloadController {
	private static String CURR_FILE_REPO_PATH="c://project//file_repo";
	
	@RequestMapping("/download")
	protected void download(@RequestParam("fileName") String fileName,
		                 	@RequestParam("storeId") String storeId,
			                 HttpServletResponse response) throws Exception {
		OutputStream out = response.getOutputStream();
		String filePath=CURR_FILE_REPO_PATH+"\\"+storeId+"\\"+fileName;
		File image=new File(filePath);

		response.setHeader("Cache-Control","no-cache");
		response.addHeader("Content-disposition", "attachment; image_url="+fileName);
		FileInputStream in=new FileInputStream(image); 
		byte[] buffer=new byte[1024*8];
		while(true){
			int count=in.read(buffer); // 입력에서 읽어들인 바이트 수를 저장
			if(count==-1)  // 파일의 끝(EOF)에 도달했는지 확인
				break;
			out.write(buffer,0,count); // 읽은 만큼 출력 스트림에 씀
		}
		in.close();
		out.close();
	}
	
	@RequestMapping("/image")
	protected void showImage(@RequestParam("fileName") String fileName,
	                         @RequestParam("storeId") String storeId,
	                         HttpServletResponse response) throws Exception {
	    String filePath = CURR_FILE_REPO_PATH + "\\" + storeId + "\\" + fileName;
	    File image = new File(filePath);

	    if (image.exists()) {
	        FileInputStream in = new FileInputStream(image);
	        byte[] buffer = new byte[1024 * 8];

	        // 이미지 파일 형식에 따라 ContentType 조정 (예: jpg, png 등)
	        response.setContentType("image/jpeg");

	        OutputStream out = response.getOutputStream();
	        int count;
	        while ((count = in.read(buffer)) != -1) {
	            out.write(buffer, 0, count);
	        }
	        in.close();
	        out.close();
	    } else {
	        response.sendError(HttpServletResponse.SC_NOT_FOUND);
	    }
	}

}
