package com.spring.teamProject.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.dao.DataAccessException;

import com.spring.teamProject.vo.StoreVO;

@Mapper
public interface AdminStoreDAO {
	
	long insertStoreInfo(Map storeInfo) throws DataAccessException;
	public void insertStoreImageFile(List imgfile) throws DataAccessException;
}
