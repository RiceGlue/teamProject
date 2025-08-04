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
	
	//가게 검색
	public List<StoreVO> selectStoreByRegion(String keyword) throws DataAccessException; //지역별 검색
	public List<StoreVO> selectStoreByMenu(String keyword) throws DataAccessException; //메뉴 이름 검색
	public List<StoreVO> selectStoreByAddr(String keyword) throws DataAccessException; //주소 검색
	public List<StoreVO> selectStoreByName(String keyword) throws DataAccessException; //가게 이름 검색
	
	//가게 상세 페이지
	public StoreVO selectStoreDetail(long storeId) throws DataAccessException;
	public List<ImageFileVO> selectStoreImage(long storeId) throws DataAccessException;
	public List<MenuVO> selectStoreMenu(long storeId) throws DataAccessException;
	public List<ReviewVO> selectDetailReview(long storeId) throws DataAccessException;
	public List<ReviewVO> selectStoreReview(long storeId) throws DataAccessException;
//	public ReservationVO selectStoreReservatioin(long storeId) throws DataAccessException;

	
}