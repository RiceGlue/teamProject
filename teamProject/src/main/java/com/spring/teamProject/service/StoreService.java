package com.spring.teamProject.service;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.beans.factory.annotation.Autowired;

import com.spring.teamProject.dao.StoreDAO;
import com.spring.teamProject.vo.StoreVO;

@Mapper
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

}
