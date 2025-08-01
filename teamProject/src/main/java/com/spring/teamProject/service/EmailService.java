package com.spring.teamProject.service;

public interface EmailService {

    /**
     * 간단한 텍스트 이메일을 발송합니다.
     * @param to      수신자 이메일 주소
     * @param subject 이메일 제목
     * @param text    이메일 본문 내용
     */
    void sendSimpleMessage(String to, String subject, String text);

}
