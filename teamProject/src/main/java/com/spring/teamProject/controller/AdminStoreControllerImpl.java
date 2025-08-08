package com.spring.teamProject.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

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
	public ModelAndView form (@RequestParam("ownerId") long ownerId, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");

		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("ownerId", ownerId);
		return mav;
	}
	
	@RequestMapping(value="/storeInfoForm", method=RequestMethod.POST)
	public String addStoreInfo(@ModelAttribute StoreVO storeVO, HttpServletRequest req, RedirectAttributes reAttr) throws Exception {
		
		MultipartHttpServletRequest multiReq = (MultipartHttpServletRequest) req;
		List<ImageFileVO> imgFileList = upload(multiReq);
		
		if(!imgFileList.isEmpty()) {
			storeVO.setFileName(imgFileList.get(0).getFileName());
		}
		
		adminStoreService.addStoreInfo(storeVO);
		
		long storeId = storeVO.getStoreId();
		
		for(ImageFileVO imgVO : imgFileList) {
			imgVO.setStoreId(storeId);
		}
		
		if(!imgFileList.isEmpty()) {
			adminStoreService.addStoreInfoImage(imgFileList);
		}
		
		reAttr.addFlashAttribute("success", true);
		
		return "redirect:/franchise/storeInfoForm";
	}
	
}
