package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.dao.DataAccessException;

import com.spring.teamProject.vo.StoreVO;

@Mapper
public interface StoreDAO {
	
	public List<StoreVO> selectStoreByRegion(String region) throws DataAccessException;

}