package com.spring.teamProject.controller;

import java.io.File;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.common.StringUtil;
import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.AdminStoreService;
import com.spring.teamProject.service.FtpService;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MenuVO;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.UserDetailsVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller("adminStoreController")
@RequestMapping(value="/franchise")
public class AdminStoreControllerImpl implements AdminStoreController {

	private static final String CURR_FILE_REPO_PATH = "C:\\project\\file_repo";

	@Autowired
	private AdminStoreService adminStoreService;
	
	@Autowired
	private FtpService ftpService;

	// application.properties에 설정된 파일 업로드 경로를 주입받습니다.
	@Value("${file.upload-dir}")
	private String uploadDir;

	
	@RequestMapping(value="/storeManage")
	public ModelAndView storeManage (@AuthenticationPrincipal UserDetailsVO userDetailsVO,@RequestParam("type") String type, HttpServletRequest req, HttpServletResponse res) throws Exception { //매장 정보 입력 폼 이동
		String viewName = (String)req.getAttribute("viewName");
		Long ownerId = null;
		List<StoreVO> storeList = new ArrayList<>();
		Map<String, Object> menuMap = new HashMap<>();

		ModelAndView mav = ViewUtil.adminLayout(viewName);
		
		
		if (userDetailsVO != null) {
			ownerId = (long) userDetailsVO.getMemberVO().getMemberId();
		}
		
		if(type.equals("store")) {
			int storeCount = adminStoreService.getStoreCount(ownerId);
			if(storeCount >= 1) {
				storeList = adminStoreService.getOwnerStore(ownerId);
			}
		} else if(type.equals("menu")) {
			storeList = adminStoreService.getOwnerStore(ownerId);
			for(int i=0;i<storeList.size();i++) {
				int menuCount = adminStoreService.getMenuCount(storeList.get(i).getStoreId());
				storeList.get(i).setMenuCount(menuCount);
			}
		}

		mav.addObject("ownerId", ownerId);
		mav.addObject("storeList", storeList);
		mav.addObject("type", type);
		return mav;
	}
	
	@RequestMapping(value="/addStoreInfoForm")
	public ModelAndView addStoreInfoForm (@AuthenticationPrincipal UserDetailsVO userDetailsVO,HttpServletRequest req, HttpServletResponse res) throws Exception { //매장 정보 입력 폼 이동
		String viewName = (String)req.getAttribute("viewName");
		Long ownerId = null;
		
		if (userDetailsVO != null) {
			ownerId = (long) userDetailsVO.getMemberVO().getMemberId();
		}
		
		ModelAndView mav = ViewUtil.adminLayout(viewName);
		mav.addObject("ownerId", ownerId);
		return mav;
	} 

	@RequestMapping(value="/addMenuForm")
	public ModelAndView addMenuForm (@AuthenticationPrincipal UserDetailsVO userDetailsVO, @RequestParam("storeId") long storeId, HttpServletRequest req, HttpServletResponse res) throws Exception { //메뉴 입력 폼 이동
		String viewName = (String)req.getAttribute("viewName");
		Long ownerId = null;
		
		if (userDetailsVO != null) {
			ownerId = (long) userDetailsVO.getMemberVO().getMemberId();
		}

		ModelAndView mav = ViewUtil.adminLayout(viewName);
		System.out.println(storeId);
		mav.addObject("storeId", storeId);
		mav.addObject("ownerId", ownerId);
		return mav;
	}
	
