package com.spring.teamProject.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
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
	
	// 지역 배열 메서드
	private String[] getRegions() {
	    return new String[] {
	        "서울", "부산", "대구", "인천", "광주", "대전", "울산", "세종",
	        "경기", "강원", "충북", "충남", "전북", "전남", "경북", "경남", "제주"
	    };
	}

	// 타입 배열 메서드
	private String[] getTypes() {
	    return new String[] { "한식", "양식", "일식", "중식", "분식", "카페", "세계음식" };
	}

	@GetMapping("/searchStore")
	public ModelAndView searchStore(@RequestParam("keyword") String keyword) throws Exception {
		System.out.println("여기");
	    List<StoreVO> searchResults = storeService.searchByKeyword(keyword);
	    
	    for(int i=0;i<searchResults.size();i++) {
	    	System.out.println("검색 결과 식당 이름 : "+searchResults.get(i).getStoreName());
	    }

	    ModelAndView mav = ViewUtil.layout("store/storeList");
	    mav.addObject("storeList", searchResults);
	    mav.addObject("keyword", keyword);
	    mav.addObject("option","search");

	    return mav;
	}
	
	@GetMapping("/findNewStores")
	public ModelAndView findNewStore() throws Exception {
		List<StoreVO> storeList = storeService.findNewOpenStore();
		
		ModelAndView mav = ViewUtil.layout("store/storeList");
		mav.addObject("storeList", storeList);
		mav.addObject("option","newOpen");
		
		return mav;
	}
	
	@GetMapping("/userLikeStores")
	public ModelAndView userLikeStores() throws Exception {
		List<StoreVO> storeList = storeService.findUserLikeStores();
		
		ModelAndView mav = ViewUtil.layout("store/storeList");
		mav.addObject("storeList", storeList);
		mav.addObject("option","like");
		
		return mav;
	}

	 @PostMapping("/filterByRegion")
	 public ResponseEntity<?> filterByRegionAjax(@RequestParam("region") String region) throws Exception {
	        List<StoreVO> storeList = storeService.getStoresByRegion(region); // 지역으로 필터링된 가게 리스트 가져오기
	        Map<String, Object> response = new HashMap<>();
	        response.put("storeList", storeList);
	        response.put("region", region);
	        return ResponseEntity.ok(response);
	    }

	 @PostMapping("/filterByType")
	 public ResponseEntity<?> filterByTypeAjax(@RequestParam("type") String type) throws Exception {
	      List<StoreVO> storeList = storeService.getStoresByType(type); // 유형으로 필터링된 가게 리스트 가져오기
	      Map<String, Object> response = new HashMap<>();
	        response.put("storeList", storeList);
	        response.put("type", type);
	        return ResponseEntity.ok(response);
	 }

	// storeList 뷰로 직접 접속할 경우 option을 통해 데이터 세팅
	@GetMapping("/storeList")
	public ModelAndView showStoreList(@RequestParam(value = "option", required = false, defaultValue = "region") String option) {
	    
		ModelAndView mav = ViewUtil.layout("store/storeList");
		
	    if(option.equals("region")) {
	    	mav.addObject("option", "region");
	    	mav.addObject("regions", getRegions());
	    } else if(option.equals("type")) {
	    	mav.addObject("option", "type");
	    	mav.addObject("types", getTypes());
	    }
	    return mav;
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
