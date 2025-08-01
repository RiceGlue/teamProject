package com.spring.teamProject.config;

import java.io.IOException;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Component
public class OAuth2AuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {
        
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
        String role = (String) oAuth2User.getAttributes().get("role");

        if ("GUEST".equals(role)) {
            // 신규 사용자인 경우, 추가 정보 입력을 위해 소셜 정보를 세션에 임시 저장
            HttpSession session = request.getSession();
            session.setAttribute("socialUserInfo", oAuth2User.getAttributes());
            
            // 추가 정보 입력 페이지로 리다이렉트
            getRedirectStrategy().sendRedirect(request, response, "/member/join_social");
        } else {
            // 기존 사용자인 경우, 메인 페이지로 리다이렉트
            super.onAuthenticationSuccess(request, response, authentication);
        }
    }
}
