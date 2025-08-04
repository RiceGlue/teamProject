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
    
    @Autowired
    private OAuth2AuthenticationSuccessHandler oAuth2AuthenticationSuccessHandler;
	
    // 비밀번호 암호화를 위한 Bean
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable) // 1. CSRF 보호 비활성화

            .authorizeHttpRequests(auth -> auth
                // 2. 접근 권한 설정: 가장 구체적인 규칙부터 순서대로
                .requestMatchers("/admin/**").hasRole("ADMIN")      // /admin 경로는 ADMIN만
                .requestMatchers("/mypage/**").authenticated()    // /mypage 경로는 로그인한 사용자만
                .anyRequest().permitAll()                           // (핵심) 그 외 모든 요청은 일단 모두 허용
            )
            .formLogin(form -> form
                // 3. 커스텀 로그인 설정
                .loginPage("/member/login")					// 로그인 페이지 경로
                .loginProcessingUrl("/member/login")		// 로그인 form action 경로
                .usernameParameter("username")				// 아이디 파라미터 이름
                .passwordParameter("password")				// 비밀번호 파라미터 이름
                .defaultSuccessUrl("/", true)				// 성공 시 이동 경로
                .failureUrl("/member/login?error=true")		// 실패 시 이동 경로
            )
            .oauth2Login(oauth2 -> oauth2
            		//소셜 로그인
                    .loginPage("/member/login")
                    .userInfoEndpoint(userInfo -> userInfo
                        .userService(customOAuth2UserService)
                    )
                    // (수정) 로그인 성공 시 우리가 만든 핸들러를 사용하도록 설정
                    .successHandler(oAuth2AuthenticationSuccessHandler)
                )
            .logout(logout -> logout
                // 4. 로그아웃 설정
                .logoutUrl("/member/logout")
                .logoutSuccessUrl("/")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
            );

        return http.build();
    }
}