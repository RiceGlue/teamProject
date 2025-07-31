package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import com.spring.teamProject.vo.StoreVO;

public interface StoreService {

	public List<StoreVO> selectStoreByRegion(String keyword) throws Exception;
	public List<StoreVO> selectStoreByType(String keyword) throws Exception;
	public Map storeDetail(long StoreId) throws Exception;
}
