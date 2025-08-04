package com.spring.teamProject.config;


import org.springframework.beans.factory.annotation.Value;

import org.springframework.context.annotation.Bean;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry; // import 추가
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import com.spring.teamProject.common.ViewNameInterceptor;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    // application.properties에 설정한 파일 저장 경로를 주입받습니다.
    @Value("${file.upload-dir}")
    private String uploadDir;
	
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new ViewNameInterceptor())
                .addPathPatterns("/**");
    }
    
    /**
     * (신규) 외부 경로의 리소스를 특정 URL 경로로 매핑합니다.
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // /profile-images/** URL 요청이 오면,
        // C:/project/file_repo/profile/ 경로에서 파일을 찾아 제공합니다.
        registry.addResourceHandler("/profile-images/**")
                .addResourceLocations("file:///" + uploadDir);
    }

}