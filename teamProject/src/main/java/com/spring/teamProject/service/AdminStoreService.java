package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import com.spring.teamProject.vo.StoreVO;

public interface AdminStoreService {
	
	public long addStoreInfo(Map storeInfo) throws Exception;
	public void addStoreInfoImage(List imgfile) throws Exception;
}
