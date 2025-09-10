package com.spring.teamProject.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.teamProject.vo.MemberVO;
import java.util.List;

@Mapper
public interface MemberDAO {
    
    // memberId로 회원 정보 조회
    MemberVO findById(long memberId);
    
    // 이메일로 회원 정보 조회
    MemberVO findByEmail(String email);
    
    // loginId로 회원 정보 조회 (Security용)
    MemberVO findByLoginId(String loginId);
    
    // [삭제] 소셜 회원가입 메소드 제거 (일반 회원가입으로 통합)
    // void insertSocialMember(MemberVO memberVO);
    
    // 일반 회원가입
    void insertMember(MemberVO memberVO);
    
    // (레거시) 로그인 처리 - Security가 인증을 대신 처리합니다.
    MemberVO login(MemberVO memberVO);
    
    // [삭제] 기존 회원의 소셜 정보 업데이트 메소드 제거
    // int updateSocialInfo(MemberVO memberVO);
    
    // 아이디 중복 확인
    int checkIdDuplicate(String loginId);

    // 회원정보 수정
    int updateMember(MemberVO memberVO);
    
    // 회원 탈퇴 (논리적 삭제로 변경)
    int deactivateMember(long memberId);

    /**
     * 역할(role)이 'OWNER'인 모든 회원 목록을 조회합니다.
     * @return List<MemberVO>
     */
    List<MemberVO> findOwners();

    List<MemberVO> findUsers();

    // 소셜 전용 회원의 아이디/비밀번호 설정을 위한 메소드
    int updateLoginCredentials(MemberVO memberVO);

    // ✨ --- [수정] findByNameAndPhone 메소드를 findByNameAndEmail로 변경합니다. --- ✨
    MemberVO findByNameAndEmail(@Param("memberName") String memberName, @Param("email") String email);

    // --- [신규] 비밀번호 재설정을 위한 사용자 확인 메소드 ---
    MemberVO findByLoginIdAndEmail(@Param("loginId") String loginId, @Param("email") String email);

    // --- [신규] 비밀번호를 업데이트하는 메소드 ---
    int updatePassword(@Param("memberId") long memberId, @Param("encodedPassword") String encodedPassword);
    
    MemberVO selectMemberById(long memberId);
    
    // [추가] 로그인 실패 횟수 관리를 위한 메소드
    MemberVO findForUpdateByLoginId(String loginId); // 비관적 잠금(Pessimistic Lock)을 사용하여 동시성 문제 방지
    void incrementLoginFailCount(String loginId);
    void resetLoginFailCount(String loginId);
}
