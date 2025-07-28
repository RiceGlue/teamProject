package com.spring.teamProject.dao;

import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.dao.DataAccessException;

@Mapper
public interface AdminStoreDAO {
	
	public long insertStoreInfo(Map newStoreMap) throws DataAccessException;
}
