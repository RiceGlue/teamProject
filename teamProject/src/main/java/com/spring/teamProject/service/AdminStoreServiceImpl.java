package com.spring.teamProject.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.spring.teamProject.dao.AdminStoreDAO;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.StoreVO;

@Service("adminStoreService")
@Transactional(propagation=Propagation.REQUIRED)
public class AdminStoreServiceImpl implements AdminStoreService{
	
	@Autowired
	private AdminStoreDAO adminStoreDAO;

	@Override
	public long addStoreInfo(Map storeInfo) throws Exception {
		long storeId = adminStoreDAO.insertStoreInfo(storeInfo);
		return storeId;
	}
	
	@Override
	public void addStoreInfoImage(List imgfile) throws Exception {
		adminStoreDAO.insertStoreImageFile(imgfile);
	}

}
