package com.spring.teamProject.config;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.spring.teamProject.service.MemberService;
import com.spring.teamProject.service.RecaptchaService;
import com.spring.teamProject.vo.MemberVO;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class RecaptchaVerificationFilter extends OncePerRequestFilter {

    @Autowired
    private MemberService memberService;

    @Autowired
    private RecaptchaService recaptchaService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        // 1. 로그인 요청인지 확인합니다. (POST /member/login)
        if (request.getRequestURI().equals(request.getContextPath() + "/member/login") && request.getMethod().equalsIgnoreCase("POST")) {
            
            String username = request.getParameter("username");
            
            // 2. username이 있는 경우에만 실패 횟수를 확인합니다.
            if (username != null && !username.isEmpty()) {
                MemberVO member = memberService.findByLoginId(username);

                // 3. 로그인 실패 횟수가 5회 이상인 경우 reCAPTCHA 검증을 수행합니다.
                if (member != null && member.getLoginFailCount() >= 5) {
                    String recaptchaResponse = request.getParameter("g-recaptcha-response");
                    
                    // 4. reCAPTCHA 응답이 없는 경우 (사용자가 새로고침 후 로그인 시도)
                    if (recaptchaResponse == null || recaptchaResponse.isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/member/login?error=recaptcha_required&username=" + username);
                        return; // 필터 체인 중단
                    }
                    
                    // 5. reCAPTCHA 응답을 검증합니다.
                    boolean isRecaptchaVerified = recaptchaService.verifyRecaptcha(recaptchaResponse);
                    if (!isRecaptchaVerified) {
                        response.sendRedirect(request.getContextPath() + "/member/login?error=recaptcha_fail&username=" + username);
                        return; // 필터 체인 중단
                    }
                }
            }
        }
        
        // 6. reCAPTCHA 검증이 필요 없거나 성공한 경우, 다음 필터로 요청을 전달합니다.
        filterChain.doFilter(request, response);
    }
}
