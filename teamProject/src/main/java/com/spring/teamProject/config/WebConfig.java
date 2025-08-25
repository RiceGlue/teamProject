package com.spring.teamProject.config;


import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
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

    // /profile-images/** URL로 들어오는 요청을
    // file:///C:/project/file_repo/profile/ 경로의 파일과 매핑합니다.
    // @Override
    // public void addResourceHandlers(ResourceHandlerRegistry registry) {
    //     registry.addResourceHandler("/profile-images/**")
    //             .addResourceLocations("file:///" + uploadDir);
    // }

}