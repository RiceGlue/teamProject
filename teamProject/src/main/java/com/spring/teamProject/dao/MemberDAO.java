package com.spring.teamProject.dao;

import org.apache.ibatis.annotations.Mapper;

import com.spring.teamProject.vo.MemberVO;

@Mapper
public interface MemberDAO {
	
    // (신규) 이메일로 회원 정보 조회
    MemberVO findByEmail(String email);
    
    // (신규) 소셜 로그인 사용자를 DB에 삽입
    void insertSocialMember(MemberVO memberVO);
	
	// loginId로 회원 정보 조회 (스프링 시큐리티용)
	MemberVO findByLoginId(String loginId);
	
	// 회원가입
	public void insertMember(MemberVO memberVO);
	
	// 로그인
	public MemberVO login(MemberVO memberVO);
	
	/*
	 * 회원정보 수정
	 * MyBatis와 같은 데이터 프레임 워크는 INSERT, UPDATE, DELETE 쿼리를 실행한 후
	 * 해당 쿼리로 인해 영향을 받은 데이터의 행 개수를 정수(int)로 반환함
	 * 회원 수정 행수가 1개일경우 1 반환 회원 수정이 없을경우 0이 반환 됌
	 */
	public int updateMember(MemberVO memberVO);
	
	/*
	 * 회원탈퇴
	 * 회원정보 수정과 같은 사유로 int형으로 보냅니다
	 * 회원탈퇴가 정상적으로 실행되지 않았다면 0을 반환합니다
	 */
	public int deleteMember(long member_id);
}
