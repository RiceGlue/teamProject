package com.spring.teamProject.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestParam;

import com.spring.teamProject.dao.StoreDAO;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.MenuVO;
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.StoreVO;

@Service
public class StoreServiceImpl implements StoreService{

	@Autowired
	private StoreDAO storeDAO;

	@Override
	public List<StoreVO> selectStoreByRegion(String keyword) throws Exception {
		List<StoreVO> regionlist = storeDAO.selectStoreByRegion(keyword);
		return regionlist;
	}

	@Override
	public List<StoreVO> selectStoreByMenu(String keyword) throws Exception {
		List<StoreVO> menulist = storeDAO.selectStoreByMenu(keyword);
		return menulist;
	}

	@Override
	public List<StoreVO> selectStoreByAddr(String keyword) throws Exception{
		List<StoreVO> addrlist = storeDAO.selectStoreByAddr(keyword);
		return addrlist;
	}

	@Override
	public List<StoreVO> selectStoreByName(String keyword) throws Exception{
		List<StoreVO> namelist = storeDAO.selectStoreByName(keyword);
		return namelist;
	}

	@Override
	public List<StoreVO> selectStoreByType(String keyword) throws Exception {
		List<StoreVO> typelist = storeDAO.selectStoreByType(keyword);
		return typelist;
	}

	@Override
	public Map storeDetail(StoreVO storeVO) throws Exception {
		Map storeMap = new HashMap<>();

		long storeId = storeVO.getStoreId();

		StoreVO store = storeDAO.selectStoreDetail(storeId);
		List<ReviewVO> review = storeDAO.selectStoreReview(storeId);
		List<MenuVO> menu = storeDAO.selectStoreMenu(storeId);
		List<ReviewVO> detailReview1 = storeDAO.selectDetailReview1(storeId);
		ReviewVO detailReview2 = storeDAO.selectDetailReview2(storeId);

		System.out.println(detailReview2.getTastePercent());

//		List<ReservationSettingVO> reservation = storeDAO.selectStoreReservatioin(storeId);

		//이미지
		List<ImageFileVO> storeImage = storeDAO.selectStoreImage(storeVO);
		List<ImageFileVO> reviewImage = storeDAO.selectReviewImage(storeId);
		List<ImageFileVO> homeReviewImage = storeDAO.selectHomeReviewImage(storeId);

		storeMap.put("store", store);
		storeMap.put("review", review);
		storeMap.put("menu", menu);
		storeMap.put("detailReview1", detailReview1);
		storeMap.put("detailReview2", detailReview2);
//		storeMap.put("reservation", reservation);

		storeMap.put("storeImage", storeImage);
		storeMap.put("reviewImage", reviewImage);
		storeMap.put("homeReviewImage", homeReviewImage);

		return storeMap;
	}

	/**
	 * 매장 ID로 매장 정보를 가져옵니다.
	 * @param storeId 매장 ID
	 * @return 매장 정보 객체
	 * @throws Exception
	 */
	@Override
	public StoreVO getStoreById(Long storeId) throws Exception {
		return storeDAO.selectStoreById(storeId);
	}

	@Override
	public List<StoreVO> searchStoreNearUser(@RequestParam String address) {
		return storeDAO.selectStoreNearUser(address);
	}

//	@Override
//	public Map getBestReviewByStores() throws Exception {
//		Map storeReivew = new HashMap<>();
//
//		List<ReviewVO> reviewList = storeDAO.selectBestReviewByStores();
//		List<ImageFileVO> reviewImageList = storeDAO.selectBestReviewImageByStores();
//
//		storeReivew.put("reviewList", reviewList);
//		storeReivew.put("reviewImageList", reviewImageList);
//		return storeReivew;
//	}

	@Override
    public List<StoreVO> getStoresByOwnerId(long ownerId) throws Exception {
        return storeDAO.selectStoresByOwnerId(ownerId);
    }
}
