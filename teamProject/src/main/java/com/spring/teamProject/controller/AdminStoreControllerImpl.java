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
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.common.BaseController;
import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.AdminStoreService;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MemberVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
  
@Controller("adminStoreController")
@RequestMapping(value="/franchise")
public class AdminStoreControllerImpl extends BaseController implements AdminStoreController {
	
	private static final String CURR_IMAGE_REPO_PATH = "C:\\project\\file_repo";
	
	@Autowired
	private AdminStoreService adminStoreService;
	
	@RequestMapping(value="/storeInfoForm")
	public ModelAndView form (@RequestParam("storeId") long storeId, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");
		
		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("storeId", storeId);
		return mav;
	}
	
	@Override
	@RequestMapping(value="/addStoreInfo", method=RequestMethod.POST)
	public ResponseEntity addStoreInfo (@RequestParam("storeId") long storeId, MultipartHttpServletRequest multiReq, HttpServletResponse res) throws Exception {
		multiReq.setCharacterEncoding("utf-8");
		res.setContentType("text/html; charset=UTF-8");
		String imageFileName=null;
		
		Map storeInfoMap  = new HashMap<>();
		storeInfoMap .put("storeId",storeId);
		Enumeration enu=multiReq.getParameterNames();
		while(enu.hasMoreElements()){
			String name=(String)enu.nextElement();
			String value=multiReq.getParameter(name);
			storeInfoMap .put(name,value);
		}
		
		HttpSession session = multiReq.getSession();
		MemberVO memberVO = (MemberVO) session.getAttribute("memberInfo");
		long reg_id = memberVO.getMemberId();
		
		List<ImageFileVO> imageFileList =upload(multiReq);
		if(imageFileList!= null && imageFileList.size()!=0) {
			for(ImageFileVO imageFileVO : imageFileList) {
				imageFileVO.setRegId(reg_id);
			}
			storeInfoMap .put("imageFileList", imageFileList);
		}
		
		String message = null;
		ResponseEntity resEntity = null;
		HttpHeaders responseHeaders = new HttpHeaders();
		responseHeaders.add("Content-Type", "text/html; charset=utf-8");
		try {
			long info_id = adminStoreService.addStoreInfo(storeInfoMap );
			if(imageFileList!=null && imageFileList.size()!=0) {
				for(ImageFileVO  imageFileVO:imageFileList) {
					imageFileName = imageFileVO.getFileName();
					File srcFile = new File(CURR_IMAGE_REPO_PATH+"\\"+"temp"+"\\"+imageFileName);
					File destDir = new File(CURR_IMAGE_REPO_PATH+"\\"+storeId);
					FileUtils.moveFileToDirectory(srcFile, destDir,true);
				}
			}
			message= "<script>";
			message += " alert('가게 정보가 등록되었습니다.');";
			message +=" location.href='"+multiReq.getContextPath()+"/admin/goods/addNewGoodsForm.do';";
			message +="</script>";
		}catch(Exception e) {
			if(imageFileList!=null && imageFileList.size()!=0) {
				for(ImageFileVO  imageFileVO:imageFileList) {
					imageFileName = imageFileVO.getFileName();
					File srcFile = new File(CURR_IMAGE_REPO_PATH+"\\"+"temp"+"\\"+imageFileName);
					srcFile.delete();
				}
			}
			
			message= "<script>";
			message += " alert('오류가 발생했습니다. 다시 시도해 주세요.');";
			message +=" location.href='"+multiReq.getContextPath()+"/admin/goods/addNewGoodsForm.do';";
			message +=("</script>");
			e.printStackTrace();
		}
		resEntity =new ResponseEntity(message, responseHeaders, HttpStatus.OK);
		return resEntity;
	}

}
