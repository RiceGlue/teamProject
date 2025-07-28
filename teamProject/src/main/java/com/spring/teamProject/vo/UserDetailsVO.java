package com.spring.teamProject.vo;

import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User; // OAuth2User import

// (수정) OAuth2User 인터페이스를 함께 구현하도록 변경
public class UserDetailsVO implements UserDetails, OAuth2User {

    private final MemberVO memberVO;

    public UserDetailsVO(MemberVO memberVO) {
        this.memberVO = memberVO;
    }

    // --- OAuth2User 인터페이스 구현 ---

    @Override
    public Map<String, Object> getAttributes() {
        // (신규) 소셜 로그인 사용자와 데이터 구조를 통일하기 위해 attributes 맵을 생성하여 반환합니다.
        Map<String, Object> attributes = new HashMap<>();
        attributes.put("name", memberVO.getMemberName()); // 'name' 키에 사용자 이름을 저장
        attributes.put("email", memberVO.getEmail());
        // 필요한 다른 정보들도 여기에 추가할 수 있습니다.
        return attributes;
    }

    @Override
    public String getName() {
        // UserDetails의 getUsername과 동일하게 로그인 ID를 반환하도록 설정
        return memberVO.getLoginId();
    }


    // --- UserDetails 인터페이스 구현 ---

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
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

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() { return true; }
    
    public MemberVO getMemberVO() {
        return memberVO;
    }
}
