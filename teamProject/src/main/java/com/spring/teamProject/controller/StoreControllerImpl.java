package com.spring.teamProject.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal; // 💡 AuthenticationPrincipal 추가
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.StoreServiceImpl;
import com.spring.teamProject.service.WaitingService;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.UserDetailsVO; // 💡 UserDetailsVO 추가

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping(value="/store")
public class StoreControllerImpl implements StoreController {

	@Autowired
	private StoreServiceImpl storeService;

	@Autowired
    private WaitingService waitingService;

	@Override
	@RequestMapping(value="/storeList", method=RequestMethod.GET)
	public ModelAndView storeList (@RequestParam("option") String option, @RequestParam("keyword") String keyword, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");

		List<StoreVO> regionlist = null ;
		List<StoreVO> menulist = null ;
		List<StoreVO> addrlist = null ;
		List<StoreVO> namelist = null ;
		List<StoreVO> typelist = null ;

		if(option.equals("region")) {
			regionlist = storeService.selectStoreByRegion(keyword);
		} else if(option.equals("search")) {
			menulist = storeService.selectStoreByMenu(keyword);
			addrlist = storeService.selectStoreByAddr(keyword);
			namelist = storeService.selectStoreByName(keyword);
		} else if(option.equals("storeType")) {
			typelist = storeService.selectStoreByType(keyword);
		}

		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("option", option);
		mav.addObject("keyword",keyword);
		mav.addObject("regionlist",regionlist);
		mav.addObject("menulist",menulist);
		mav.addObject("addrlist",addrlist);
		mav.addObject("namelist",namelist);
		return mav;
	}

	@Override
	@RequestMapping(value="/storeDetail", method=RequestMethod.GET)
	public ModelAndView storeDetail(@ModelAttribute StoreVO storeVO, @AuthenticationPrincipal UserDetailsVO userDetailsVO, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");

		ModelAndView mav = ViewUtil.layout(viewName);

		Map storeMap = storeService.storeDetail(storeVO);

		Long storeId = storeVO.getStoreId();
		int currentWaitingCount = waitingService.getCurrentWaitingCount(storeId);

		if (userDetailsVO != null) {
			Long memberId = (long) userDetailsVO.getMemberVO().getMemberId();
			mav.addObject("memberId", memberId);
		}

		mav.addObject("storeMap", storeMap);
		mav.addObject("currentWaitingCount", currentWaitingCount);

		return mav;
	}


//	@RequestMapping(value="/likeReview" , method=RequestMethod.POST)
//	public Map<String, Object> likeReview(@RequestBody Map<String, Object> payload, HttpSession session) {
//		Long reviewId = Long.valueOf(payload.get("reviewId").toString());
//		String userId = (String) session.getAttribute("loginId");
//

//		boolean alreadyLiked = storeService.likeReview(reviewId, userId);
//
//		Map<String, Object> response = new HashMap<>();
//		if (alreadyLiked) {
//			response.put("success", false);
//		} else {
//			int updatedCount = storeService.increaseCountReview(reviewId, userId);
//			response.put("success", true);
//			response.put("likeCount", updatedCount);
//		}
//		return response;
//	}


}
