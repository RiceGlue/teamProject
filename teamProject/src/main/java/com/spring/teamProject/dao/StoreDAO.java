package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;

import com.spring.teamProject.vo.StoreVO;

@Mapper
public class StoreDAO {
	@Autowired
	private SqlSession sqlSession;
	
	public List<StoreVO> SelectStoreRegion(String region) {
		List<StoreVO> storelist = sqlSession.selectList("mapper.store.SelectStoreRegion", region);
		return storelist;
	}
	
	public List<StoreVO> SelectKeywordStore(String keyword) {
		List<StoreVO> storelist = sqlSession.selectList("mapper.store.SelectKeywordStore",keyword);
		return storelist;
	}
}
