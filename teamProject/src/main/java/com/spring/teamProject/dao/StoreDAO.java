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
	public List<StoreVO> selectStoreByType(String keyword) throws DataAccessException; //가게 유형 검색

	//가게 상세 페이지
	public StoreVO selectStoreDetail(long storeId) throws DataAccessException;
	public List<MenuVO> selectStoreMenu(long storeId) throws DataAccessException;
	public List<ReviewVO> selectDetailReview1(long storeId) throws DataAccessException;
	public ReviewVO selectDetailReview2(long storeId) throws DataAccessException;
	public List<ReviewVO> selectStoreReview(long storeId) throws DataAccessException;
//	public List<ReservationSettingVO> selectStoreReservatioin(long storeId) throws DataAccessException;

	public List<ImageFileVO> selectStoreImage(StoreVO storeVO) throws DataAccessException;
	public List<ImageFileVO> selectReviewImage(long storeId) throws DataAccessException;

	// 매장 ID로 매장 정보를 가져오는 메서드 추가
	public StoreVO selectStoreById(long storeId) throws DataAccessException;

	public List<StoreVO> selectStoreNearUser (String address) throws DataAccessException;

	public List<ReviewVO> selectBestReviewByStores() throws DataAccessException;
	public List<ImageFileVO> selectBestReviewImageByStores() throws DataAccessException;

    /**
     * 점주(owner) ID로 소유한 매장 목록을 조회합니다.
     * @param ownerId 점주 ID
     * @return 소유한 매장 목록
     * @throws DataAccessException DB 접근 오류 시
     */
    public List<StoreVO> selectStoresByOwnerId(long ownerId) throws DataAccessException;
}