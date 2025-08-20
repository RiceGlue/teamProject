package com.spring.teamProject.dao;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.dao.DataAccessException;

import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.WaitingVO;

@Mapper
public interface ReviewDAO {

	public ReservationVO selectReservationById(long reservationId) throws DataAccessException;
	public WaitingVO selectWaitingById(long waitingId) throws DataAccessException;
	public StoreVO selectStore(long storeId) throws DataAccessException;
}
