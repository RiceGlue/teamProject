package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.RequestParam;

import com.spring.teamProject.vo.StoreVO;

public interface StoreService {

	public List<StoreVO> selectStoreByRegion(String keyword) throws Exception;
	public List<StoreVO> selectStoreByMenu(String keyword) throws Exception;
	public List<StoreVO> selectStoreByAddr(String keyword) throws Exception;
	public List<StoreVO> selectStoreByName(String keyword) throws Exception;
	public List<StoreVO> selectStoreByType(String keyword) throws Exception;
	public Map storeDetail(StoreVO storeVO) throws Exception;

	// 매장 ID로 매장 정보를 가져오는 메서드 추가
	public StoreVO getStoreById(Long storeId) throws Exception;
	
	public List<StoreVO> searchStoreNearUser(@RequestParam String address) throws Exception;
	
//	PUBLIC MAP GETBESTREVIEWBYSTORES() THROWS EXCEPTION;
}
