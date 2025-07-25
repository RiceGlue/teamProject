package com.spring.teamProject.dao;

import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;

public class AdminStoreDAOImpl implements AdminStoreDAO{
	
	@Autowired
	private SqlSession sqlSession;
	
	@Override
	public long insertStoreInfo(Map newStoreMap) throws DataAccessException {
		sqlSession.insert("mapper.store.insertStoreInfo",newStoreMap);
		return (long) newStoreMap.get("storeId");
	}
}
