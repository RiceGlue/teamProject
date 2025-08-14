package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import com.spring.teamProject.vo.StoreVO;

public interface StoreService {

	public List<StoreVO> selectStoreByRegion(String keyword) throws Exception;
	public List<StoreVO> selectStoreByMenu(String keyword) throws Exception;
	public List<StoreVO> selectStoreByAddr(String keyword) throws Exception;
	public List<StoreVO> selectStoreByName(String keyword) throws Exception;
	public List<StoreVO> selectStoreByType(String keyword) throws Exception;
	public Map storeDetail(StoreVO storeVO) throws Exception;
}
