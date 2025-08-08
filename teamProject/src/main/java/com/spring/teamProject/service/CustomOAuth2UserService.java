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
import org.springframework.transaction.annotation.Transactional;

import com.spring.teamProject.dao.MemberDAO;
import com.spring.teamProject.dao.SocialAccountDAO;
import com.spring.teamProject.vo.MemberVO;
import com.spring.teamProject.vo.SocialAccountVO;

@Service
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    @Autowired
    private MemberDAO memberDAO;

    @Autowired
    private SocialAccountDAO socialAccountDAO;

    @Override
    @Transactional
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(userRequest);

        String provider = userRequest.getClientRegistration().getRegistrationId().toUpperCase(); // "GOOGLE"
        String socialId = oAuth2User.getName();
        String email = oAuth2User.getAttribute("email");

        MemberVO member = null;
        String role = null;

        // 1. provider와 socialId로 social_accounts 테이블에서 계정을 찾습니다.
        SocialAccountVO socialAccount = socialAccountDAO.findByProviderAndSocialId(provider, socialId);

        if (socialAccount != null) {
            // 2-1. 이미 소셜 계정이 연동된 경우 -> 기존 회원으로 로그인 처리
            member = memberDAO.findById(socialAccount.getMemberId());
        } else {
            // 2-2. 연동된 소셜 계정이 없는 경우 -> 이메일로 기존 회원이 있는지 확인
            member = memberDAO.findByEmail(email);
            if (member != null) {
                // 3-1. 이메일이 같은 회원이 있다면 -> 새로운 소셜 계정을 기존 계정에 연동
                SocialAccountVO newSocialAccount = new SocialAccountVO();
                newSocialAccount.setMemberId(member.getMemberId());
                newSocialAccount.setProvider(provider);
                newSocialAccount.setSocialId(socialId);
                socialAccountDAO.insertSocialAccount(newSocialAccount);
            }
        }

        Map<String, Object> attributes = new java.util.HashMap<>(oAuth2User.getAttributes());

        if (member != null) {
            // 4. 기존 회원이거나, 방금 계정을 연동한 경우
            if ("OWNER".equals(member.getRole()) || "ADMIN".equals(member.getRole())) {
                throw new OAuth2AuthenticationException("가맹점주 및 관리자 계정은 소셜 로그인을 이용할 수 없습니다.");
            }
            role = member.getRole();
            attributes.put("name", member.getMemberName()); // 이름은 우리 DB 기준으로 덮어쓰기
        } else {
            // 5. 어디에도 정보가 없는 완전 신규 사용자 -> 추가 정보 입력을 위해 GUEST 역할 부여
            role = "GUEST";
        }

        attributes.put("role", role);
        
        // --- ? 여기가 핵심 수정 부분입니다 ? ---
        // principal 객체에 소셜 제공자 정보를 추가하여, JSP에서 아이콘을 표시할 수 있도록 합니다.
        attributes.put("socialProvider", provider);
        
        return new DefaultOAuth2User(
                Collections.singleton(new SimpleGrantedAuthority("ROLE_" + role)),
                attributes,
                "sub" // Google의 경우 nameAttributeKey가 'sub'
        );
    }
}
