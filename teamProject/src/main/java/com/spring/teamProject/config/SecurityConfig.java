package com.spring.teamProject.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.spring.teamProject.service.CustomOAuth2UserService;

import jakarta.servlet.http.HttpServletResponse;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // @Autowired를 사용하여 필요한 서비스들을 주입
    @Autowired
    private CustomOAuth2UserService customOAuth2UserService;

    // --- 로그인 성공 핸들러를 주입받습니다. ---
    @Autowired
    private OAuth2AuthenticationSuccessHandler oAuth2AuthenticationSuccessHandler;

    // --- 1. 새로 만든 핸들러를 주입받습니다. ---
    @Autowired
    private CustomAccessDeniedHandler customAccessDeniedHandler;

    // [추가] 로그인 실패/성공 핸들러와 reCAPTCHA 필터를 주입받습니다.
    @Autowired
    private CustomLoginSuccessHandler customLoginSuccessHandler;

    @Autowired
    private CustomLoginFailureHandler customLoginFailureHandler;

    @Autowired
    private RecaptchaVerificationFilter recaptchaVerificationFilter;

    // [수정] PasswordEncoder Bean은 AppConfig로 이동되었습니다.

    // [복원] 정적 리소스는 Spring Security의 보안 필터를 거치지 않도록 설정합니다.
    @Bean
    public WebSecurityCustomizer webSecurityCustomizer() {
        return (web) -> web.ignoring().requestMatchers("/images/**", "/js/**", "/css/**");
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)

            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/admin/**").hasRole("ADMIN")                      // /admin/** 경로는 ADMIN 역할만 접근 가능
                .requestMatchers("/owner/**", "/franchise/**", "/settlement/**").hasRole("OWNER") // /owner/**, /franchise/**, /settlement/** 경로는 OWNER 역할만 접근 가능
                .requestMatchers("/member/mypage/**", "/member/edit-profile").authenticated()      // ? /member/mypage 하위 경로도 인증 필요
                .requestMatchers("/reservation/**", "/waiting/**").authenticated()   // reservation 페이지나 waiting 페이지로 이동할때 로그인을 유도함
                .anyRequest().permitAll()
            )
            .formLogin(form -> form
                .loginPage("/member/login")
                .loginProcessingUrl("/member/login")
                .usernameParameter("username")
                .passwordParameter("password")
                // [수정] 기본 성공/실패 URL 대신, 직접 만든 핸들러를 사용하도록 변경합니다.
                .successHandler(customLoginSuccessHandler)
                .failureHandler(customLoginFailureHandler)
            )
            .oauth2Login(oauth2 -> oauth2
                .loginPage("/member/login")
                .userInfoEndpoint(userInfo -> userInfo
                    .userService(customOAuth2UserService)
                )
                // --- defaultSuccessUrl을 지우고, 우리가 만든 successHandler를 등록합니다. ---
                .successHandler(oAuth2AuthenticationSuccessHandler)
            )
            .logout(logout -> logout
                .logoutUrl("/member/logout")
                .logoutSuccessUrl("/")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
            )
            // ? --- 2. 접근 거부(403) 상황이 발생하면, 우리가 만든 핸들러를 사용하도록 설정합니다. --- ?
            .exceptionHandling(exception -> exception
                .accessDeniedHandler(customAccessDeniedHandler)
                .authenticationEntryPoint(ajaxAwareAuthenticationEntryPoint())
            );
            
        // [추가] 직접 만든 reCAPTCHA 필터를 Spring Security의 기본 로그인 필터보다 먼저 실행되도록 등록합니다.
        http.addFilterBefore(recaptchaVerificationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    // ✨ 새로운 Bean을 추가하여 AJAX 요청을 구분합니다. ✨
    @Bean
    public AuthenticationEntryPoint ajaxAwareAuthenticationEntryPoint() {
        return (request, response, authException) -> {
            // 'X-Requested-With' 헤더로 AJAX 요청인지 확인합니다.
            if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
                // AJAX 요청인 경우, 401 Unauthorized 상태 코드를 반환합니다.
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
            } else {
                // 일반적인 웹 브라우저 요청인 경우, 로그인 페이지로 리디렉션합니다.
                response.sendRedirect("/member/login");
            }
        };
    }
}

