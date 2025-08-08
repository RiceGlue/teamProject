package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import com.spring.teamProject.vo.StoreVO;

public interface AdminStoreService {
	
	public void addStoreInfo(StoreVO storeVO) throws Exception;
	public void addStoreInfoImage(List imgfile) throws Exception;
}
