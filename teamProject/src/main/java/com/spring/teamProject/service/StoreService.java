package com.spring.teamProject.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.teamProject.dao.StoreDAO;
import com.spring.teamProject.vo.StoreVO;

@Service
public class StoreService{
	
	@Autowired
	private StoreDAO storeDAO;
	
	public List<StoreVO> storeRegionList(String region) throws Exception {
		List<StoreVO> storelist = storeDAO.SelectStoreRegion(region);
		return storelist;
	}
	

}
