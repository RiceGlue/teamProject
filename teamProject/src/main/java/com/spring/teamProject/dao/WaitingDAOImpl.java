package com.spring.teamProject.dao;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;

import com.spring.teamProject.vo.WaitingVO;

public class WaitingDAOImpl implements WaitingDAO {

	@Autowired
	private SqlSession sqlSession;
	
	private static final String NAMESPACE = "com.spring.teamProject.dao.WaitingDAO";

    @Override
    public void insertWaitingSlot(WaitingVO vo) {
        sqlSession.insert(NAMESPACE + ".insertWaitingSlot", vo);
    }

    @Override
    public List<WaitingVO> getWaitingSlotsByStore(Long storeId) {
        return sqlSession.selectList(NAMESPACE + ".getWaitingSlotsByStore", storeId);
    }

    @Override
    public void deleteWaitingSlot(Long waitingId) {
        sqlSession.delete(NAMESPACE + ".deleteWaitingSlot", waitingId);
    }

    @Override
    public void updateWaitingSlot(WaitingVO vo) {
        sqlSession.update(NAMESPACE + ".updateWaitingSlot", vo);
    }
	
}
