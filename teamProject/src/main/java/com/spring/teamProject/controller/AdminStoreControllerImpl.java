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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.common.BaseController;
import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.AdminStoreService;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MenuVO;

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
	
	@RequestMapping(value={"/updateStoreInfoForm","/updateMenuInfoForm"})
	public ModelAndView updateform (@RequestParam("storeId") long storeId, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");

		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("storeId", storeId);
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
			System.out.println(name+": "+value);
			storeInfo.put(name, value);
		}
		
		String regIdstr = (String) storeInfo.get("ownerId");
		long regId = Long.parseLong(regIdstr);

		List<ImageFileVO> imgFileList = upload(multiReq);
		if (imgFileList != null && !imgFileList.isEmpty()) {
			for (ImageFileVO imageFileVO : imgFileList) {
				imageFileVO.setRegId(regId);
			}
			for(int i=0;i<imgFileList.size();i++) {
				System.out.print("이미지 파일 리스트 사이즈 : "+ imgFileList.size());
				System.out.println(imgFileList.get(i).getFileName());
			}
			storeInfo.put("fileName", imgFileList.get(0).getFileName());
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
			return new ModelAndView("redirect:/franchise/storeInfoForm?ownerId="+regId+"&success=true");
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
			return new ModelAndView("redirect:/franchise/storeInfoForm?ownerId="+regId+"&error=true");
		}
	}
	
	@Override
	public ModelAndView addMenuInfo(MultipartHttpServletRequest multiReq) throws Exception {
		multiReq.setCharacterEncoding("UTF-8");

		long storeId = Long.parseLong(multiReq.getParameter("storeId"));

		String[] menuName = multiReq.getParameterValues("menuName");
		String[] price = multiReq.getParameterValues("price");
		String[] description = multiReq.getParameterValues("description");
		String[] displayNo = multiReq.getParameterValues("displayNo");

		List<MultipartFile> fileList = multiReq.getFiles("fileName");

		for (int i = 0; i < menuName.length; i++) {
			// 1. 메뉴 저장
			MenuVO menuVO = new MenuVO();
			menuVO.setMenuName(menuName[i]);
			menuVO.setPrice(price[i]);
			menuVO.setDescription(description[i]);
			menuVO.setDisplayNo(Integer.parseInt(displayNo[i]));
			menuVO.setStoreId(storeId);

			long menuId = adminStoreService.addMenuInfo(menuVO); // menuId 반환

			// 2. 해당 메뉴에 대한 파일 추출
			MultipartFile file = fileList.get(i);
			if (file != null && !file.isEmpty()) {
				String originalFileName = file.getOriginalFilename();

				// 3. 저장 경로 구성 및 실제 저장
				File tempDir = new File(CURR_FILE_REPO_PATH + File.separator + "temp");
				if (!tempDir.exists()) tempDir.mkdirs();

				File saveFile = new File(tempDir, originalFileName);
				file.transferTo(saveFile);

				// 4. 이미지 정보 객체 생성 및 DB 저장
				ImageFileVO imageFileVO = new ImageFileVO();
				imageFileVO.setFileName(originalFileName);
				imageFileVO.setMenuId(menuId);   // menuId 연결!
				imageFileVO.setStoreId(storeId);

				adminStoreService.saveImage(imageFileVO);
			}

			System.out.println("메뉴 저장됨: " + menuName[i]);
		}

		return new ModelAndView("redirect:/somewhere");
	}


}
