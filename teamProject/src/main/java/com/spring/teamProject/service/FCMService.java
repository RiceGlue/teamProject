package com.spring.teamProject.service;

import org.springframework.stereotype.Service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;

@Service
public class FCMService {
	
	
	public void sendNotification(String token, String title, String body) {
        // FCM 토큰이 없으면 알림을 보내지 않습니다.
        if (token == null || token.isEmpty()) {
            System.out.println("FCM Token is null. Skipping notification.");
            return;
        }

        Notification notification = Notification.builder()
            .setTitle(title)
            .setBody(body)
            .build();

        Message message = Message.builder()
            .setNotification(notification)
            .setToken(token) // 알림을 받을 대상 디바이스의 토큰 설정
            .build();

        try {
            // 메시지 전송
            String response = FirebaseMessaging.getInstance().send(message);
            System.out.println("Successfully sent message: " + response);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
