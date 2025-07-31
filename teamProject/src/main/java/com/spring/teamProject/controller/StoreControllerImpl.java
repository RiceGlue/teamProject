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
			System.out.println(storelist.get(i).getStoreName());
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

        // JSP 파일 경로
        return "store/storeDetail"; // src/main/webapp/WEB-INF/views/store/storeDetail.jsp 를 가리킴
    }

    @GetMapping(value="/storeList.do")
    public ModelAndView storeList(HttpServletRequest req, HttpServletResponse res) throws Exception {
        ModelAndView mav = ViewUtil.layout("store/storeList");
        return mav;
    }

	public ModelAndView form(@RequestParam("store_id") String store_id, HttpServletRequest req, HttpServletResponse res) throws Exception {
		ModelAndView mav = ViewUtil.layout("franchise/");
		return mav;
	}

}
