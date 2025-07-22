package com.spring.teamProject.dao;

import java.util.List;
//import org.springframework.dao.DataAccessException;

import com.spring.teamProject.vo.StoreVO;

public interface StoreDAO {
	public List<StoreVO> SelectStoreRegion(String region);
}
