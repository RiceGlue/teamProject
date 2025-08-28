package com.spring.teamProject.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal; // 💡 AuthenticationPrincipal 추가
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.ReviewServiceImpl;
import com.spring.teamProject.service.StoreServiceImpl;
import com.spring.teamProject.service.WaitingService;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.UserDetailsVO; // 💡 UserDetailsVO 추가

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller
@RequestMapping(value="/store")
public class StoreControllerImpl implements StoreController {

	@Autowired
	private StoreServiceImpl storeService;

	@Autowired
    private WaitingService waitingService;
	
	@Autowired
	private ReviewServiceImpl reviewService;

	@Override
	@RequestMapping(value="/storeList", method=RequestMethod.GET)
	public ModelAndView storeList ( @AuthenticationPrincipal UserDetailsVO userDetailsVO, @RequestParam("option") String option, @RequestParam("keyword") String keyword, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");

		List<StoreVO> regionlist = null ;
		List<StoreVO> menulist = null ;
		List<StoreVO> addrlist = null ;
		List<StoreVO> namelist = null ;
		List<StoreVO> typelist = null ;
		List<StoreVO> userLocationlist = null ;

		if(option.equals("region")) {
			regionlist = storeService.selectStoreByRegion(keyword);
		} else if(option.equals("search")) {
			menulist = storeService.selectStoreByMenu(keyword);
			addrlist = storeService.selectStoreByAddr(keyword);
			namelist = storeService.selectStoreByName(keyword);
		} else if(option.equals("storeType")) {
			typelist = storeService.selectStoreByType(keyword);
		} else if(option.equals("userLocation")) {
			userLocationlist = searchStoreNearUser(keyword);
		}

		ModelAndView mav = ViewUtil.layout(viewName);
		
		if (userDetailsVO != null) {
			Long memberId = (long) userDetailsVO.getMemberVO().getMemberId();
			mav.addObject("memberId", memberId);
		}
		
		mav.addObject("option", option);
		mav.addObject("keyword",keyword);
		mav.addObject("regionlist",regionlist);
		mav.addObject("menulist",menulist);
		mav.addObject("addrlist",addrlist);
		mav.addObject("namelist",namelist);
		mav.addObject("userLocationlist",userLocationlist);
		return mav;
	}

	@Override
	@RequestMapping(value="/storeDetail", method=RequestMethod.GET)
	public ModelAndView storeDetail(@ModelAttribute StoreVO storeVO, @AuthenticationPrincipal UserDetailsVO userDetailsVO, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");
		String roadAddress = null;
		String storeType = null;
		
		ModelAndView mav = ViewUtil.layout(viewName);

		Map storeMap = storeService.storeDetail(storeVO);
		
		Long storeId = storeVO.getStoreId();
		int currentWaitingCount = waitingService.getCurrentWaitingCount(storeId);

		if (userDetailsVO != null) {
			Long memberId = (long) userDetailsVO.getMemberVO().getMemberId();
			mav.addObject("memberId", memberId);
		}

		StoreVO storedStoreVO = (StoreVO) storeMap.get("store");
		if (storedStoreVO != null) {
			roadAddress = getAddress(storedStoreVO.getRoadAddress());
		    storeType=storedStoreVO.getStoreType();
		    System.out.println("Address from storeVO inside storeMap: " + roadAddress);
		}

		
		List<StoreVO> nearByStoreList = storeService.searchStoreNearUser(roadAddress);
		List<StoreVO> storeTypeList = storeService.searchStoreSameStoreType(storedStoreVO);
		
		mav.addObject("storeMap", storeMap);
		mav.addObject("currentWaitingCount", currentWaitingCount);
		mav.addObject("nearByStoreList", nearByStoreList);
		mav.addObject("storeTypeList", storeTypeList);

		return mav;
	}


	@RequestMapping(value="/likeReview", method=RequestMethod.POST)
	@ResponseBody
	public int likeReview(@RequestBody Map<String, Object> payload) throws Exception {
	    long reviewId = Long.parseLong(payload.get("reviewId").toString());
	    boolean isLiked = Boolean.parseBoolean(payload.get("isLiked").toString());

	    int updatedLikes = reviewService.modifyReviewLikes(reviewId, isLiked);
	    return updatedLikes;
	}

		
	@GetMapping("/searchStoreNearUser")
	@ResponseBody
	public List<StoreVO> searchStoreNearUser(@RequestParam("location") String location) {
		System.out.println("사용자 주소 : " +location);
		
		List<StoreVO> store = storeService.searchStoreNearUser(location);
	    return store;// 서비스에서 LIKE '%location%' 검색
	}
	
	public static String getAddress(String fullRoadAddress) {
        if (fullRoadAddress == null || fullRoadAddress.trim().isEmpty()) {
            return "";
        }

        String[] parts = fullRoadAddress.trim().split("\\s+");
        if (parts.length >= 3) {
            return parts[0] + " " + parts[1];
        } else {
            return fullRoadAddress; // fallback: 가능한 만큼만 리턴
        }
    }

}
