package com.spring.teamProject.dao;

import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.dao.DataAccessException;

import com.spring.teamProject.vo.StoreVO;

@Mapper
public interface AdminStoreDAO {
	
	long selectStoreId(StoreVO storeVO) throws DataAccessException;
	public long insertStoreInfo(Map newStoreMap) throws DataAccessException;
}
