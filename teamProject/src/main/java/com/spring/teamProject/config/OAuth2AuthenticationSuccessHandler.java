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
        
        HttpSession session = request.getSession();
        Boolean isLinking = (Boolean) session.getAttribute("socialLinkRequest");

        // --- ? 여기가 핵심 수정 부분입니다 ? ---
        // 1. 세션에 '계정 연동' 표식이 있는지 확인합니다.
        if (Boolean.TRUE.equals(isLinking)) {
            // 2. 표식을 사용했으니 즉시 제거하여 다음 로그인에 영향을 주지 않도록 합니다.
            session.removeAttribute("socialLinkRequest");
            
            // 3. 연동 성공 메시지를 담아 프로필 수정 페이지로 돌려보냅니다.
            session.setAttribute("msg", "Google 계정이 성공적으로 연동되었습니다.");
            getRedirectStrategy().sendRedirect(request, response, "/member/edit-profile");
            return; // 여기서 로직을 종료합니다.
        }

        // --- 이하 기존 로그인/신규가입 로직 (표식이 없는 경우에만 실행) ---
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
        String role = (String) oAuth2User.getAttributes().get("role");

        if ("GUEST".equals(role)) {
            session.setAttribute("socialUserInfo", oAuth2User.getAttributes());
            getRedirectStrategy().sendRedirect(request, response, "/member/join_social");
        } else {
            super.onAuthenticationSuccess(request, response, authentication);
        }
    }
}
