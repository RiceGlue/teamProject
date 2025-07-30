package com.spring.teamProject.dao;

import org.apache.ibatis.annotations.Mapper;
import com.spring.teamProject.vo.MemberVO;

@Mapper
public interface MemberDAO {
    
    // memberId로 회원 정보 조회 (마이페이지용)
    MemberVO findById(long memberId);
    
    // 이메일로 회원 정보 조회 (소셜 로그인용)
    MemberVO findByEmail(String email);
    
    // loginId로 회원 정보 조회 (Security용)
	MemberVO findByLoginId(String loginId);
	
    // 소셜 회원가입
    void insertSocialMember(MemberVO memberVO);
	
	// 일반 회원가입
	void insertMember(MemberVO memberVO);
	
	// (레거시) 로그인 처리 - Security가 인증을 대신 처리합니다.
	MemberVO login(MemberVO memberVO);
	
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
	public int deleteMember(long memberId);
}
