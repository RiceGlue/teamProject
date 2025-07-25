package com.spring.teamProject.service;

import java.util.ArrayList;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.spring.teamProject.dao.AdminStoreDAO;
import com.spring.teamProject.vo.ImageFileVO;

@Service("adminStoreService")
@Transactional(propagation=Propagation.REQUIRED)
public class AdminStoreServiceImpl implements AdminStoreService{
	
	@Autowired
	private AdminStoreDAO adminStoreDAO;
	
	@Override
	public long addStoreInfo(Map newStoreMap) throws Exception {
		long storeId = adminStoreDAO.insertStoreInfo(newStoreMap);
		ArrayList<ImageFileVO> imageFileList = (ArrayList)newStoreMap.get("imageFileList");
		for(ImageFileVO imageFileVO : imageFileList ) {
			imageFileVO.setStoreId(storeId);
		}
//		adminStoreDAO.insertStoreImageFile(imageFileList);
		return storeId;
	}
}
