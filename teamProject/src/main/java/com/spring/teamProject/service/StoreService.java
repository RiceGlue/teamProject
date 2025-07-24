package com.spring.teamProject.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.teamProject.dao.StoreDAO;
import com.spring.teamProject.vo.StoreImageVO;
import com.spring.teamProject.vo.StoreVO;

@Service
public class StoreService{
	
	@Autowired
	private StoreDAO storeDAO;
	
	public List<StoreVO> storeRegionList(String region) throws Exception {
		List<StoreVO> storelist = storeDAO.SelectStoreRegion(region);
		return storelist;
	}
	
	public List<StoreVO> keywordSearchStore(String keyword) throws Exception {
		List<StoreVO> storelist = storeDAO.SelectKeywordStore(keyword);
		return storelist;
	}
	
	public List<Long> storeImageRegionList(String region) throws Exception {
		List<Long> imagelist = storeDAO.SelectStoreImageRegion(region);
		return imagelist;
	}

}
