package com.spring.teamProject.service;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
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
import com.spring.teamProject.vo.UserDetailsVO;

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

        String provider = userRequest.getClientRegistration().getRegistrationId().toUpperCase();
        String socialId = oAuth2User.getName();
        String email = oAuth2User.getAttribute("email");

        // --- ? 여기가 핵심 수정 부분입니다 ? ---
        // 1. 현재 로그인한 사용자가 있는지 확인합니다. (계정 연동 시나리오)
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated() && authentication.getPrincipal() instanceof UserDetailsVO) {
            
            // 2. 이미 다른 계정에 연동된 소셜 정보인지 확인하여 보안을 강화합니다.
            SocialAccountVO existingSocial = socialAccountDAO.findByProviderAndSocialId(provider, socialId);
            if (existingSocial != null) {
                // 이 예외는 나중에 Controller에서 잡아서 사용자에게 메시지를 보여줄 수 있습니다.
                throw new OAuth2AuthenticationException("이미 다른 계정에 연동된 소셜 계정입니다.");
            }

            // 3. 현재 로그인된 사용자의 정보를 가져와 새로운 소셜 계정을 DB에 연동합니다.
            UserDetailsVO userDetails = (UserDetailsVO) authentication.getPrincipal();
            long memberId = userDetails.getMemberVO().getMemberId();
            
            SocialAccountVO newSocialAccount = new SocialAccountVO();
            newSocialAccount.setMemberId(memberId);
            newSocialAccount.setProvider(provider);
            newSocialAccount.setSocialId(socialId);
            socialAccountDAO.insertSocialAccount(newSocialAccount);
            
            // 4. DB에서 최신 회원 정보를 다시 불러와(연동된 소셜 계정 목록 포함) 세션을 수동으로 갱신합니다.
            //    이것이 세션 덮어쓰기를 막고, 기존 로그인 상태를 유지시키는 핵심입니다.
            MemberVO updatedMember = memberDAO.findById(memberId);
            UserDetailsVO newPrincipal = new UserDetailsVO(updatedMember);
            Authentication newAuth = new UsernamePasswordAuthenticationToken(newPrincipal, authentication.getCredentials(), newPrincipal.getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(newAuth);
            
            // 5. 갱신된 사용자 정보를 반환하여 현재 세션을 유지합니다.
            return newPrincipal;
        }

        // --- 로그인/신규가입 시나리오 ---
        MemberVO member = null;
        
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

        if (member != null) {
            // DB에 정보가 있는 사용자 (기존 소셜 유저 또는 방금 연동된 유저)
            if ("OWNER".equals(member.getRole()) || "ADMIN".equals(member.getRole())) {
                throw new OAuth2AuthenticationException("가맹점주 및 관리자 계정은 소셜 로그인을 이용할 수 없습니다.");
            }
            
            // --- ? 여기가 핵심 수정 부분입니다 ? ---
            // MyBatis의 지연 로딩 문제를 피하기 위해, social_accounts 정보를 명시적으로 다시 조회하여 주입합니다.
            List<SocialAccountVO> socialAccounts = socialAccountDAO.findByMemberId(member.getMemberId());
            member.setSocialAccounts(socialAccounts);
            
            // 이제 모든 정보가 완벽하게 채워진 MemberVO로 UserDetailsVO를 생성합니다.
            return new UserDetailsVO(member);
        } else {
            // 어디에도 정보가 없는 완전 신규 사용자 -> 추가 정보 입력을 위해 GUEST 역할 부여
            Map<String, Object> attributes = new java.util.HashMap<>(oAuth2User.getAttributes());
            attributes.put("role", "GUEST");
            attributes.put("socialProvider", provider); // 핸들러에서 사용하기 위해 추가
            
            return new DefaultOAuth2User(
                    Collections.singleton(new SimpleGrantedAuthority("ROLE_GUEST")),
                    attributes,
                    "sub" // Google의 경우 nameAttributeKey가 'sub'
            );
        }
    }
}
