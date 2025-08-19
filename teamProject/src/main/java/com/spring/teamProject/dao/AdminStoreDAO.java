package com.spring.teamProject.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.dao.DataAccessException;

import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MenuVO;
import com.spring.teamProject.vo.StoreVO;

@Mapper
public interface AdminStoreDAO {
	
	long insertStoreInfo(Map storeInfo) throws DataAccessException;
	public void insertStoreImage(List<ImageFileVO> imgfile) throws DataAccessException;
	public long insertMenu(MenuVO meunVO) throws DataAccessException;
	public void insertMenuImage(ImageFileVO imgFileVO) throws DataAccessException;
	public StoreVO selectStoreInfo(long storeId) throws DataAccessException;
	public List<MenuVO> selectMenuList(long storeId) throws DataAccessException;
	public List<ImageFileVO> selectStoreImage(StoreVO storeVO) throws DataAccessException;
	public void updateStoreInfo (Map storeInfo) throws DataAccessException;
	public void updateImage (ImageFileVO imgFileVO) throws DataAccessException;
	public void updateFileType (ImageFileVO imgFileVO) throws DataAccessException;
	public ImageFileVO selectImage(long imageId) throws DataAccessException;
	public void updateStoreInfoWithImage(Map storeInfo) throws DataAccessException;
	public void updateMenu(MenuVO menuVO) throws DataAccessException;
	public void updateMenuWithImage(MenuVO menuVO) throws DataAccessException;
}
