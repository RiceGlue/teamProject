package com.spring.teamProject.tool;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.spring.teamProject.service.EmailService;

@Service
public class DebugEmailUtil {

    @Autowired
    private EmailService emailService;

    /**
     * 관리자 페이지 등에서 테스트 이메일을 발송하는 유틸리티 메소드
     * @param toAddress 테스트 이메일을 받을 주소
     * @return 발송 성공 여부
     */
    public boolean sendTestEmail(String toAddress) {
        try {
            emailService.sendSimpleMessage(
                toAddress,
                "[테스트] 시스템에서 발송된 테스트 이메일입니다.",
                "이 메일이 성공적으로 도착했다면, 시스템의 이메일 발송 기능이 정상적으로 작동하고 있는 것입니다."
            );
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
