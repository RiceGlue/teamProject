package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.spring.teamProject.vo.StoreVO;

@Mapper
public interface StoreDAO {
	
	public List<StoreVO> SelectStoreRegion(String region);
	public List<StoreVO> SelectKeywordStore(String keyword);
	public List<Long> SelectStoreImageRegion(String region);	


}