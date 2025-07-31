package com.spring.teamProject.service;

import org.springframework.stereotype.Service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;

@Service
public class FCMService {

    // 이 메소드가 서버에서 전달받은 title과 body를 그대로 사용하는지 확인
    public void sendNotification(String token, String title, String body) {
        if (token == null || token.isEmpty()) {
            System.err.println("FCM token is null or empty. Cannot send notification.");
            return;
        }
        Message message = Message.builder()
                .setNotification(Notification.builder()
                        .setTitle(title)
                        .setBody(body) // <-- 이 body가 이미 완성된 문자열이어야 합니다.
                        .build())
                .setToken(token)
                .build();

        try {
            String response = FirebaseMessaging.getInstance().send(message);
            System.out.println("Successfully sent message: " + response);
        } catch (Exception e) {
            System.err.println("Failed to send message: " + e.getMessage());
        }
    }
}