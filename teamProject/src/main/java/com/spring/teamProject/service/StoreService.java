package com.spring.teamProject.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.RequestParam;

import com.spring.teamProject.vo.StoreVO;

public interface StoreService {

	public List<StoreVO> selectStoreByRegion(String keyword) throws Exception;
	public List<StoreVO> selectStoreByMenu(String keyword) throws Exception;
	public List<StoreVO> selectStoreByAddr(String keyword) throws Exception;
	public List<StoreVO> selectStoreByName(String keyword) throws Exception;
	public List<StoreVO> selectStoreByType(String keyword) throws Exception;
	public Map storeDetail(StoreVO storeVO) throws Exception;

	// 매장 ID로 매장 정보를 가져오는 메서드 추가
	public StoreVO getStoreById(Long storeId) throws Exception;

	public List<StoreVO> searchStoreNearUser(@RequestParam String address) throws Exception;

//	PUBLIC MAP GETBESTREVIEWBYSTORES() THROWS EXCEPTION;


	/**
	 * 점주 ID로 소유한 모든 매장 정보를 조회합니다.
	 * @param ownerId 점주(회원) ID
	 * @return 해당 점주가 소유한 매장 목록
	 * @throws Exception DB 처리 오류 발생 시
	 */
	public List<StoreVO> getStoresByOwnerId(long ownerId) throws Exception;
	public List<StoreVO> searchStoreSameStoreType(String storeType) throws Exception;
}
