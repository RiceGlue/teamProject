package com.spring.teamProject.vo;

import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.core.user.OAuth2User;

public class UserDetailsVO implements UserDetails, OAuth2User {

    private final MemberVO memberVO;

    public UserDetailsVO(MemberVO memberVO) {
        this.memberVO = memberVO;
    }

    // --- OAuth2User 인터페이스 구현 ---

    @Override
    public Map<String, Object> getAttributes() {
        Map<String, Object> attributes = new HashMap<>();
        attributes.put("name", memberVO.getMemberName());
        attributes.put("email", memberVO.getEmail());
        
        List<SocialAccountVO> socialAccounts = memberVO.getSocialAccounts();
        if (socialAccounts != null && !socialAccounts.isEmpty()) {
            attributes.put("socialProvider", socialAccounts.get(0).getProvider());
        }
        
        return attributes;
    }

    /**
     * [수정] Spring Security가 사용자를 식별하는 대표 이름을 반환합니다.
     * 일반 회원은 login_id를, 소셜 전용 회원은 social_id를 반환하여
     * 'principalName cannot be empty' 오류를 해결합니다.
     */
    @Override
    public String getName() {
        // 일반 계정인 경우 login_id를 반환
        if (memberVO.getLoginId() != null && !memberVO.getLoginId().isEmpty()) {
            return memberVO.getLoginId();
        }
        // 소셜 전용 계정인 경우, 연동된 첫 번째 소셜 계정의 ID를 반환
        if (memberVO.getSocialAccounts() != null && !memberVO.getSocialAccounts().isEmpty()) {
            return memberVO.getSocialAccounts().get(0).getSocialId();
        }
        // 예외 케이스 (이런 경우는 없어야 함)
        return String.valueOf(memberVO.getMemberId());
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

    /**
     * [수정] UserDetails의 username은 null이 아니어야 합니다.
     * login_id가 없는 소셜 전용 회원의 경우, 고유값인 email을 대신 반환합니다.
     */
    @Override
    public String getUsername() {
        if (memberVO.getLoginId() != null && !memberVO.getLoginId().isEmpty()) {
            return memberVO.getLoginId();
        }
        return memberVO.getEmail();
    }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() {
        return "ACTIVE".equals(memberVO.getStatus());
    }
    
    public MemberVO getMemberVO() {
        return memberVO;
    }
}
