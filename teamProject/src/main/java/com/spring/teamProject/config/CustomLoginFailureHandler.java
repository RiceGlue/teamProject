package com.spring.teamProject.config;

import com.spring.teamProject.service.MemberService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * 일반 로그인 실패 시 호출되는 커스텀 핸들러입니다.
 * 로그인 실패 횟수를 1 증가시키고, 실패한 아이디 정보를 다음 페이지로 전달하는 역할을 합니다.
 */
@Component
public class CustomLoginFailureHandler extends SimpleUrlAuthenticationFailureHandler {

    @Autowired
    private MemberService memberService;

    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
                                        AuthenticationException exception) throws IOException, ServletException {
        
        // 1. 로그인 실패 시 사용자가 입력한 아이디(username)를 가져옵니다.
        String username = request.getParameter("username");

        // 2. 아이디가 존재할 경우, MemberService를 호출하여 해당 아이디의 실패 횟수를 1 증가시킵니다.
        if (username != null && !username.isEmpty()) {
            memberService.incrementLoginFailCount(username);
        }

        // 3. 실패 후 이동할 URL을 설정합니다. 실패한 아이디를 파라미터로 함께 전달합니다.
        //    이렇게 해야 컨트롤러에서 실패 횟수를 다시 조회하여 reCAPTCHA 표시 여부를 결정할 수 있습니다.
        String encodedUsername = URLEncoder.encode(username, StandardCharsets.UTF_8);
        setDefaultFailureUrl("/member/login?error=true&username=" + encodedUsername);

        // 4. 부모 클래스의 onAuthenticationFailure를 호출하여 리다이렉트 등 기본 실패 처리를 수행합니다.
        super.onAuthenticationFailure(request, response, exception);
    }
}
