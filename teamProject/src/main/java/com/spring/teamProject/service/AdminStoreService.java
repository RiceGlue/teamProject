package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MenuVO;
import com.spring.teamProject.vo.StoreVO;

public interface AdminStoreService {
	
	public long addStoreInfo(Map storeInfo) throws Exception;
	public void addStoreInfoImage(List<ImageFileVO> imgfile) throws Exception;
	public long addMenu(MenuVO menuVO) throws Exception;
	public void addMenuImage(ImageFileVO imgFileVO) throws Exception;
	public StoreVO selectStoreInfo(long storeId) throws Exception;
	public List<MenuVO> selectMenuList(long storeId) throws Exception;
}
