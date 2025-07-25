package com.spring.teamProject.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

// 보안을 활성화 하기 위해선 주석을 지우고 사용해주세요
//@Configuration
//@EnableWebSecurity // 스프링 시큐리티 설정을 활성화합니다.
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // 1. 접근 권한 설정
            .authorizeHttpRequests(auth -> auth
                // 아래 주소들은 로그인하지 않아도 누구나 접근할 수 있도록 허용
                .requestMatchers("/", "/css/**", "/js/**", "/images/**").permitAll()
                // (수정) 로그인 페이지를 명시적으로 허용 목록에 추가
                .requestMatchers("/member/login", "/member/join-select", "/member/join").permitAll() 
                .requestMatchers("/store/**").permitAll()
                // 위에 명시된 주소 외의 모든 요청은 반드시 로그인을 해야만 접근 가능
                .anyRequest().authenticated()
            )
            // 2. 우리가 만든 커스텀 로그인 페이지 설정
            .formLogin(form -> form
                .loginPage("/member/login") // 로그인이 필요한 페이지에 접근하면 이 주소로 리다이렉트
                .loginProcessingUrl("/member/login") // 로그인 폼의 action URL과 일치시켜야 함
                .defaultSuccessUrl("/", true) // 로그인 성공 시 이동할 기본 페이지
                .permitAll() // 로그인 페이지 자체에 대한 접근은 항상 허용
            )
            // 3. 로그아웃 설정
            .logout(logout -> logout
                .logoutUrl("/member/logout") // 로그아웃을 처리할 URL
                .logoutSuccessUrl("/") // 로그아웃 성공 시 이동할 페이지
                .invalidateHttpSession(true) // 세션 무효화
            )
            // 4. CSRF 보호 기능 비활성화 (개발 초기 단계에서 POST 요청 오류를 방지하기 위함)
            .csrf(AbstractHttpConfigurer::disable);

        return http.build();
    }
}
