package com.spring.teamProject.service;

import com.spring.teamProject.vo.MemberVO;

public interface MemberService {
	
	//회원가입
	public void join(MemberVO memberVO);
	
    // [삭제] 소셜 회원가입 메소드 제거 (일반 join으로 통합 관리)
    // void joinSocial(MemberVO memberVO);
	
    // (레거시) 로그인
    public MemberVO login(MemberVO memberVO);
    
    // 회원정보 수정
    public boolean updateMember(MemberVO memberVO);
    
    // [수정] 회원 탈퇴 (논리적 삭제)
    public boolean deactivateMember(long memberId);
    
    // 이메일로 회원 정보 조회
    public MemberVO findByEmail(String email);

    // 아이디 중복 확인
    public int checkIdDuplicate(String loginId);
}
