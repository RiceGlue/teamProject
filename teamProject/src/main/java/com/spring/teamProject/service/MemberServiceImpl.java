package com.spring.teamProject.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.spring.teamProject.dao.MemberDAO;
import com.spring.teamProject.vo.MemberVO;

@Service("memberService")
public class MemberServiceImpl implements MemberService {
	
	@Autowired
	private MemberDAO memberDAO;
	
	// (신규) SecurityConfig에 만들어 둔 PasswordEncoder를 주입받습니다.
	@Autowired
	private PasswordEncoder passwordEncoder;
	
	@Override
	public void join(MemberVO memberVO) {
		// (수정) DB에 저장하기 전에 비밀번호를 암호화합니다.
		String encodedPassword = passwordEncoder.encode(memberVO.getLoginPw());
		memberVO.setLoginPw(encodedPassword);
		
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