	@RequestMapping(value={"/modifyStoreInfoForm", "/modifyMenuForm"})
	public ModelAndView modifyForm (@RequestParam("storeId") long storeId, HttpServletRequest req, HttpServletResponse res) throws Exception {
	    String viewName = (String) req.getAttribute("viewName");

	    // 매장 정보 및 이미지 가져오기
	    StoreVO storeVO = adminStoreService.selectStoreInfo(storeId);
	    List<ImageFileVO> imageList = adminStoreService.selectStoreImage(storeVO);

	    // storeVO 안의 문자열 필드들을 List<String>으로 변환
	    List<String> closedList = StringUtil.StringSeparated(storeVO.getClosed());
	    List<String> operatingTimeList = StringUtil.StringSeparated(storeVO.getOperatingTime());
	    List<String> breakTimeList = StringUtil.StringSeparated(storeVO.getBreakTime());
	    List<String> lastOrderList = StringUtil.StringSeparated(storeVO.getLastOrder());
	    List<String> amenitiesList = StringUtil.StringSeparated(storeVO.getAmenities());

	    // storeMap에 정보 저장
	    Map<String, Object> storeMap = new HashMap<>();
	    storeMap.put("storeInfo", storeVO);
	    storeMap.put("imageList", imageList);
	    
	    storeMap.put("closedList", closedList);
	    storeMap.put("operatingTimeList", operatingTimeList);
	    storeMap.put("breakTimeList", breakTimeList);
	    storeMap.put("lastOrderList", lastOrderList);
	    storeMap.put("amenitiesList", amenitiesList);

	    // 메뉴 정보 가져오기
	    List<MenuVO> menuList = adminStoreService.selectMenuList(storeId);

	    // 모델과 뷰 반환
	    ModelAndView mav = ViewUtil.adminLayout(viewName);
	    mav.addObject("menuList", menuList);
	    mav.addObject("storeMap", storeMap);

	    return mav;
	}


	@Override
	@RequestMapping(value = "/addStoreInfo", method = RequestMethod.POST)
	public ModelAndView addStoreInfo(@AuthenticationPrincipal UserDetailsVO userDetailsVO, MultipartHttpServletRequest multiReq) throws Exception {
		ModelAndView mav = new ModelAndView();
		String directoryName = "store";
		multiReq.setCharacterEncoding("UTF-8");
		
		Map<String, Object> storeInfo = new HashMap<>();
		Enumeration<?> enu = multiReq.getParameterNames();
		
		while (enu.hasMoreElements()) {
			String name = (String) enu.nextElement();
			String value = multiReq.getParameter(name);
			System.out.println(name + ": " + value);
			storeInfo.put(name, value);
		}
		
		String regIdstr = (String) storeInfo.get("ownerId");
		long regId = Long.parseLong(regIdstr);
		
		String[] fileTypes = multiReq.getParameterValues("fileType");
		String[] displayNos = multiReq.getParameterValues("displayNo");
		
		List<MultipartFile> files = multiReq.getFiles("fileName[]");
		List<ImageFileVO> imgFileList = new ArrayList<>();
		
		for (MultipartFile file : files) {
			if (file.isEmpty()) continue;
			
			String originalFilename = file.getOriginalFilename();
			String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
			String savedFilename = UUID.randomUUID().toString() + extension;
			
			File tempFile = File.createTempFile("upload-", extension);
			file.transferTo(tempFile);
			
			boolean uploadSuccess = ftpService.uploadFile(tempFile, directoryName, savedFilename);
			tempFile.delete();
			
			if (uploadSuccess) {
				ImageFileVO imageFileVO = new ImageFileVO();
				imageFileVO.setFileName(savedFilename);
				imgFileList.add(imageFileVO);
			} else {
				System.err.println("FTP 업로드 실패: " + originalFilename);
			}
		}
		for (int i = 0; i < imgFileList.size(); i++) {
			ImageFileVO imageFileVO = imgFileList.get(i);
			if (fileTypes != null && i < fileTypes.length) {
				imageFileVO.setFileType(Boolean.parseBoolean(fileTypes[i]));
				if (Boolean.parseBoolean(fileTypes[i])) {
					storeInfo.put("fileName", imgFileList.get(i).getFileName());
				}
			}
			if (displayNos != null && i < displayNos.length) {
				try {
					imageFileVO.setDisplayNo(Integer.parseInt(displayNos[i]));
				} catch (NumberFormatException e) {
					imageFileVO.setDisplayNo(0);
				}
			}
			
			imageFileVO.setRegId(regId);
		}
		try {
			long storeId = adminStoreService.addStoreInfo(storeInfo);
			if (!imgFileList.isEmpty()) {
				for (ImageFileVO imageFileVO : imgFileList) {
					imageFileVO.setStoreId(storeId);
				}
				adminStoreService.addStoreInfoImage(imgFileList);
			}
			mav.addObject("success", true);
			mav.setViewName("redirect:/franchise/addStoreInfoForm?ownerId=" + regId);
		} catch (Exception e) {
			e.printStackTrace();
			mav.addObject("error", true);
			mav.setViewName("redirect:/franchise/addStoreInfoForm?ownerId=" + regId);
		}
		return mav;
	}



