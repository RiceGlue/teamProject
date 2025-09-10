package com.spring.teamProject.config;

import com.spring.teamProject.service.MemberService;
import com.spring.teamProject.vo.UserDetailsVO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * 일반 로그인 성공 시 호출되는 커스텀 핸들러입니다.
 * 로그인 성공 후, 해당 회원의 누적된 로그인 실패 횟수를 0으로 초기화하는 역할을 합니다.
 */
@Component
public class CustomLoginSuccessHandler extends SavedRequestAwareAuthenticationSuccessHandler {

    @Autowired
    private MemberService memberService;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws ServletException, IOException {

        // 1. 로그인에 성공한 사용자 정보를 가져옵니다.
        Object principal = authentication.getPrincipal();

        // 2. 사용자 정보가 UserDetailsVO 타입인지 확인합니다.
        if (principal instanceof UserDetailsVO) {
            UserDetailsVO userDetails = (UserDetailsVO) principal;
            String loginId = userDetails.getUsername(); // UserDetails의 username은 loginId를 반환합니다.

            // 3. MemberService를 호출하여 해당 사용자의 로그인 실패 횟수를 0으로 초기화합니다.
            if (loginId != null && !loginId.isEmpty()) {
                memberService.resetLoginFailCount(loginId);
            }
        }

        // 4. 부모 클래스의 onAuthenticationSuccess를 호출하여,
        //    로그인 전 접근하려던 페이지가 있었다면 그곳으로 리다이렉트하고,
        //    없었다면 기본 성공 URL('/')로 리다이렉트하는 등 기본 성공 처리를 수행합니다.
        super.onAuthenticationSuccess(request, response, authentication);
    }
}
