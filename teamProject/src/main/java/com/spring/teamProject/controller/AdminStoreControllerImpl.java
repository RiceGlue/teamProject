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
		System.out.println(ownerId);
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

		// 1. regId 세팅
		if (imgFileList != null && !imgFileList.isEmpty()) {
		    for (ImageFileVO imageFileVO : imgFileList) {
		        imageFileVO.setRegId(regId); // ✅ regId는 먼저 세팅 가능
		    }
		    storeInfo.put("fileName", imgFileList.get(0).getFileName());
		}

		try {
		    // 2. store 정보 먼저 등록 후 storeId 받기
		    long storeId = adminStoreService.addStoreInfo(storeInfo);

		    // 3. 생성된 storeId를 이미지에 추가 세팅
		    for (ImageFileVO imageFileVO : imgFileList) {
		    	imageFileVO.setStoreId(storeId);// ✅ storeId는 이 시점에 세팅
		    }

		    // 4. 이미지 DB 저장
		    adminStoreService.addStoreInfoImage(imgFileList);

		    // 5. 파일 이동
		    for (ImageFileVO imageFileVO : imgFileList) {
		        imageFileName = imageFileVO.getFileName();
		        File srcFile = new File(CURR_FILE_REPO_PATH + File.separator + "temp" + File.separator + imageFileName);
		        File destDir = new File(CURR_FILE_REPO_PATH + File.separator + storeId);
		        FileUtils.moveFileToDirectory(srcFile, destDir, true);
		    }

		    return new ModelAndView("redirect:/franchise/storeInfoForm?ownerId=" + regId + "&success=true");

		} catch (Exception e) {
		    // 삭제 로직 그대로 유지
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
		    return new ModelAndView("redirect:/franchise/storeInfoForm?ownerId=" + regId + "&error=true");
		}
	}
	
	@Override
	@RequestMapping(value = "/addMenuInfo", method = RequestMethod.POST)
	public ModelAndView addMenuInfo(MultipartHttpServletRequest multiReq) throws Exception {
	    multiReq.setCharacterEncoding("UTF-8");

	    // 폼 데이터를 배열로 받기
	    String[] menuNames = multiReq.getParameterValues("menuName");
	    String[] prices = multiReq.getParameterValues("price");
	    String[] descriptions = multiReq.getParameterValues("description");
	    String[] displayNos = multiReq.getParameterValues("displayNo");

	    // 고정 파라미터 받기
	    String storeIdStr = multiReq.getParameter("storeId");
	    String regIdStr = multiReq.getParameter("regId");

	    long storeId = Long.parseLong(storeIdStr);
	    long regId = Long.parseLong(regIdStr);
	    
	    System.out.println(storeId +","+regId);

	    // 파일 업로드 메서드 호출
	    List<ImageFileVO> imgFileList = upload(multiReq);
	    
	    ModelAndView mav = new ModelAndView();

	    try {
	        // 메뉴 개수만큼 반복
	        if (menuNames != null) {
	        	System.out.println("여기");
	            for (int i = 0; i < menuNames.length; i++) {
	                // 1. MenuVO 객체 생성 및 데이터 설정
	                MenuVO menuVO = new MenuVO();
	                menuVO.setStoreId(storeId);
	                menuVO.setMenuName(menuNames[i]);
	                menuVO.setPrice(prices[i]);
	                menuVO.setDescription(descriptions[i]);
	                menuVO.setDisplayNo(Integer.parseInt(displayNos[i]));

	                System.out.println(menuNames[i]+","+prices[i]);
	                // i번째 메뉴에 해당하는 i번째 파일 이름을 MenuVO에 연결 (파일이 있을 경우만)
	                if (imgFileList != null && i < imgFileList.size()) {
	                    menuVO.setFileName(imgFileList.get(i).getFileName());
	                }

	                // 2. 메뉴 정보 DB에 저장 후, 자동 생성된 menuId 가져오기
	                long menuId = adminStoreService.addMenuInfo(menuVO);

	                // 3. ImageFileVO 객체에 추가 정보 설정 후 DB에 저장
	                // 파일이 존재할 경우에만 ImageFileVO를 처리
	                if (imgFileList != null && i < imgFileList.size()) {
	                    ImageFileVO imageFileVO = imgFileList.get(i);
	                    imageFileVO.setStoreId(storeId);
	                    imageFileVO.setRegId(regId);
	                    imageFileVO.setMenuId(menuId); // 생성된 menuId를 설정
	                    imageFileVO.setDisplayNo(Integer.parseInt(displayNos[i]));

	                    adminStoreService.addMenuInfoImage(imageFileVO);
	                }
	            }
	        }
	        
	        // 성공 시 리다이렉트
	        mav.addObject("success", true);
	        mav.setViewName("redirect:/franchise/menuInfoForm?storeId="+storeId+"&ownerId="+regId);

	    } catch (Exception e) {
	        e.printStackTrace();
	        
	        // 실패 시 리다이렉트
	        mav.addObject("error", true);
	        mav.setViewName("redirect:/franchise/menuInfoForm?storeId="+storeId+"&ownerId="+regId);
	    }
	    return mav;
	}
	
}
