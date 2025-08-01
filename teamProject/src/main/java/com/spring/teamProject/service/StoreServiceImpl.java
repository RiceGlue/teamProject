package com.spring.teamProject.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.teamProject.dao.StoreDAO;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MenuVO;
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.StoreVO;

@Service
public class StoreServiceImpl implements StoreService{
	
	@Autowired
	private StoreDAO storeDAO;
	
	@Override
	public List<StoreVO> selectStoreByRegion(String keyword) throws Exception {
		List<StoreVO> storelist = storeDAO.selectStoreByRegion(keyword);
		return storelist;
	}
	
	@Override
	public List<StoreVO> selectStoreByType(String keyword) throws Exception {
		List<StoreVO> storelist = storeDAO.selectStoreByType(keyword);
		return storelist;
	}
	
	@Override
	public Map storeDetail(long storeId) throws Exception {
		Map storeMap = new HashMap<>();
		
		StoreVO store = storeDAO.selectStoreDetail(storeId);
		List<ImageFileVO> imagelist = storeDAO.selectStoreImage(storeId);
		List<ReviewVO> review = storeDAO.selectStoreReview(storeId);
		List<MenuVO> menu = storeDAO.selectStoreMenu(storeId);
		List<ReviewVO> detailReview = storeDAO.selectDetailReview(storeId);
//		ReservationVO reservation = storeDAO.selectStoreReservatioin(storeId);

		
		storeMap.put("store", store);
		storeMap.put("imagelist", imagelist);
		storeMap.put("review", review);
		storeMap.put("menu", menu);
		storeMap.put("detailReview", detailReview);
//		storeMap.put("reservation", reservation);
		
		System.out.println(storeId);
		System.out.println(store.getStoreId());
		
		return storeMap;
	}
	

}
