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
	private static String CURR_IMAGE_REPO_PATH="c://project//image_repo";
	
	@RequestMapping("/download")
	protected void download(@RequestParam("image_url") String image_url,
		                 	@RequestParam("store_id") String store_id,
			                 HttpServletResponse response) throws Exception {
		OutputStream out = response.getOutputStream();
		String filePath=CURR_IMAGE_REPO_PATH+"\\"+store_id+"\\"+image_url;
		File image=new File(filePath);

		response.setHeader("Cache-Control","no-cache");
		response.addHeader("Content-disposition", "attachment; image_url="+image_url);
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

}
