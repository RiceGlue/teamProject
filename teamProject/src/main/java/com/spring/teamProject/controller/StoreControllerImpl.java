package com.spring.teamProject.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.StoreServiceImpl;
import com.spring.teamProject.vo.StoreVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller
@RequestMapping(value="/store")
public class StoreControllerImpl implements StoreController {

	@Autowired
	private StoreServiceImpl storeService;

	@Override
	@RequestMapping(value="/storeRegionList", method=RequestMethod.GET)
	public ModelAndView SelectRegionStoreList (@RequestParam("region") String region, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");
		
		List<StoreVO> storelist = storeService.storeRegionList(region);
		
		for(int i=0;i<storelist.size();i++) {
			System.out.println(storelist.get(i).getAddress());
		}
		
		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("region",region);
		mav.addObject("storelist",storelist);
		return mav;
	}
	
	@Override
	@RequestMapping(value="/storeDetail", method=RequestMethod.GET)
	public ModelAndView storeDetail(@RequestParam("storeId") long storeId, HttpServletRequest req, HttpServletResponse res) throws Exception {
		String viewName = (String)req.getAttribute("viewName");
		
		Map storeMap = storeService.storeDetail(storeId);
		
		ModelAndView mav = ViewUtil.layout(viewName);
		mav.addObject("storeMap", storeMap);
		return mav;
	}

	/**
     * 매장 상세 페이지를 보여주는 메서드
     * GET /store/storeDetail.do?storeId={storeId}
     */
    @GetMapping(value="/storeDetail.do")
    public String storeDetail(@RequestParam("storeId") Long storeId, Model model) {
        StoreVO store = getDummyStoreInfo(storeId); // 가데이터 매장 정보 가져오기
        model.addAttribute("store", store); // 모델에 매장 정보 추가

        // JSP 파일 경로
        return "store/storeDetail"; // src/main/webapp/WEB-INF/views/store/storeDetail.jsp 를 가리킴
    }
    // JSP에 전달할 가데이터 StoreVO 생성
    private StoreVO getDummyStoreInfo(Long storeId) {
        StoreVO store = new StoreVO();
        store.setStoreId(storeId);
        store.setStoreName("더미 매장 " + storeId); // 매장 ID에 따라 이름 변경
        store.setAddress("서울시 가짜구 더미동 " + storeId + "번지");
        store.setDescription("이것은 매장 " + storeId + "의 상세 설명입니다. 다양한 메뉴와 편안한 분위기를 자랑합니다.");
        store.setOperationType("ALL"); // ALL, DINE_IN, TAKE_OUT 등
        // 실제 프로젝트에서는 DB에서 데이터를 가져옵니다.
        return store;
    }

	public ModelAndView form(@RequestParam("store_id") String store_id, HttpServletRequest req, HttpServletResponse res) throws Exception {
		ModelAndView mav = ViewUtil.layout("franchise/");
		return mav;
	}

}
