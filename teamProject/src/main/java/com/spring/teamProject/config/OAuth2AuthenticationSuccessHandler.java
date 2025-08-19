package com.spring.teamProject.config;

import java.io.IOException;
import java.util.Map;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;
import org.springframework.security.web.savedrequest.RequestCache;
import org.springframework.security.web.savedrequest.SavedRequest;
import org.springframework.stereotype.Component;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Component
public class OAuth2AuthenticationSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private RequestCache requestCache = new HttpSessionRequestCache();

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                          Authentication authentication) throws IOException, ServletException {
        
        HttpSession session = request.getSession();
        Boolean isLinking = (Boolean) session.getAttribute("socialLinkRequest");

        // --- ? 1. '계정 연동' 시나리오 처리 (사용자가 프로필 수정 페이지에서 직접 연동을 시작한 경우) ---
        // 세션에 '계정 연동' 표식이 있는지 먼저 확인합니다.
        if (Boolean.TRUE.equals(isLinking)) {
            // 표식을 사용했으니 즉시 제거하여 다음 로그인에 영향을 주지 않도록 합니다.
            session.removeAttribute("socialLinkRequest");
            
            // 연동 성공 메시지를 담아 프로필 수정 페이지로 돌려보냅니다.
            // RedirectAttributes를 사용할 수 없으므로 세션을 통해 임시 메시지를 전달합니다.
            session.setAttribute("msg", "Google 계정이 성공적으로 연동되었습니다.");
            getRedirectStrategy().sendRedirect(request, response, "/member/edit-profile");
            return; // 여기서 로직을 종료합니다.
        }

        // --- ? 2. '신규 가입' 또는 '기존 회원 로그인' 또는 '연동 확인' 시나리오 처리 ---
        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
        Map<String, Object> attributes = oAuth2User.getAttributes();

        // 2-1. "계정 연동 확인"이 필요한 경우 (소셜 로그인 이메일과 동일한 이메일의 일반 계정이 이미 존재)
        if (Boolean.TRUE.equals(attributes.get("link_required"))) {
            session.setAttribute("socialLinkInfo", attributes); // 소셜 정보를 세션에 저장
            getRedirectStrategy().sendRedirect(request, response, "/member/link-account"); // 연동 확인 페이지로 이동
            return;
        }

        // 2-2. GUEST 권한이 있다면 완전 신규 사용자이므로 추가 정보 입력 페이지로 이동
        if (authentication.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_GUEST"))) {
            session.setAttribute("socialUserInfo", attributes);

            // 회원가입 페이지로 리다이렉트합니다.
            String targetUrl = "/member/join_social";
            getRedirectStrategy().sendRedirect(request, response, targetUrl);

        } else {
            // 3. '기존 회원 로그인' 시나리오 처리
            
            // Spring Security가 저장해 둔 '원래 가려던 페이지' 정보를 가져옵니다.
            SavedRequest savedRequest = requestCache.getRequest(request, response);

            if (savedRequest != null) {
                // '원래 가려던 페이지'가 있으면, 그곳으로 리다이렉트합니다.
                String targetUrl = savedRequest.getRedirectUrl();
                getRedirectStrategy().sendRedirect(request, response, targetUrl);
            } else {
                // '원래 가려던 페이지'가 없으면, 기본 URL(메인 페이지)로 리다이렉트합니다.
                String targetUrl = "/";
                getRedirectStrategy().sendRedirect(request, response, targetUrl);
            }
        }
    }
}
