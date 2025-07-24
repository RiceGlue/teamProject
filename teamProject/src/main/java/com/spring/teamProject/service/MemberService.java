package com.spring.teamProject.service;

import com.spring.teamProject.vo.MemberVO;

public interface MemberService {
	
	//회원가입
	public void join(MemberVO memberVO);
	
	//로그인
	public MemberVO login(MemberVO memberVO);
	
	//회원정보 수정
	public boolean updateMember(MemberVO memberVO);
	
	//회원탈퇴
	public boolean deleteMember(long member_id);
}
