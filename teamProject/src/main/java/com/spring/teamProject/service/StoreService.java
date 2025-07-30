package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import com.spring.teamProject.vo.StoreVO;

public interface StoreService {

	public List<StoreVO> storeRegionList(String region) throws Exception;
	public Map storeDetail(long StoreId) throws Exception;
}
