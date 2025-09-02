package com.spring.teamProject.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal; // 💡 AuthenticationPrincipal 추가
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
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
	@RequestMapping(value = "/storeList", method = RequestMethod.GET)
	public ModelAndView storeList(@AuthenticationPrincipal UserDetailsVO userDetailsVO, @RequestParam("option") String option,@RequestParam("keyword") String keyword,HttpServletRequest req,HttpServletResponse res) throws Exception {

	    String viewName = (String) req.getAttribute("viewName");
	    ModelAndView mav = ViewUtil.layout(viewName);

	    // 로그인 사용자 ID 설정
	    if (userDetailsVO != null) {
	        Long memberId = (long) userDetailsVO.getMemberVO().getMemberId();
	        mav.addObject("memberId", memberId);
	    }

	    // 옵션에 따른 검색 처리
	    if ("region".equals(option)&&keyword.isEmpty()) {
	    	String[] regions = { "서울", "부산", "대구", "인천", "광주", "대전", "울산", "세종", "경기", "강원", "충북", "충남", "전북", "전남", "경북", "경남", "제주"};
	    	mav.addObject("regions",regions);
	    } else if ("search".equals(option)) {
	        mav.addObject("menulist", storeService.selectStoreByMenu(keyword));
	        mav.addObject("addrlist", storeService.selectStoreByAddr(keyword));
	        mav.addObject("namelist", storeService.selectStoreByName(keyword));
	    } else if ("storeType".equals(option)) {
	        mav.addObject("typelist", storeService.selectStoreByType(keyword));
	    } else if ("userLocation".equals(option)) {
	        mav.addObject("userLocationlist", searchStoreNearUser(keyword));
	    }

	    // 검색 정보 전달
	    mav.addObject("option", option);
	    mav.addObject("keyword", keyword);

	    return mav;
	}
	
	@PostMapping("/regionList")
	@ResponseBody
	public Map<String, Object> getStoreListByRegion(@RequestParam String keyword) throws Exception {
	    Map<String, Object> response = new HashMap<>();
	    List<StoreVO> regionList = storeService.selectStoreByRegion(keyword);
	    response.put("regionList", regionList);
	    return response;
	}


	@Override
	@RequestMapping(value="/storeDetail", method=RequestMethod.GET)
	public ModelAndView storeDetail(@ModelAttribute StoreVO storeVO, @AuthenticationPrincipal UserDetailsVO userDetailsVO, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");
		
		String roadAddress = null;
		String storeType = null;
		Long memberId = null;
		
		ModelAndView mav = ViewUtil.layout(viewName);

		Map storeMap = storeService.storeDetail(storeVO);
		
		Long storeId = storeVO.getStoreId();
		int currentWaitingCount = waitingService.getCurrentWaitingCount(storeId);

		if (userDetailsVO != null) {
			memberId = (long) userDetailsVO.getMemberVO().getMemberId();
			mav.addObject("memberId", memberId);
		}

		StoreVO storedStoreVO = (StoreVO) storeMap.get("store");
		if (storedStoreVO != null) {
			roadAddress = getAddress(storedStoreVO.getRoadAddress());
		    storeType=storedStoreVO.getStoreType();
		}

		
		List<StoreVO> nearByStoreList = storeService.searchStoreNearUser(roadAddress);
		List<StoreVO> storeTypeList = storeService.searchStoreSameStoreType(storedStoreVO);
		
		mav.addObject("storeMap", storeMap);
		mav.addObject("currentWaitingCount", currentWaitingCount);
		mav.addObject("nearByStoreList", nearByStoreList);
		mav.addObject("storeTypeList", storeTypeList);
		
		return mav;
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
