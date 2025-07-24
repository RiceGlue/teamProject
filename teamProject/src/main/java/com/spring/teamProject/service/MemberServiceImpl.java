package com.spring.teamProject.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.teamProject.dao.MemberDAO;
import com.spring.teamProject.vo.MemberVO;

@Service("memberService")
public class MemberServiceImpl implements MemberService {
	
	@Autowired
	private MemberDAO memberDAO;
	
	@Override
	public void join(MemberVO memberVO) {
		memberDAO.insertMember(memberVO);
	}
	
	@Override
	public MemberVO login(MemberVO memberVO) {
		return memberDAO.login(memberVO);
	}
	
	@Override
	public boolean updateMember(MemberVO memberVO) {
		//1개의 행이 수정되었다면 true 아닐경우 false를 반환합니다
		return memberDAO.updateMember(memberVO) == 1;
	}
	
	public boolean deleteMember(long member_id) {
		//1개의 행이 수정되었다면 true 아닐경우 false를 반환합니다
		return memberDAO.deleteMember(member_id) == 1;
	}
}