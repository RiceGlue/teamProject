package com.spring.teamProject.service;

import com.spring.teamProject.vo.MemberVO;

public interface MemberService {
	
	//회원가입
	public void join(MemberVO memberVO);
	
    //소셜 회원가입
    void joinSocial(MemberVO memberVO);
	
	//로그인
	public MemberVO login(MemberVO memberVO);
	
	//회원정보 수정
	public boolean updateMember(MemberVO memberVO);
	
	//회원탈퇴
	public boolean deleteMember(long memberId);
	
	// 이메일로 회원 정보 조회
	public MemberVO findByEmail(String email);

	// (신규) 아이디 중복 확인
	public int checkIdDuplicate(String loginId);
}