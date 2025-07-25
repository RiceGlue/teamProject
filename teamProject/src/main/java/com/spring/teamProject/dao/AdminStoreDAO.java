package com.spring.teamProject.dao;

import java.util.Map;

import org.springframework.dao.DataAccessException;

public interface AdminStoreDAO {
	public long insertStoreInfo(Map newStoreMap) throws DataAccessException;
}
