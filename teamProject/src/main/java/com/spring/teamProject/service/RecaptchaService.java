package com.spring.teamProject.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@Service
public class RecaptchaService {

    @Value("${google.recaptcha.secret-key}")
    private String secretKey;

    private static final String RECAPTCHA_VERIFY_URL = "https://www.google.com/recaptcha/api/siteverify";

    public boolean verifyRecaptcha(String response) {
        if (response == null || response.isEmpty()) {
            return false;
        }

        RestTemplate restTemplate = new RestTemplate();
        
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("secret", secretKey);
        params.add("response", response);

        try {
            Map<String, Object> result = restTemplate.postForObject(RECAPTCHA_VERIFY_URL, params, Map.class);
            return (boolean) result.get("success");
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}