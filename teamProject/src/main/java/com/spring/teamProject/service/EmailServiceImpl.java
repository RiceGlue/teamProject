package com.spring.teamProject.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

//이메일 관련서비스 시작시 다시 활성화 예정
//사용시 값도 넣어야함
//@Service
public class EmailServiceImpl implements EmailService {

    @Autowired
    private JavaMailSender emailSender;

    @Override
    public void sendSimpleMessage(String to, String subject, String text) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom("YOUR_GMAIL_ADDRESS@gmail.com"); // 보내는 사람 (properties와 동일해야 함)
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
