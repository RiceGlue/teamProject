package com.spring.teamProject.config;

import java.io.IOException;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class CustomAccessDeniedHandler implements AccessDeniedHandler {

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response,
                       AccessDeniedException accessDeniedException) throws IOException, ServletException {
        
        // 세션에 에러 메시지를 담아 메인 페이지로 리다이렉트합니다.
        request.getSession().setAttribute("errorMessage", "접근 권한이 없거나 잘못된 접근입니다.");
        response.sendRedirect(request.getContextPath() + "/");
    }
}
