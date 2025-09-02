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
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.StoreVO;

@Service("adminStoreService")
@Transactional(propagation=Propagation.REQUIRED)
public class AdminStoreServiceImpl implements AdminStoreService{

	@Autowired
	private AdminStoreDAO adminStoreDAO;

	@Override
	public List<StoreVO> getOwnerStore(long ownerId) throws Exception {
		return adminStoreDAO.selectOwnerStore(ownerId);
	}
	
	@Override
	public int getStoreCount(long ownerId) throws Exception {
		return adminStoreDAO.selectStoreCount(ownerId);
	}
	
	@Override
	public int getMenuCount(long storeId) throws Exception {
		return adminStoreDAO.selectMenuCount(storeId);
	}
	
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
	
	@Override
	public List<MenuVO> selectMenuList(long storeId) throws Exception {
		List<MenuVO> menuList = adminStoreDAO.selectMenuList(storeId);
		return menuList;
	}
	
	@Override
	public List<ImageFileVO> selectStoreImage(StoreVO storeVO) throws Exception {
		List<ImageFileVO> imageList = adminStoreDAO.selectStoreImage(storeVO);
		return imageList;
	}
	
	@Override
	public void modifyStoreInfo(Map storeInfo) throws Exception {
		adminStoreDAO.updateStoreInfo(storeInfo);
	}

	@Override
	public void modifyImage(ImageFileVO imgFileVO) throws Exception {
		adminStoreDAO.updateImage(imgFileVO);
	}
	
	@Override
	public void modifyFileType(ImageFileVO imgFileVO) throws Exception {
		adminStoreDAO.updateFileType(imgFileVO);
	}
	
	@Override
	public ImageFileVO selectImage(long imageId) throws Exception {
		ImageFileVO imgFileVO = adminStoreDAO.selectImage(imageId);
		return imgFileVO;
	}
	
	@Override
	public long selectImageId (long menuId) throws Exception {
		long imageId = adminStoreDAO.selectImageId(menuId);
		return imageId;
	}
	@Override
	public void modifyStoreInfoWithImage(Map storeInfo) throws Exception {
		adminStoreDAO.updateStoreInfoWithImage(storeInfo);
	}
	
	@Override
	public void modifyMenu(MenuVO menuVO) throws Exception {
		adminStoreDAO.updateMenu(menuVO);
	}
	
	@Override
	public void modifyMenuWithImage(MenuVO menuVO) throws Exception {
		adminStoreDAO.updateMenuWithImage(menuVO);
	}
	
	@Override
	public void deleteMenu(long menuId) throws Exception {
		adminStoreDAO.deleteMenuOnImageFile(menuId);
		adminStoreDAO.deleteMenuOnMenu(menuId);
	}
	
	@Override
	public boolean deleteImageById(long imageId) throws Exception {
		return adminStoreDAO.deleteImageById(imageId);
	}
}
