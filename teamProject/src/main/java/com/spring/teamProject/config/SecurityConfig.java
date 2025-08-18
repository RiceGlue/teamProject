package com.spring.teamProject.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

import com.spring.teamProject.service.CustomOAuth2UserService;

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

    // 비밀번호 암호화를 위한 Bean
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)

            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/admin/**").hasRole("ADMIN")                       // /admin/** 경로는 ADMIN 역할만 접근 가능
                .requestMatchers("/owner/**").hasRole("OWNER")                       // /owner/** 경로는 OWNER 역할만 접근 가능
                .requestMatchers("/member/mypage/**").authenticated()                // ? /member/mypage 하위 경로도 인증 필요
                .requestMatchers("/reservation/**", "/waiting/**").authenticated()   // reservation 페이지나 waiting 페이지로 이동할때 로그인을 유도함
                .anyRequest().permitAll()
            )
            .formLogin(form -> form
                .loginPage("/member/login")
                .loginProcessingUrl("/member/login")
                .usernameParameter("username")
                .passwordParameter("password")
                .defaultSuccessUrl("/")
                .failureUrl("/member/login?error=true")
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
            );

        return http.build();
    }
}
