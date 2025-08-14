package com.spring.teamProject.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.teamProject.dao.StoreDAO;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MenuVO;
import com.spring.teamProject.vo.ReservationSettingVO;
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.StoreVO;

@Service
public class StoreServiceImpl implements StoreService{
	
	@Autowired
	private StoreDAO storeDAO;
	
	@Override
	public List<StoreVO> selectStoreByRegion(String keyword) throws Exception {
		List<StoreVO> regionlist = storeDAO.selectStoreByRegion(keyword);
		return regionlist;
	}
	
	@Override
	public List<StoreVO> selectStoreByMenu(String keyword) throws Exception {
		List<StoreVO> menulist = storeDAO.selectStoreByMenu(keyword);
		return menulist;
	}
	
	@Override
	public List<StoreVO> selectStoreByAddr(String keyword) throws Exception{
		List<StoreVO> addrlist = storeDAO.selectStoreByAddr(keyword);
		return addrlist;
	}
	
	@Override
	public List<StoreVO> selectStoreByName(String keyword) throws Exception{
		List<StoreVO> namelist = storeDAO.selectStoreByName(keyword);
		return namelist;
	}
	
	@Override
	public List<StoreVO> selectStoreByType(String keyword) throws Exception {
		List<StoreVO> typelist = storeDAO.selectStoreByType(keyword);
		return typelist;
	}
	
	@Override
	public Map storeDetail(StoreVO storeVO) throws Exception {
		Map storeMap = new HashMap<>();
		
		long storeId = storeVO.getStoreId();
		long ownerId = storeVO.getOwnerId();
		
		StoreVO store = storeDAO.selectStoreDetail(storeId);
		List<ReviewVO> review = storeDAO.selectStoreReview(storeId);
		List<MenuVO> menu = storeDAO.selectStoreMenu(storeId);
		List<ReviewVO> detailReview = storeDAO.selectDetailReview(storeId);
//		List<ReservationSettingVO> reservation = storeDAO.selectStoreReservatioin(storeId);
		
		//이미지
		List<ImageFileVO> storeImage = storeDAO.selectStoreImage(storeVO);
		List<ImageFileVO> reviewImage = storeDAO.selectReviewImage(storeId);

		
		storeMap.put("store", store);
		storeMap.put("review", review);
		storeMap.put("menu", menu);
		storeMap.put("detailReview", detailReview);
//		storeMap.put("reservation", reservation);
		
		storeMap.put("storeImage", storeImage);
		storeMap.put("reviewImage", reviewImage);

		return storeMap;
	}
	

}
