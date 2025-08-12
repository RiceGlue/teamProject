package com.spring.teamProject.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.dao.DataAccessException;

import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MenuVO;

@Mapper
public interface AdminStoreDAO {
	
	long insertStoreInfo(Map storeInfo) throws DataAccessException;
	public void insertStoreImageFile(List<ImageFileVO> imgfile) throws DataAccessException;
	public void deleteStoreInfo(long storeId) throws DataAccessException;
	public long insertMenuInfo(MenuVO meunVO) throws DataAccessException;
	public void insertMenuImageFile(ImageFileVO imgFileVO) throws DataAccessException;
}
