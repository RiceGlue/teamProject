package com.spring.teamProject.controller;

import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
import com.spring.teamProject.vo.StoreVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller("adminStoreController")
@RequestMapping(value="/franchise")
public class AdminStoreControllerImpl extends BaseController implements AdminStoreController {

	private static final String CURR_FILE_REPO_PATH = "C:\\project\\file_repo";

	@Autowired
	private AdminStoreService adminStoreService;

	@RequestMapping(value="/addStoreInfoForm")
	public ModelAndView addStoreInfoForm (@RequestParam("ownerId") long ownerId,HttpServletRequest req, HttpServletResponse res) throws Exception { //매장 정보 입력 폼 이동
		String viewName = (String)req.getAttribute("viewName");

		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("ownerId", ownerId);
		return mav;
	} 

	@RequestMapping(value="/addMenuForm")
	public ModelAndView addMenuForm (@RequestParam("storeId") long storeId, @RequestParam("ownerId") long ownerId, HttpServletRequest req, HttpServletResponse res) throws Exception { //메뉴 입력 폼 이동
		String viewName = (String)req.getAttribute("viewName");

		ModelAndView mav = ViewUtil.layout(viewName);
		System.out.println(storeId);
		mav.addObject("storeId", storeId);
		mav.addObject("ownerId", ownerId);
		return mav;
	}
	
	@RequestMapping(value={"/modifyStoreInfoForm", "/modifyMenuForm"})
	public ModelAndView modifyForm (@RequestParam("storeId") long storeId, HttpServletRequest req, HttpServletResponse res) throws Exception { //메뉴 입력 폼 이동
		String viewName = (String)req.getAttribute("viewName");
		//매장 정보 수정 원래 데이터 가져오기
		Map<String, Object> storeMap = new HashMap<>();
		
		StoreVO storeVO = adminStoreService.selectStoreInfo(storeId);
		List<ImageFileVO> imageList = adminStoreService.selectStoreImage(storeVO);
		
		storeMap.put("storeInfo", storeVO);
		storeMap.put("imageList", imageList);
		
		//메뉴 수정 원래 데이터 가져오기
		List<MenuVO> menuList = adminStoreService.selectMenuList(storeId);
		
		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("menuList", menuList);
		mav.addObject("storeMap",storeMap);
		return mav;
	}

	@Override
	@RequestMapping(value = "/addStoreInfo", method = RequestMethod.POST)
	public ModelAndView addStoreInfo(MultipartHttpServletRequest multiReq) throws Exception {
	    String directoryName = "store";
	    ModelAndView mav = new ModelAndView();
	    
	    multiReq.setCharacterEncoding("UTF-8");

	    Map<String, Object> storeInfo = new HashMap<>();
	    Enumeration<?> enu = multiReq.getParameterNames();
	    while (enu.hasMoreElements()) {
	        String name = (String) enu.nextElement();
	        String value = multiReq.getParameter(name);
	        System.out.println(name + ": " + value);
	        storeInfo.put(name, value);
	    }

	    // regId
	    String regIdstr = (String) storeInfo.get("ownerId");
	    long regId = Long.parseLong(regIdstr);

	    // fileType, displayNo
	    String[] fileTypes = multiReq.getParameterValues("fileType");
	    String[] displayNos = multiReq.getParameterValues("displayNo");

	    // 파일 업로드
	    List<ImageFileVO> imgFileList = upload(multiReq, directoryName);

	    // ➤ fileType/displayNo 매핑
	    for (int i = 0; i < imgFileList.size(); i++) {
	        ImageFileVO imageFileVO = imgFileList.get(i);

	        if (fileTypes != null && i < fileTypes.length) {
	            imageFileVO.setFileType(Boolean.parseBoolean(fileTypes[i]));
	            if(Boolean.parseBoolean(fileTypes[i])) {
	            	// 메인 이미지 파일 이름을 첫 번째로 지정
	            	storeInfo.put("fileName", imgFileList.get(i).getFileName());
	            }
	        }

	        if (displayNos != null && i < displayNos.length) {
	            try {
	                imageFileVO.setDisplayNo(Integer.parseInt(displayNos[i]));
	            } catch (NumberFormatException e) {
	                imageFileVO.setDisplayNo(0); // fallback
	            }
	        }

	        imageFileVO.setRegId(regId); //regId 설정
	    }

	    try {
	        long storeId = adminStoreService.addStoreInfo(storeInfo);

	        if (imgFileList != null && !imgFileList.isEmpty()) {
	            for (ImageFileVO imageFileVO : imgFileList) {
	                imageFileVO.setStoreId(storeId); //storeId 설정
	            }

	            adminStoreService.addStoreInfoImage(imgFileList);
	        }

	        mav.addObject("success",true);
	        mav.setViewName("redirect:/franchise/addStoreInfoForm?ownerId=" + regId);
	    } catch (Exception e) {
	        e.printStackTrace();
	        mav.addObject("error",true);
	        mav.setViewName("redirect:/franchise/addStoreInfoForm?ownerId=" + regId);
	    }
	    return mav;
	}


