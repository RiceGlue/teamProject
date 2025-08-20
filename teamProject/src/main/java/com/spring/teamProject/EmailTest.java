
package com.spring.teamProject;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

// ✨ 중요: 테스트를 위해 임시로 @SpringBootApplication 어노테이션을 붙여줍니다.
@SpringBootApplication
public class EmailTest {

    public static void main(String[] args) {
        System.setProperty("mail.smtp.localhost", "localhost");
        // Spring Boot 애플리케이션을 실행하지만, 웹 서버는 띄우지 않습니다.
        System.setProperty("spring.main.web-application-type", "none");
        ApplicationContext context = SpringApplication.run(TeamProjectApplication.class, args);

        // 실행된 Spring 컨텍스트에서 JavaMailSender Bean을 직접 가져옵니다.
        JavaMailSender mailSender = context.getBean(JavaMailSender.class);

        // --- 1. 받는 사람 이메일 주소를 입력해주세요 ---
        String to = "sldp666@gmail.com";
        // -----------------------------------------

        System.out.println("'" + to + "' 주소로 테스트 이메일 발송을 시도합니다...");

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(to);
            message.setFrom("wkjogreen@gmail.com");
            message.setSubject("[얌테이블 프로젝트] 독립 Java 파일 이메일 발송 테스트");
            message.setText("이 메일이 성공적으로 도착했다면, application.properties의 이메일 설정은 완벽합니다!");

            mailSender.send(message);

            System.out.println("✅ 메일 발송에 성공했습니다!");

        } catch (Exception e) {
            System.out.println("❌ 메일 발송에 실패했습니다.");
            e.printStackTrace(); // 실패 시 상세한 오류 로그를 출력합니다.
        }
        
        // 테스트가 끝나면 애플리케이션을 종료합니다.
        System.exit(0);
    }
}