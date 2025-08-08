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
	public long selectStoreId(StoreVO storeVO) throws Exception {
		long storeId = adminStoreDAO.selectStoreId(storeVO);
		return storeId;
	}
	
	@Override
	public long selectOwnerId(long storeId) throws Exception {
		long ownerId = adminStoreDAO.selectOwnerId(storeId);
		return ownerId;
	}
	
	@Override
	public long addStoreInfo(Map newStoreMap) throws Exception {
		long infoId = adminStoreDAO.insertStoreInfo(newStoreMap);
		ArrayList<ImageFileVO> imgfile = (ArrayList)newStoreMap.get("imgfile");
		for(ImageFileVO imageFileVO : imgfile ) {
			imageFileVO.setInfoId(infoId);
		}
		adminStoreDAO.insertStoreImageFile(imgfile);
		return infoId;
	}
	
	@Override
	public void addStoreInfoImage(List imgfile) throws Exception {
		adminStoreDAO.insertStoreImageFile(imgfile);
	}

}
