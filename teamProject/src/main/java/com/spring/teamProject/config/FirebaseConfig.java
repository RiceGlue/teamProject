package com.spring.teamProject.config;

import java.io.InputStream;

import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import jakarta.annotation.PostConstruct;

@Configuration
public class FirebaseConfig {

	@PostConstruct
	public void initialize() {
		try {
			// src/main/resources 에 있는 서비스 계정 키 파일 경로를 설정합니다.
			ClassPathResource resource = new ClassPathResource("firebase-service-account.json");
			InputStream serviceAccount = resource.getInputStream();

			FirebaseOptions options = new FirebaseOptions.Builder()
					.setCredentials(GoogleCredentials.fromStream(serviceAccount))
					// 자신의 Realtime Database URL을 입력하세요.
					// 이 부분을 정확한 아시아 남동부 리전 URL로 변경해야 합니다!
					.setDatabaseUrl("https://riceglue-9864b-default-rtdb.asia-southeast1.firebasedatabase.app/") // <--- 여기를 수정!
					.build();

			// FirebaseApp이 이미 초기화되지 않았을 경우에만 초기화합니다.
			if (FirebaseApp.getApps().isEmpty()) {
				FirebaseApp.initializeApp(options);
				System.out.println("Firebase Admin SDK initialized successfully with correct database URL."); // 로그 추가
			}

		} catch (Exception e) {
			System.err.println("Firebase Admin SDK initialization failed: " + e.getMessage()); // 오류 로그 추가
			e.printStackTrace();
		}
	}

}
