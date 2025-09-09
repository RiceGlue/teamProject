package com.spring.teamProject.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
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
	public List<StoreVO> searchByKeyword(String keyword) {
	    keyword = keyword.trim();
	    String[] tokens = keyword.split("\\s+");

	    if (tokens.length == 1) {
	        return searchBySingleKeyword(tokens[0]);
	    } else if (tokens.length == 2) {
	        return searchByDoubleKeyword(tokens[0], tokens[1]);
	    } else if (tokens.length == 3) {
	        return searchByTripleKeyword(tokens[0], tokens[1], tokens[2]);
	    }

	    return new ArrayList<>();
	}

	public List<StoreVO> searchBySingleKeyword(String keyword) {
		List<StoreVO> storeList1 = storeDAO.findByRegion(keyword);
		List<StoreVO> storeList2 = storeDAO.findByStoreName(keyword);
		List<StoreVO> storeList3 = storeDAO.findStoresByMenu(keyword);
		List<StoreVO> storeList4 = storeDAO.findByType(keyword);

		Map<Long, StoreVO> storeMap = new LinkedHashMap<>();

		for (StoreVO store : storeList1) {
		    storeMap.put(store.getStoreId(), store);
		}
		for (StoreVO store : storeList2) {
		    storeMap.put(store.getStoreId(), store);
		}
		for (StoreVO store : storeList3) {
		    storeMap.put(store.getStoreId(), store);
		}
		for (StoreVO store : storeList4) {
		    storeMap.put(store.getStoreId(), store);
		}

		return new ArrayList<>(storeMap.values());

	}

	public List<StoreVO> searchByDoubleKeyword(String first, String second) {
	    if (isRegion(first)) {
	        if (isMenu(second)) {
	            return storeDAO.findByRegionAndMenu(first, second);
	        } else {
	            return storeDAO.findByRegionAndStoreName(first, second);
	        }
	    } else if (isMenu(first)) {
	        return storeDAO.findByMenuAndStoreName(first, second);
	    }

	    return new ArrayList<>();
	}

	public List<StoreVO> searchByTripleKeyword(String first, String second, String third) {
	    String[] tokens = { first, second, third };
	    String region = null;
	    String menu = null;
	    String storeName = null;

	    for (String token : tokens) {
	        if (region == null && isRegion(token)) {
	            region = token;
	        } else if (menu == null && isMenu(token)) {
	            menu = token;
	        } else if (storeName == null &&isStoreName(token)) {
	            storeName = token;
	        }
	    }

	    if (region != null && menu != null && storeName != null) {
	        return storeDAO.findByRegionAndMenuAndStoreName(region, menu, storeName);
	    } else if (region != null && menu != null) {
	        return storeDAO.findByRegionAndMenu(region, menu);
	    } else if (region != null && storeName != null) {
	        return storeDAO.findByRegionAndStoreName(region, storeName);
	    } else if (menu != null && storeName != null) {
	        return storeDAO.findByMenuAndStoreName(menu, storeName);
	    }

	    return new ArrayList<>();
	}

	@Override
	public List<StoreVO> getStoresByRegion(String region) throws Exception {
		return storeDAO.findByRegion(region);
	}
	
	@Override
	public List<StoreVO> getStoresByType(String type) throws Exception {
		return storeDAO.findByType(type);
	}
	
	@Override
	public List<StoreVO> findNewOpenStore() throws Exception {
		return storeDAO.findNewOpenStore();
	}
	
	@Override
	public List<StoreVO> findUserLikeStores() throws Exception {
		return storeDAO.findUserLikeStores();
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

	@Override
    public List<StoreVO> getStoresByOwnerId(long ownerId) throws Exception {
        return storeDAO.selectStoresByOwnerId(ownerId);
    }
	
	@Override
	public List<StoreVO> searchStoreSameStoreType(StoreVO storeVO) throws Exception {
		return storeDAO.selectStoreSameStoreType(storeVO);
	}
	
	public boolean isRegion(String keyword) {
	    Integer count = storeDAO.isRegion(keyword);
	    return count != null && count > 0;
	}

	public boolean isStoreName(String keyword) {
	    Integer count = storeDAO.isStoreName(keyword);
	    return count != null && count > 0;
	}

	public boolean isMenu(String keyword) {
	    Integer count = storeDAO.isMenu(keyword);
	    return count != null && count > 0;
	}

	
}