	@Override
	@RequestMapping(value = "/addMenu", method = RequestMethod.POST)
	public ModelAndView addMenu(@AuthenticationPrincipal UserDetailsVO userDetailsVO, MultipartHttpServletRequest multiReq) throws Exception {
		String directoryName = "menu";
		multiReq.setCharacterEncoding("UTF-8");
		
		String[] menuName = multiReq.getParameterValues("menuName");
		String[] price = multiReq.getParameterValues("price");
		String[] description = multiReq.getParameterValues("description");
		String[] displayNo = multiReq.getParameterValues("displayNo");
		
		String storeIdStr = multiReq.getParameter("storeId");
		String regIdStr = multiReq.getParameter("regId");
		
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
		
		// ✅ FTP 방식 파일 업로드 처리
		List<MultipartFile> files = multiReq.getFiles("fileName[]");
		List<ImageFileVO> fileList = new ArrayList<>();
		
		for (MultipartFile file : files) {
			if (file.isEmpty()) continue;
			
			String originalFilename = file.getOriginalFilename();
			String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
			String savedFilename = UUID.randomUUID().toString() + extension;
			
			File tempFile = File.createTempFile("upload-", extension);
			file.transferTo(tempFile);
			
			boolean uploadSuccess = ftpService.uploadFile(tempFile, directoryName, savedFilename);
			tempFile.delete();
			
			if (uploadSuccess) {
				ImageFileVO imageFileVO = new ImageFileVO();
				imageFileVO.setFileName(savedFilename);
				fileList.add(imageFileVO);
			} else {
				System.err.println("FTP 업로드 실패: " + originalFilename);
			}
		}
		
		ModelAndView mav = new ModelAndView();
		
		try {
			for (int i = 0; i < menuName.length; i++) {
				MenuVO menuVO = new MenuVO();
				menuVO.setStoreId(storeId);
				menuVO.setMenuName(menuName[i]);
				menuVO.setPrice(price != null && price.length > i ? price[i] : "0");
				menuVO.setDescription(description != null && description.length > i ? description[i] : "");
				menuVO.setDisplayNo(displayNo != null && displayNo.length > i ? Integer.parseInt(displayNo[i]) : 0);
				
				if (fileList != null && i < fileList.size()) {
					menuVO.setFileName(fileList.get(i).getFileName());
				}
				
				System.out.println(menuVO.getMenuName() + "," + menuVO.getPrice() + "," + menuVO.getDescription() + "," + menuVO.getDisplayNo() + "," + menuVO.getFileName());
				
				adminStoreService.addMenu(menuVO);
				long menuId = menuVO.getMenuId();
				System.out.println("생성된 메뉴 ID : " + menuId);
				
				if (fileList != null && i < fileList.size()) {
					ImageFileVO imgFileVO = fileList.get(i);
					imgFileVO.setFileName(fileList.get(i).getFileName());
					imgFileVO.setDisplayNo(displayNo != null && displayNo.length > i ? Integer.parseInt(displayNo[i]) : 0);
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

	
	@Override
	@RequestMapping(value="/modifyStoreInfo", method = RequestMethod.POST)
	public ModelAndView modifyStoreInfo(MultipartHttpServletRequest multiReq) throws Exception {
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
	
		String regIdstr = (String) storeInfo.get("ownerId");
		long regId = Long.parseLong(regIdstr);
		
		String storeIdstr = (String) storeInfo.get("storeId");
		long storeId = Long.parseLong(storeIdstr);
	
		String[] imageIds = multiReq.getParameterValues("imageId");
		String[] fileTypes = multiReq.getParameterValues("fileType");
		String[] displayNos = multiReq.getParameterValues("displayNo");
		String[] originalFileNames = multiReq.getParameterValues("originalFileName");
	
		List<MultipartFile> files = multiReq.getFiles("fileName");
		List<ImageFileVO> addImgFileList = new ArrayList<>();
	
		try {
			for (int i = 0; i < files.size(); i++) {
				
				MultipartFile file = files.get(i);
				
				String imageId = (imageIds != null && i < imageIds.length) ? imageIds[i] : null;
				String fileType = (fileTypes != null && i < fileTypes.length) ? fileTypes[i] : null;
				String displayNo = (displayNos != null && i < displayNos.length) ? displayNos[i] : "0";
				String originalFileName = (originalFileNames != null && i < originalFileNames.length) ? originalFileNames[i] : null;
			
				boolean hasFile = file != null && !file.isEmpty();
				boolean isFileTypeTrue = "true".equalsIgnoreCase(fileType);
			
				if (hasFile) {
					String originalFilename = file.getOriginalFilename();
					String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
					String savedFilename = UUID.randomUUID().toString() + extension;
				
					File tempFile = File.createTempFile("upload-", extension);
					file.transferTo(tempFile);
				
					boolean uploadSuccess = ftpService.uploadFile(tempFile, directoryName, savedFilename);
					tempFile.delete();
				
					if (uploadSuccess) {
						if (imageId != null && !imageId.isEmpty()) {
							ImageFileVO imageFileVO = new ImageFileVO();
							imageFileVO.setImageId(Integer.parseInt(imageId));
							imageFileVO.setFileName(savedFilename);
							imageFileVO.setFileType(isFileTypeTrue);
							
							adminStoreService.modifyImage(imageFileVO);
						
							if (originalFileName != null && !originalFileName.isEmpty()) {
								ftpService.deleteFile(directoryName, originalFileName);
							}
						
							if (isFileTypeTrue) {
								storeInfo.put("fileName", savedFilename);
							}
						} else {
							ImageFileVO imageFileVO = new ImageFileVO();
							imageFileVO.setFileName(savedFilename);
							imageFileVO.setDisplayNo(Integer.parseInt(displayNo));
							imageFileVO.setFileType(isFileTypeTrue);
							imageFileVO.setStoreId(storeId);
							imageFileVO.setRegId(regId);
							addImgFileList.add(imageFileVO);
						
							if (isFileTypeTrue) {
								storeInfo.put("fileName", savedFilename);
							}
						}
					}
				} else if (imageId != null && !imageId.isEmpty()) {
					
					ImageFileVO orignFileVO = adminStoreService.selectImage(Long.parseLong(imageId));
					if (orignFileVO != null && orignFileVO.isFileType() != isFileTypeTrue) {
						ImageFileVO imageFileVO = new ImageFileVO();
						imageFileVO.setImageId(Integer.parseInt(imageId));
						imageFileVO.setFileType(isFileTypeTrue);
						adminStoreService.modifyFileType(imageFileVO);
					}
				}
			}
		
			if (!addImgFileList.isEmpty()) {
				adminStoreService.addStoreInfoImage(addImgFileList);
			}
		
			if (storeInfo.get("fileName") != null && !((String) storeInfo.get("fileName")).isEmpty()) {
				adminStoreService.modifyStoreInfoWithImage(storeInfo);
			} else {
				adminStoreService.modifyStoreInfo(storeInfo);
			}
		
			mav.addObject("success", true);
			mav.setViewName("redirect:/franchise/modifyStoreInfoForm?storeId=" + storeId);
		} catch (Exception e) {
		e.printStackTrace();
			mav.addObject("error", true);
			mav.setViewName("redirect:/franchise/modifyStoreInfoForm?storeId=" + storeId);
		}
	
		return mav;
	}
	
	@Override
	@RequestMapping(value="/modifyMenu", method=RequestMethod.POST)
	public ModelAndView modifyMenu(MultipartHttpServletRequest multiReq) throws Exception {
		ModelAndView mav = new ModelAndView();
		multiReq.setCharacterEncoding("UTF-8");
	
		String storeIdStr = multiReq.getParameter("storeId");
		long storeId = Long.parseLong(storeIdStr);
		
		String menuIdStr = multiReq.getParameter("menuId");
		long menuId = Long.parseLong(menuIdStr);
		
		String menuName = multiReq.getParameter("menuName");
		String price = multiReq.getParameter("price");
		String description = multiReq.getParameter("description");
		String originalFileName = multiReq.getParameter("originalFileName");
		
		long imageId = adminStoreService.selectImageId(menuId);
	
		String directoryName = "menu";
		File tempFile = null;
	
		try {
			MultipartFile imageFile = multiReq.getFile("fileName");
			String savedFileName = null;
		
			if (imageFile != null && !imageFile.isEmpty()) {
				String originalFilename = imageFile.getOriginalFilename();
				String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
				savedFileName = UUID.randomUUID().toString() + extension;
			
				tempFile = File.createTempFile("upload-", extension);
				imageFile.transferTo(tempFile);
			
				boolean uploadSuccess = ftpService.uploadFile(tempFile, directoryName, savedFileName);
				tempFile.delete();
			
				if (!uploadSuccess) {
					throw new Exception("FTP 업로드 실패");
				}
			
				if (originalFileName != null && !originalFileName.trim().isEmpty()) {
					ftpService.deleteFile(directoryName, originalFileName);
				}
			
				MenuVO menuVO = new MenuVO();
				menuVO.setMenuId(menuId);
				menuVO.setMenuName(menuName);
				menuVO.setPrice(price);
				menuVO.setDescription(description);
				menuVO.setFileName(savedFileName);
			
				ImageFileVO imgFileVO = new ImageFileVO();
				imgFileVO.setFileName(savedFileName);
				imgFileVO.setFileType(false);
				imgFileVO.setImageId(imageId);
			
				adminStoreService.modifyMenuWithImage(menuVO);
				adminStoreService.modifyImage(imgFileVO);
		
			} else {
				MenuVO menuVO = new MenuVO();
				menuVO.setMenuId(menuId);
				menuVO.setMenuName(menuName);
				menuVO.setPrice(price);
				menuVO.setDescription(description);
				adminStoreService.modifyMenu(menuVO);
			}
		
			mav.addObject("success", true);
			mav.setViewName("redirect:/franchise/modifyMenuForm?storeId=" + storeId);
		
		} catch (Exception e) {
			e.printStackTrace();
			mav.addObject("error", true);
			mav.setViewName("redirect:/franchise/modifyMenuForm?storeId=" + storeId);
		} finally {
			if (tempFile != null && tempFile.exists()) {
				tempFile.delete();
			}
		}
		return mav;
	}

	
	@Override
	@RequestMapping(value="/deleteMenu", method=RequestMethod.POST)
	public ModelAndView deleteMenu(@RequestParam("menuId") long menuId, @RequestParam("storeId") long storeId, @RequestParam("fileName") String fileName) throws Exception {
		ModelAndView mav = new ModelAndView();
		String directoryName = "menu";
	
		try {
			if (fileName != null && !fileName.trim().isEmpty()) {
			ftpService.deleteFile(directoryName, fileName);
		}
	
		adminStoreService.deleteMenu(menuId);
	
		mav.addObject("success", true);
		mav.setViewName("redirect:/franchise/modifyMenuForm?storeId=" + storeId);
	
		} catch (Exception e) {
			e.printStackTrace();
			mav.addObject("error", true);
			mav.setViewName("redirect:/franchise/modifyMenuForm?storeId=" + storeId);
		}
	
		return mav;
	}
}