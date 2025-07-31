package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.dao.DataAccessException;

import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MenuVO;
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.StoreVO;

@Mapper
public interface StoreDAO {
	
	public List<StoreVO> selectStoreByRegion(String region) throws DataAccessException;
	
	//가게 상세 페이지
	public StoreVO selectStoreDetail(long storeId) throws DataAccessException;
	public List<ImageFileVO> selectStoreImage(long storeId) throws DataAccessException;
	public List<MenuVO> selectStoreMenu(long storeId) throws DataAccessException;
	public List<ReviewVO> selectDetailReview(long storeId) throws DataAccessException;
	public ReviewVO selectStoreReivew(long storeId) throws DataAccessException;
//	public ReservationVO selectStoreReservatioin(long storeId) throws DataAccessException;

	
}