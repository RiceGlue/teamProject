package com.spring.teamProject.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import org.springframework.beans.factory.annotation.Value;

// ✨ --- 여기가 핵심 수정 부분입니다 --- ✨
// 주석을 제거하여 이 클래스가 서비스 Bean으로 등록되도록 합니다.
@Service
public class EmailServiceImpl implements EmailService {

    @Autowired
    private JavaMailSender emailSender;

    @Value("${spring.mail.username}")
    private String fromAddress;

    @Override
    public void sendSimpleMessage(String to, String subject, String text) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            // 보내는 사람 주소는 application.properties의 username과 동일해야 합니다.
            // 이 부분은 설정 파일에서 자동으로 적용되므로 직접 설정할 필요가 없습니다.
            message.setFrom(fromAddress); 
            message.setTo(to);
            message.setSubject(subject);
            message.setText(text);
            emailSender.send(message);
        } catch (Exception e) {
            // 이메일 발송 실패 시 예외 처리 (예: 로깅)
            e.printStackTrace();
            throw new RuntimeException("이메일 발송에 실패했습니다.", e);
        }
    }
}
