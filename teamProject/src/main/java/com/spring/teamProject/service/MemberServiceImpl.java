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
        // (수정) 전화번호를 정제하는 로직
        processPhoneNumber(memberVO);
        
        String encodedPassword = passwordEncoder.encode(memberVO.getLoginPw());
        memberVO.setLoginPw(encodedPassword);
        
        memberDAO.insertMember(memberVO);
    }
    
    @Override
    public void joinSocial(MemberVO memberVO) {
        // (수정) 전화번호를 정제하는 로직
        processPhoneNumber(memberVO);
        
        memberDAO.insertSocialMember(memberVO);
    }
    
    /**
     * (신규) 전화번호에서 불필요한 문자를 제거하고, 한국 번호의 경우 앞자리 '0'을 제거하는 메소드
     */
    private void processPhoneNumber(MemberVO memberVO) {
        if (memberVO.getPhone() != null && memberVO.getCountryCode() != null) {
            String cleanPhoneNumber = memberVO.getPhone().replaceAll("[^0-9]", "");
            
            if ("82".equals(memberVO.getCountryCode()) && cleanPhoneNumber.startsWith("0")) {
                cleanPhoneNumber = cleanPhoneNumber.substring(1);
            }
            // VO에 정제된 전화번호를 다시 설정
            memberVO.setPhone(cleanPhoneNumber);
        }
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