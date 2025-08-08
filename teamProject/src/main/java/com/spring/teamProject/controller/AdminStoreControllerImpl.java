package com.spring.teamProject.controller;

import java.io.File;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.common.BaseController;
import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.AdminStoreService;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.StoreVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
  
@Controller("adminStoreController")
@RequestMapping(value="/franchise")
public class AdminStoreControllerImpl extends BaseController implements AdminStoreController {
	
	private static final String CURR_FILE_REPO_PATH = "C:\\project\\file_repo";
	
	@Autowired
	private AdminStoreService adminStoreService;
	
	@RequestMapping(value={"/storeInfoForm","/menuInfoForm"})
	public ModelAndView form (@RequestParam("ownerId") long ownerId, @RequestParam("storeName") String storeName, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");
		
		StoreVO storeVO = new StoreVO();
		
		storeVO.setOwnerId(ownerId);
		storeVO.setStoreName(storeName);
		
		long storeId = adminStoreService.selectStoreId(storeVO);
		
		System.out.println(storeId);

		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("storeId", storeId);
		mav.addObject("storeName", storeName);
		return mav;
	}
	
	public ResponseEntity addStoreInfo(MultipartHttpServletRequest multireq, HttpServletResponse res) throws Exception {
		multireq.setCharacterEncoding("UTF-8");
		res.setContentType("text/html; charset=UTF-8");
		
		String fileName = null;
		
		Map storeInfo = new HashMap<>();
		
		Enumeration enu = multireq.getParameterNames();
		while(enu.hasMoreElements()) {
			String name = (String)enu.nextElement();
			String value = multireq.getParameter(name);
			
			storeInfo.put(name, value);
		}
		
		long storeId = (long) storeInfo.get("storeId");
		long ownerId = adminStoreService.selectOwnerId(storeId);
		
		List<ImageFileVO> imgfile = upload(multireq);
		if(imgfile!=null && imgfile.size()!=0) {
			for(ImageFileVO imgfileVO : imgfile) {
				imgfileVO.setRegId(ownerId);
			}
			
			storeInfo.put("imgfile", imgfile);
		}
		
		String message = null;
		ResponseEntity resEntity = null;
		HttpHeaders resHeaders = new HttpHeaders();
		resHeaders.add("Content-Type","text/html; charset=UTF-8");
		
		try {
			long infoId = adminStoreService.addStoreInfo(storeInfo);
			if(imgfile!=null&&imgfile.size()!=0) {
				for(ImageFileVO imgfileVO:imgfile) {
					fileName = imgfileVO.getFileName();
					File srcFile = new File(CURR_FILE_REPO_PATH+"\\"+"temp"+"\\"+fileName);
					File destDir = new File(CURR_FILE_REPO_PATH+"\\"+infoId);
					FileUtils.moveFileToDirectory(srcFile, destDir, true);
				}
			}
			message = "<script>";
			message += " alert('정보 입력 성공.');";
			message += " location.href='" + multireq.getContextPath() + "/franchise/storeInfoForm';";
			message += "</script>";
			
		} catch(Exception e) {
			if(imgfile!=null&&imgfile.size()!=0) {
				for(ImageFileVO imgfileVO : imgfile) {
					fileName = imgfileVO.getFileName();
					File srcFile = new File(CURR_FILE_REPO_PATH+"\\"+"temp"+"\\"+fileName);
					srcFile.delete();
				}
			}
			message = "<script>";
			message += " alert('정보 입력 실패. 다시 시도해 주세요');";
			message += " location.href='" + multireq.getContextPath() + "/franchise/storeInfoForm';";
			message += "</script>";
			
			e.printStackTrace();
		}
		resEntity = new ResponseEntity(message, resHeaders, HttpStatus.OK);
		return resEntity; 
	}
	
}
