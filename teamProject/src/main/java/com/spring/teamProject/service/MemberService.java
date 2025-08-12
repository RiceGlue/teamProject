package com.spring.teamProject.service;

import com.spring.teamProject.vo.MemberVO;
import java.util.List;

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
    
    // [신규] memberId로 회원 정보를 조회하는 메소드 추가 (내부 로직용)
    public MemberVO findById(long memberId);

    // 아이디 중복 확인
    public int checkIdDuplicate(String loginId);

    /**
     * [신규] 소셜 계정 연동을 해제합니다.
     * @param memberId 회원 ID
     * @param provider 소셜 서비스 제공자
     * @return 성공 여부
     */
    public boolean unlinkSocialAccount(long memberId, String provider);

    /**
     * [신규] 역할(role)이 'OWNER'인 모든 회원 목록을 조회합니다.
     * @return List<MemberVO>
     */
    public List<MemberVO> findOwners();
}
