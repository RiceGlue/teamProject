package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import com.spring.teamProject.vo.StoreVO;

public interface AdminStoreService {
	
	public long selectStoreId(StoreVO storeVO) throws Exception;
	public long addStoreInfo(Map newStoreMap) throws Exception;
}
