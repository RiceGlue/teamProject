package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MenuVO;
import com.spring.teamProject.vo.StoreVO;

public interface AdminStoreService {
	
	public List<StoreVO> getOwnerStore(long ownerId) throws Exception;
	public int getStoreCount(long ownerId) throws Exception;
	public int getMenuCount(long storeId) throws Exception;
	
	public long addStoreInfo(Map storeInfo) throws Exception;
	public void addStoreInfoImage(List<ImageFileVO> imgfile) throws Exception;
	public long addMenu(MenuVO menuVO) throws Exception;
	public void addMenuImage(ImageFileVO imgFileVO) throws Exception;
	public StoreVO selectStoreInfo(long storeId) throws Exception;
	public List<MenuVO> selectMenuList(long storeId) throws Exception;
	public List<ImageFileVO> selectStoreImage(StoreVO storeVO) throws Exception;
	public void modifyStoreInfo(Map storeInfo) throws Exception;
	public void modifyImage(ImageFileVO imgFileVO) throws Exception;
	public ImageFileVO selectImage(long imageId) throws Exception;
	public long selectImageId (long menuId) throws Exception;
	public void modifyFileType(ImageFileVO imgFileVO) throws Exception;
	public void modifyStoreInfoWithImage(Map storeInfo) throws Exception;
	public void modifyMenu(MenuVO menuVO) throws Exception;
	public void modifyMenuWithImage(MenuVO menuVO) throws Exception;
	public void deleteMenu(long menuId) throws Exception;
}
