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
	Integer isRegion(String keyword);
	Integer isStoreName(String keyword);
	Integer isMenu(String keyword);   // 메뉴 판별 메서드 추가

	List<StoreVO> findByRegion(String region);
	List<StoreVO> findByStoreName(String storeName);
	List<StoreVO> findStoresByMenu(String menu);
	List<StoreVO> findByType(String type);

	List<StoreVO> findByRegionAndMenu(String region, String menu);
	List<StoreVO> findByRegionAndStoreName(String region, String storeName);
	List<StoreVO> findByMenuAndStoreName(String menu, String storeName);
	List<StoreVO> findByRegionAndMenuAndStoreName(String region, String menu, String storeName);

	List<StoreVO> findByMenu(String menuName);  // 메뉴로 매장 찾기
	List<Long> findStoreIdsByMenuName(String menuName);  // 메뉴 이름으로 매장 ID 찾기
	
	List<StoreVO> findNewOpenStore();
	List<StoreVO> findUserLikeStores();
	    
	List<StoreVO> findByStoreIds(List<Long> storeIds);

	//가게 상세 페이지
	public StoreVO selectStoreDetail(long storeId) throws DataAccessException;
	public List<MenuVO> selectStoreMenu(long storeId) throws DataAccessException;
	public List<ReviewVO> selectDetailReview1(long storeId) throws DataAccessException;
	public ReviewVO selectDetailReview2(long storeId) throws DataAccessException;
	public List<ReviewVO> selectStoreReview(long storeId) throws DataAccessException;
//	public List<ReservationSettingVO> selectStoreReservatioin(long storeId) throws DataAccessException;

	public List<ImageFileVO> selectStoreImage(StoreVO storeVO) throws DataAccessException;
	public List<ImageFileVO> selectReviewImage(long storeId) throws DataAccessException;
	public List<ImageFileVO> selectHomeReviewImage(long storeId) throws DataAccessException;

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
    public List<StoreVO> selectStoreSameStoreType(StoreVO storeVO) throws DataAccessException;
}