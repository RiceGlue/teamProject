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
        
        // [수정] socialAccounts 리스트를 확인하여 소셜 연동 정보를 추가합니다.
        List<SocialAccountVO> socialAccounts = memberVO.getSocialAccounts();
        if (socialAccounts != null && !socialAccounts.isEmpty()) {
            // 여러 개가 연동될 수 있지만, 우선 첫 번째 것을 대표로 사용합니다.
            attributes.put("socialProvider", socialAccounts.get(0).getProvider());
        }
        
        return attributes;
    }

    @Override
    public String getName() {
        // 소셜 로그인의 경우 고유 ID를 반환해야 하지만, 일반 로그인의 Principal에서는 loginId를 반환합니다.
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
    public boolean isEnabled() {
        // [수정] 논리적 삭제를 위해 status가 'ACTIVE'인 경우에만 계정을 활성화합니다.
        return "ACTIVE".equals(memberVO.getStatus());
    }
    
    public MemberVO getMemberVO() {
        return memberVO;
    }
}
