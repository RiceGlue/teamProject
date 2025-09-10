package com.spring.teamProject.service;

import com.spring.teamProject.vo.MemberVO;
import java.util.List;

public interface MemberService {
	
	// 회원가입
	public void join(MemberVO memberVO);
	
	// (레거시) 로그인 - 현재 Spring Security가 처리
	public MemberVO login(MemberVO memberVO);
	
	// 회원정보 수정
	public boolean updateMember(MemberVO memberVO);
	
	// 회원 탈퇴 (논리적 삭제)
	public boolean deactivateMember(long memberId);
	
	// 이메일로 회원 정보 조회
	public MemberVO findByEmail(String email);
	
	// memberId로 회원 정보 조회 (내부 로직용)
	public MemberVO findById(long memberId);

	// 아이디 중복 확인
	public int checkIdDuplicate(String loginId);

	/**
	 * 소셜 계정 연동을 해제합니다.
	 * @param memberId 회원 ID
	 * @param provider 소셜 서비스 제공자
	 * @return 성공 여부
	 */
	public boolean unlinkSocialAccount(long memberId, String provider);

	/**
	 * 역할(role)이 'OWNER'인 모든 회원 목록을 조회합니다.
	 * @return List<MemberVO>
	 */
	public List<MemberVO> findOwners();

	/**
	 * 역할(role)이 'USER'인 모든 회원 목록을 조회합니다.
	 * @return List<MemberVO>
	 */
	public List<MemberVO> findUsers();

    /**
     * 소셜 전용 회원의 아이디/비밀번호를 설정하여 일반 계정으로 전환합니다.
     * @param memberId 회원 ID
     * @param loginId 새로 설정할 로그인 아이디
     * @param newPassword 새로 설정할 비밀번호
     * @return 성공 여부
     */
    boolean setPasswordForSocialUser(long memberId, String loginId, String newPassword);

    /**
     * 아이디와 비밀번호를 모두 확인하여 소셜 계정을 연동합니다.
     * @param email 기존 계정의 이메일
     * @param loginId 기존 계정의 아이디
     * @param rawPassword 사용자가 입력한 비밀번호
     * @param provider 소셜 서비스 제공자
     * @param socialId 소셜 서비스의 고유 ID
     * @return 연동이 완료된 회원 정보
     */
    MemberVO verifyIdAndPasswordAndLinkAccount(String email, String loginId, String rawPassword, String provider, String socialId);
	
    // --- 아이디 찾기 로직 ---
    String findLoginId(String memberName, String email);

    // --- 비밀번호 재설정 로직 ---
    boolean resetPassword(String loginId, String email);

    // ? --- [신규] 아이디 찾기 시 테스트 이메일을 발송하는 메소드 --- ?
    //boolean sendFindIdTestEmail(String memberName, String email);

    // ? --- [수정] 아이디 찾기 로직을 '인증 이메일 발송' 기능으로 변경 --- ?
    String sendVerificationCodeForId(String memberName, String email);
    
    MemberVO getMemberById(long memberId);
    
    // [추가] 로그인 실패/성공 카운트 처리를 위한 메소드 선언
    void incrementLoginFailCount(String loginId);
    void resetLoginFailCount(String loginId);
    MemberVO findByLoginId(String loginId);
}