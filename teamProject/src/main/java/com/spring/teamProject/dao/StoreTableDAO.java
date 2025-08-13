// src/main/java/com/spring/teamProject/dao/StoreTableDAO.java
package com.spring.teamProject.dao;

import com.spring.teamProject.vo.StoreTableVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Mapper
@Repository
public interface StoreTableDAO {
    /**
     * 특정 매장의 모든 테이블 목록을 조회합니다.
     * @param storeId 매장 ID
     * @return 해당 매장의 모든 테이블 목록
     */
    List<StoreTableVO> selectAllTablesByStoreId(@Param("storeId") Long storeId);

	StoreTableVO selectStoreTableById(Long tableId);
}