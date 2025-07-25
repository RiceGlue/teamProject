package com.spring.teamProject.vo;

import java.util.Collection;
import java.util.Collections;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

// 우리 MemberVO를 스프링 시큐리티가 이해할 수 있는 UserDetails 형태로 변환하는 클래스
public class UserDetailsVO implements UserDetails {

    private final MemberVO memberVO;

    public UserDetailsVO(MemberVO memberVO) {
        this.memberVO = memberVO;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // 사용자의 권한(role)을 GrantedAuthority 컬렉션으로 반환
        // 예: "ROLE_USER", "ROLE_OWNER"
        return Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + memberVO.getRole()));
    }

    @Override
    public String getPassword() {
        return memberVO.getLoginPw();
    }

    @Override
    public String getUsername() {
        return memberVO.getLoginId();
    }

    // 계정이 만료되지 않았는지 리턴 (true: 만료안됨)
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    // 계정이 잠겨있지 않은지 리턴 (true: 잠기지 않음)
    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    // 비밀번호가 만료되지 않았는지 리턴 (true: 만료안됨)
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    // 계정이 활성화(사용가능)인지 리턴 (true: 활성화)
    @Override
    public boolean isEnabled() {
        return true;
    }
    
    // MemberVO 객체를 반환하는 getter
    public MemberVO getMemberVO() {
        return memberVO;
    }
}
