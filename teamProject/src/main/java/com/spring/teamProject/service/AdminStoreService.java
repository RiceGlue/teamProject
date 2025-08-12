package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MenuVO;

public interface AdminStoreService {
	
	public long addStoreInfo(Map storeInfo) throws Exception;
	public void addStoreInfoImage(List<ImageFileVO> imgfile) throws Exception;
	public void deleteInfo(long storeId) throws Exception;
	public long addMenuInfo(MenuVO menuVO) throws Exception;
	public void addMenuInfoImage(ImageFileVO imgFileVO) throws Exception;
}
