package com.spring.teamProject.controller;

import java.io.File;
import java.util.ArrayList;
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
	
	@RequestMapping(value="/storeInfoForm")
	public ModelAndView storeInfoForm (@RequestParam("ownerId") long ownerId,HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");

		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("ownerId", ownerId);
		return mav;
	}
	
	@RequestMapping(value="/menuInfoForm")
	public ModelAndView menuInfoForm (@RequestParam("storeId") long storeId, @RequestParam("ownerId") long ownerId, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");

		ModelAndView mav = ViewUtil.layout(viewName);
		System.out.println(storeId);
		mav.addObject("storeId", storeId);
		mav.addObject("ownerId", ownerId);
		return mav;
	}
	
	@Override
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
			adminStoreService.addStoreInfoImage(imgFileList);
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
	@RequestMapping(value="/addMenuInfo", method=RequestMethod.POST)
	public ModelAndView addMenuInfo(MultipartHttpServletRequest multiReq) throws Exception {
	    multiReq.setCharacterEncoding("UTF-8");

	    String[] menuName = multiReq.getParameterValues("menuName");

	    // menuName 배열이 null인지 확인하는 코드를 추가합니다.
	    if (menuName == null || menuName.length == 0) {
	        // 메뉴가 하나도 없는 경우 처리
	        System.out.println("메뉴 항목이 제출되지 않았습니다.");
	        // 오류 페이지로 리다이렉트하거나 사용자에게 알릴 수 있는 방법을 선택합니다.
	        String regIdStr = multiReq.getParameter("regId");
	        return new ModelAndView("redirect:/franchise/menuInfoForm?storeId=4&ownerId=1&menu=true");
	    }

	    String[] price = multiReq.getParameterValues("price");
	    String[] description = multiReq.getParameterValues("description");
	    String[] displayNo = multiReq.getParameterValues("displayNo");
	    
	    String storeIdStr = multiReq.getParameter("storeId"); 
	    String regIdStr = multiReq.getParameter("regId");

	    long storeId = 0;
	    long regId = 0;

	    if(storeIdStr != null && !storeIdStr.trim().isEmpty()) {
	        storeId = Long.parseLong(storeIdStr);
	        System.out.println(storeId);
	    }

	    if(regIdStr != null && !regIdStr.trim().isEmpty()) {
	        regId = Long.parseLong(regIdStr);
	        System.out.println(regId);
	    }

	    List<MultipartFile> fileList = multiReq.getFiles("fileName");

	    try {
	        for (int i = 0; i < menuName.length; i++) {
	            // 메뉴 정보 설정
	            MenuVO menuVO = new MenuVO();
	            menuVO.setMenuName(menuName[i]);
	            menuVO.setPrice(price[i]);
	            menuVO.setDescription(description[i]);
	            menuVO.setDisplayNo(Integer.parseInt(displayNo[i]));
	            menuVO.setStoreId(storeId);

<<<<<<< HEAD
	            // 파일 이름 설정
	            MultipartFile file = fileList.get(i);
	            if (file != null && !file.isEmpty()) {
	                String originalFileName = file.getOriginalFilename();
	                menuVO.setFileName(originalFileName);
	            }

	            System.out.println(menuName[i]+","+price[i]+","+description[i]+","+displayNo[i]+","+storeId+","+menuVO.getFileName());
	            // 메뉴 insert (menuId 자동 세팅됨)
	            long menuId = adminStoreService.addMenuInfo(menuVO);
=======
				// 4. 이미지 정보 객체 생성 및 DB 저장
				ImageFileVO imageFileVO = new ImageFileVO();
				imageFileVO.setFileName(originalFileName);
				// * 이거 임시로 주석처리 해두었어요 지수씨
				//imageFileVO.setMenuId(menuId);   // menuId 연결!
				imageFileVO.setStoreId(storeId);

				//adminStoreService.saveImage(imageFileVO);
			}
>>>>>>> fd736abbf7d819c3386861460a382a2305d5bd25

	            // 이미지 저장
	            if (file != null && !file.isEmpty()) {
	                File tempDir = new File(CURR_FILE_REPO_PATH + File.separator + "temp");
	                if (!tempDir.exists()) tempDir.mkdirs();

	                File saveFile = new File(tempDir, file.getOriginalFilename());
	                file.transferTo(saveFile);

	                ImageFileVO imageFileVO = new ImageFileVO();
	                imageFileVO.setFileName(file.getOriginalFilename());
	                imageFileVO.setMenuId(menuId);   // 연결된 menuId
	                imageFileVO.setStoreId(storeId);

	                adminStoreService.addMenuInfoImage(imageFileVO);
	            }

	            System.out.println("메뉴 저장됨: " + menuName[i]);
	        }

	        // 성공 시 redirect + success 파라미터
	        return new ModelAndView("redirect:/franchise/menuInfoForm?storeId=4&ownerId=1&success=true");
	    } catch (Exception e) {
	        e.printStackTrace();

	        // 실패 시 redirect + error 파라미터
	        return new ModelAndView("redirect:/franchise/menuInfoForm?storeId=4&ownerId=1&error=true");
	    }
	}

}
