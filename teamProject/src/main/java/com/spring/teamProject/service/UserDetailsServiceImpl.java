package com.spring.teamProject.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.spring.teamProject.dao.MemberDAO;
import com.spring.teamProject.vo.MemberVO;
import com.spring.teamProject.vo.UserDetailsVO;

// Spring Security의 UserDetailsService를 구현한 클래스
@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    @Autowired
    private MemberDAO memberDAO;

    // 로그인 시 스프링 시큐리티가 자동으로 이 메소드를 호출합니다.
    // username(우리 시스템의 loginId)을 기반으로 DB에서 사용자 정보를 찾아 UserDetails 객체로 반환합니다.
    @Override
    public UserDetails loadUserByUsername(String loginId) throws UsernameNotFoundException {
        MemberVO memberVO = memberDAO.findByLoginId(loginId);
        if (memberVO == null) {
            throw new UsernameNotFoundException("사용자를 찾을 수 없습니다: " + loginId);
        }
        return new UserDetailsVO(memberVO);
    }
}
