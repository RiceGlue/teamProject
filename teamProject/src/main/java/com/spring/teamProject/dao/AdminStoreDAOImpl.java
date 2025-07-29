package com.spring.teamProject.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;

import com.spring.teamProject.vo.StoreVO;

public class AdminStoreDAOImpl implements AdminStoreDAO{
	
	@Autowired
	private SqlSession sqlSession;

	@Override
	public long insertStoreInfo(Map newStoreMap) throws DataAccessException {
		sqlSession.insert("mapper.store.insertStoreInfo",newStoreMap);
		return (long)newStoreMap.get("storeId");
	}
	
	@Override
	public List<StoreVO> selectStoreByRegion(String region) throws DataAccessException {
		List<StoreVO> storelist = sqlSession.selectList("mapper.store.selectStoreByRegion", region);
		return storelist;
	}

}
