package com.spring.teamProject.tool;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordEncoderUtil {

    public static void main(String[] args) {
        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
        
        // --- 여기에 암호화하고 싶은 비밀번호를 입력하세요 ---
        String plainPassword = "admin1234"; 
        // ------------------------------------------------

        String encodedPassword = passwordEncoder.encode(plainPassword);

        System.out.println("--- 암호화된 비밀번호 (이것을 복사하세요) ---");
        System.out.println(encodedPassword);
        System.out.println("-------------------------------------------");
    }
}
