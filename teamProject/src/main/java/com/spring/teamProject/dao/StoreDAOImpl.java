package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;

import com.spring.teamProject.vo.StoreVO;

public class StoreDAOImpl implements StoreDAO {
	@Autowired
	private SqlSession sqlSession;
	
	@Override
	public List<StoreVO> SelectStoreRegion(String region){
		List<StoreVO> storelist = sqlSession.selectList("mapper.store.SelectStoreRegion", region);
		return storelist;
	}

}
