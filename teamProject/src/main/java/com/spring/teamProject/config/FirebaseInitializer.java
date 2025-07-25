package com.spring.teamProject.config;

import java.io.InputStream;

import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import jakarta.annotation.PostConstruct;

@Configuration
public class FirebaseInitializer {

	@PostConstruct
	public void initialize() {
		try {
			// src/main/resources 에 있는 서비스 계정 키 파일 경로를 설정합니다.
			ClassPathResource resource = new ClassPathResource("firebase-service-account.json");
			InputStream serviceAccount = resource.getInputStream();

			FirebaseOptions options = new FirebaseOptions.Builder()
					.setCredentials(GoogleCredentials.fromStream(serviceAccount))
					// 자신의 Realtime Database URL을 입력하세요.
					.setDatabaseUrl("https://riceglue-9864b.firebaseio.com").build();

			// FirebaseApp이 이미 초기화되지 않았을 경우에만 초기화합니다.
			if (FirebaseApp.getApps().isEmpty()) {
				FirebaseApp.initializeApp(options);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
