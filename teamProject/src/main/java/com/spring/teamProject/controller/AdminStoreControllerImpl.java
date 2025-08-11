package com.spring.teamProject.controller;

import java.io.File;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
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

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
  
@Controller("adminStoreController")
@RequestMapping(value="/franchise")
public class AdminStoreControllerImpl extends BaseController implements AdminStoreController {
	
	private static final String CURR_FILE_REPO_PATH = "C:\\project\\file_repo";
	
	@Autowired
	private AdminStoreService adminStoreService;
	
	@RequestMapping(value={"/storeInfoForm","/menuInfoForm"})
	public ModelAndView form (@RequestParam("ownerId") long ownerId, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");

		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("ownerId", ownerId);
		return mav;
	}
	
	@RequestMapping(value="/addStoreInfo", method=RequestMethod.POST)
	public ModelAndView addStoreInfo(MultipartHttpServletRequest multiReq) throws Exception {
		multiReq.setCharacterEncoding("UTF-8");
		String imageFileName = null;
		
		Map<String, Object> storeInfo = new HashMap<>();
		Enumeration<?> enu = multiReq.getParameterNames();
		while (enu.hasMoreElements()) {
			String name = (String) enu.nextElement();
			String value = multiReq.getParameter(name);
			storeInfo.put(name, value);
		}

		long regId = (long)storeInfo.get("ownerId");
		System.out.println("등록자 아이디: "+regId);

		List<ImageFileVO> imgFileList = upload(multiReq);
		if (imgFileList != null && !imgFileList.isEmpty()) {
			for (ImageFileVO imageFileVO : imgFileList) {
				imageFileVO.setRegId(regId);
			}
			for(int i=0;i<imgFileList.size();i++) {
				System.out.print("이미지 파일 리스트 사이즈 : "+ imgFileList.size());
				System.out.println(imgFileList.get(i).getFileName());
			}
			storeInfo.put("imgFileList", imgFileList);
		}

		try {
			long storeId = adminStoreService.addStoreInfo(storeInfo);
			if (imgFileList != null && !imgFileList.isEmpty()) {
				for (ImageFileVO imageFileVO : imgFileList) {
					imageFileName = imageFileVO.getFileName();
					File srcFile = new File(CURR_FILE_REPO_PATH + File.separator + "temp" + File.separator + imageFileName);
					File destDir = new File(CURR_FILE_REPO_PATH + File.separator + storeId);
					FileUtils.moveFileToDirectory(srcFile, destDir, true);
				}
			}
			// ✅ 등록 성공 시 redirect
			return new ModelAndView("redirect:/franchise/storeInfoForm?success=true");
		} catch (Exception e) {
			if (imgFileList != null && !imgFileList.isEmpty()) {
				for (ImageFileVO imageFileVO : imgFileList) {
					imageFileName = imageFileVO.getFileName();
					File srcFile = new File(CURR_FILE_REPO_PATH + File.separator + "temp" + File.separator + imageFileName);
					if (srcFile.exists()) {
						srcFile.delete();
					}
				}
			}
			e.printStackTrace();
			// 실패 시에도 redirect
			return new ModelAndView("redirect:/franchise/storeInfoForm?error=true");
		}
	}

}
