package com.spring.teamProject.controller;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
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
import org.springframework.web.bind.annotation.RequestMethod;
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
	
	@Override
	@RequestMapping(value = "/addStoreInfo", method = RequestMethod.POST)
	public ResponseEntity<String> addStoreInfo(MultipartHttpServletRequest multiReq,
	                                           HttpServletResponse response) throws Exception {
		
		int count =1;
		
	    multiReq.setCharacterEncoding("utf-8");

	    Map<String, Object> storeInfoMap = new HashMap<>();

	    Enumeration<?> enu = multiReq.getParameterNames();
	    while (enu.hasMoreElements()) {
	        String name = (String) enu.nextElement();
	        String value = multiReq.getParameter(name);
	        storeInfoMap.put(name, value);
	    }

	    String storeId = (String) storeInfoMap.get("storeId");
	    String imageFileName = null;
	    String message;
	    ResponseEntity<String> resEntity;
	    HttpHeaders responseHeaders = new HttpHeaders();
	    responseHeaders.add("Content-Type", "text/html; charset=utf-8");

	    try {
	        // 1. 이미지 파일 리스트 추출
	        List<ImageFileVO> imageFileList = upload(multiReq); // 이 메서드는 아래에서 설명


	        // 3. 이미지 메타정보 추가
	        if (imageFileList != null && !imageFileList.isEmpty()) {
	            for (ImageFileVO imageFileVO : imageFileList) {
	                imageFileVO.setFileType(false); // 가게 이미지
	                imageFileVO.setDisplayNo(count); // 필요 시 변경
	                imageFileVO.setRegId(1L); // 추후 세션 유저 ID로 변경
	                count++;
	            }
	            storeInfoMap.put("imageFileList", imageFileList);
	        }
	        
	        long infoId = adminStoreService.addStoreInfo(storeInfoMap);

	        // 4. 이미지 실제 저장 (temp → 정식 폴더로)
	        if (imageFileList != null && !imageFileList.isEmpty()) {
	            for (ImageFileVO imageFileVO : imageFileList) {
	                imageFileName = imageFileVO.getFileName();

	                File srcFile = new File(CURR_FILE_REPO_PATH + "\\temp\\" + imageFileName);
	                File destDir = new File(CURR_FILE_REPO_PATH + "\\" + storeId);
	                if (!destDir.exists()) destDir.mkdirs();

	                FileUtils.moveFileToDirectory(srcFile, destDir, true);
	            }
	        }

	        message = "<script>";
	        message += "alert('가게 정보가 등록되었습니다.');";
	        message += "location.href='" + multiReq.getContextPath() + "/franchise/addStoreInfo';";
	        message += "</script>";

	    } catch (Exception e) {
	        e.printStackTrace();

	        if (imageFileName != null) {
	            File tempFile = new File(CURR_FILE_REPO_PATH + "\\temp\\" + imageFileName);
	            tempFile.delete();
	        }

	        message = "<script>";
	        message += "alert('오류가 발생했습니다. 다시 시도해 주세요.');";
	        message += "location.href='" + multiReq.getContextPath() + "/franchise/addStoreInfo';";
	        message += "</script>";
	    }

	    resEntity = new ResponseEntity<>(message, responseHeaders, HttpStatus.OK);
	    return resEntity;
	}



}
