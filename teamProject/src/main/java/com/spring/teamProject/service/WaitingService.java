package com.spring.teamProject.service;

import java.util.List;

import com.spring.teamProject.vo.WaitingVO;

public interface WaitingService {
    List<WaitingVO> getAllWaitings();
    WaitingVO getWaitingById(Long waitingId);
    void insertWaiting(WaitingVO waiting);
    void updateWaitingStatus(Long waitingId, String status);
    void deleteWaiting(Long waitingId);
}
