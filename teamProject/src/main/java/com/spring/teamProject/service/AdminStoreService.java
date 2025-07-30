package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import com.spring.teamProject.vo.StoreVO;

public interface AdminStoreService {
	
	public long addStoreInfo(Map newStoreMap) throws Exception;
	public List<StoreVO> storeRegionList(String region) throws Exception;
}
