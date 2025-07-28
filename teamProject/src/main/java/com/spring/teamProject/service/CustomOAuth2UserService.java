package com.spring.teamProject.service;

import java.util.Collections;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import com.spring.teamProject.dao.MemberDAO;
import com.spring.teamProject.vo.MemberVO;

@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    @Autowired
    private MemberDAO memberDAO;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);

        String registrationId = userRequest.getClientRegistration().getRegistrationId();
        String userNameAttributeName = userRequest.getClientRegistration().getProviderDetails().getUserInfoEndpoint().getUserNameAttributeName();

        String email = oAuth2User.getAttribute("email");
        String name = oAuth2User.getAttribute("name");
        String socialId = oAuth2User.getAttribute(userNameAttributeName);

        MemberVO member = memberDAO.findByEmail(email);
        String role;

        if (member != null) {
            // 이미 가입된 사용자인 경우
            if ("OWNER".equals(member.getRole()) || "ADMIN".equals(member.getRole())) {
                // (수정) 역할이 점주나 관리자이면 소셜 로그인을 차단하고 예외를 발생시킵니다.
                throw new OAuth2AuthenticationException("가맹점주 및 관리자 계정은 소셜 로그인을 이용할 수 없습니다.");
            }
            role = member.getRole(); // 기존 'USER' 역할 부여
        } else {
            // 처음 방문한 사용자는 추가 정보 입력을 위해 임시 역할 'GUEST'를 부여합니다.
            role = "GUEST"; 
        }

        Map<String, Object> attributes = new java.util.HashMap<>(oAuth2User.getAttributes());
        attributes.put("role", role); // 역할 정보 추가

        return new DefaultOAuth2User(
                Collections.singleton(new SimpleGrantedAuthority("ROLE_" + role)),
                attributes,
                userNameAttributeName
        );
    }
}
