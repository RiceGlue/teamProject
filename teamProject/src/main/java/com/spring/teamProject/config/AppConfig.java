package com.spring.teamProject.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Spring Security 설정과 분리하여,
 * 애플리케이션 전반에서 사용되는 공용 Bean들을 정의하는 설정 클래스입니다.
 */
@Configuration
public class AppConfig {

    /**
     * 비밀번호 암호화를 위한 PasswordEncoder Bean을 생성합니다.
     * 이 Bean은 SecurityConfig에서 분리되어 순환 참조 문제를 해결합니다.
     * @return BCryptPasswordEncoder 인스턴스
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