	@Override
	@RequestMapping(value = "/addMenu", method = RequestMethod.POST)
	public ModelAndView addMenu(MultipartHttpServletRequest multiReq) throws Exception { //메뉴 정보 입력
		String directoryName = "menu";
		
		multiReq.setCharacterEncoding("UTF-8");

	    String[] menuName = multiReq.getParameterValues("menuName");
	    String[] price = multiReq.getParameterValues("price");
	    String[] description = multiReq.getParameterValues("description");
	    String[] displayNo = multiReq.getParameterValues("displayNo");
	    
	    String storeIdStr = multiReq.getParameter("storeId");
	    String regIdStr = multiReq.getParameter("regId");

	    
	    // 기본 유효성 검사
	    if (menuName == null || menuName.length == 0) {
	        System.out.println("메뉴 항목이 제출되지 않았습니다.");
	        return new ModelAndView("redirect:/franchise/addMenuForm?storeId=" + storeIdStr + "&ownerId=" + regIdStr + "&error=true");
	    }

	    long storeId = 0;
	    long regId = 0;

	    if (storeIdStr != null && !storeIdStr.trim().isEmpty()) {
	        storeId = Long.parseLong(storeIdStr);
	    }

	    if (regIdStr != null && !regIdStr.trim().isEmpty()) {
	        regId = Long.parseLong(regIdStr);
	    }

	    List<ImageFileVO> fileList = upload(multiReq,directoryName);

	    ModelAndView mav = new ModelAndView();

	    try {
	        for (int i = 0; i < menuName.length; i++) {
	            MenuVO menuVO = new MenuVO();
	            menuVO.setStoreId(storeId);
	            menuVO.setMenuName(menuName[i]);
	            menuVO.setPrice(price != null && price.length > i ? price[i] : "0");
	            menuVO.setDescription(description != null && description.length > i ? description[i] : "");
	            menuVO.setDisplayNo(displayNo != null && displayNo.length > i ? Integer.parseInt(displayNo[i]) : 0);

	            if(fileList !=null && i<fileList.size()) {
	            	menuVO.setFileName(fileList.get(i).getFileName());
	            }

	            System.out.println(menuVO.getMenuName() + "," + menuVO.getPrice() + "," + menuVO.getDescription() + "," + menuVO.getDisplayNo() + "," + menuVO.getFileName());

	            // 메뉴 저장
	            adminStoreService.addMenu(menuVO);

	            long menuId = menuVO.getMenuId();
	            System.out.println("생성된 메뉴 ID : " + menuId);

	            if(fileList !=null && i<fileList.size()) {
	            	ImageFileVO imgFileVO = fileList.get(i);
	            	imgFileVO.setFileName(fileList.get(i).getFileName());
	            	imgFileVO.setDisplayNo(Integer.parseInt(displayNo[i]));
	            	imgFileVO.setRegId(regId);
	            	imgFileVO.setMenuId(menuId);
	            	imgFileVO.setStoreId(storeId);
 	
	            	adminStoreService.addMenuImage(imgFileVO);
	            }

	            System.out.println("메뉴 저장됨: " + menuName[i]);
	        }

	        mav.addObject("success", true);
	        mav.setViewName("redirect:/franchise/addMenuForm?storeId=" + storeId + "&ownerId=" + regId);
	        

	    } catch (Exception e) {
	        e.printStackTrace();
	        mav.addObject("error", true);
	        mav.setViewName("redirect:/franchise/addMenuForm?storeId=" + storeId + "&ownerId=" + regId);
	    }
	    
	    return mav;
	}
//	
//	@Override
//	@RequestMapping(value="/modifyMenu", method=RequestMethod.POST)
//	public ModelAndView modifyMenu(MultipartHttpServletRequest multiReq) throws Exception {
//		
//	}

}
