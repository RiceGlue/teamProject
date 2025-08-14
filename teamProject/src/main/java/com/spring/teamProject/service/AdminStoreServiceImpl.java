package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.spring.teamProject.dao.AdminStoreDAO;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MenuVO;
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
	public void addStoreInfoImage(List<ImageFileVO> imgfile) throws Exception {
		adminStoreDAO.insertStoreImage(imgfile);
	}

	@Override
	public long addMenu(MenuVO menuVO) throws Exception {
		long menuId = adminStoreDAO.insertMenu(menuVO);
		return menuId;
	}
	
	@Override
	public void addMenuImage(ImageFileVO imgFileVO) throws Exception {
		adminStoreDAO.insertMenuImage(imgFileVO);
	}
	
	@Override
	public StoreVO selectStoreInfo(long storeId) throws Exception {
		StoreVO storeInfo = adminStoreDAO.selectStoreInfo(storeId);
		return storeInfo;
	}
	public List<MenuVO> selectMenuList(long storeId) throws Exception {
		List<MenuVO> menuList = adminStoreDAO.selectMenuList(storeId);
		return menuList;
	}
}
