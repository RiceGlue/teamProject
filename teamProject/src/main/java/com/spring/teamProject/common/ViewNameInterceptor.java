package com.spring.teamProject.common;

import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ViewNameInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        try {
            String viewName = getViewName(request);
            request.setAttribute("viewName", viewName);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return true;  // 계속 진행하려면 true 리턴
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response,
                           Object handler, ModelAndView modelAndView) throws Exception {
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response,
                                Object handler, Exception ex) throws Exception {
        // 필요 시 구현
    }

    private String getViewName(HttpServletRequest request) throws Exception {
        String uri = (String) request.getAttribute("javax.servlet.include.request_uri");
        if (uri == null || uri.trim().isEmpty()) {
            uri = request.getRequestURI(); 
        }

        int end;
        if (uri.contains(";")) {
            end = uri.indexOf(";");
        } else if (uri.contains("?")) {
            end = uri.indexOf("?");
        } else {
            end = uri.length();
        }

        String viewName = uri.substring(0, end); // 확장자 제거 전 단계

        // 확장자 제거 (.do, .jsp 등)
        int dotIndex = viewName.lastIndexOf(".");
        if (dotIndex != -1) {
            viewName = viewName.substring(0, dotIndex);
        }

        return viewName;  
    }
}
