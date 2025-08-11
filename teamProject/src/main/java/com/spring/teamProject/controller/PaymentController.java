package com.spring.teamProject.controller;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.spring.teamProject.service.PaymentService;
import com.spring.teamProject.vo.PaymentVO;

import io.portone.sdk.server.errors.WebhookVerificationException;
// ⭐ 패키지 경로 변경 ⭐
import io.portone.sdk.server.webhook.Webhook;
import io.portone.sdk.server.webhook.WebhookVerifier;

import jakarta.servlet.http.HttpServletRequest;

@Controller
@RequestMapping("/payment")
public class PaymentController {

    private static final Logger logger = LoggerFactory.getLogger(PaymentController.class);

    @Autowired
    private PaymentService paymentService;

    // PortOne API Secret Key - 관리자 페이지에서 발급받은 실제 Secret Key
    private static final String PORTONE_API_SECRET_KEY = "hjPTj28vVQEjpoOdAP2BjPO8iicSxLhvy0i8Fn0zmptLywFYrZreldlomnU46yj9KElbhp6xYiQky544";

    // PortOne 웹훅 시크릿 키 - PortOne 관리자 페이지에서 발급받은 실제 웹훅 시크릿 키
    private static final String PORTONE_WEBHOOK_SECRET_KEY = "whsec_ugQDC2yhirm7PWTzX7m0BaB0cDsuAO1e4+bVz+0XFS8=";


    @PostMapping("/webhook")
    @ResponseBody
    public ResponseEntity<String> handlePaymentWebhook(@RequestBody String payload, HttpServletRequest request) {
        logger.info("PortOne 웹훅 요청 수신: {}", payload);

        try {
            WebhookVerifier webhookVerifier = new WebhookVerifier(PORTONE_WEBHOOK_SECRET_KEY);

            // 포트원 웹훅 요청 헤더에서 필요한 값들을 가져옵니다.
            String msgId = request.getHeader(WebhookVerifier.HEADER_ID);
            String msgSignature = request.getHeader(WebhookVerifier.HEADER_SIGNATURE);
            String msgTimestamp = request.getHeader(WebhookVerifier.HEADER_TIMESTAMP);

            webhookVerifier.verify(
                payload,
                msgId,
                msgSignature,
                msgTimestamp
            );

            logger.info("웹훅 시그니처 검증 성공!");

        } catch (WebhookVerificationException e) {
            logger.warn("웹훅 시그니처 검증 실패. 요청이 위조되었을 수 있습니다.");
            return new ResponseEntity<>("signature verification failed", HttpStatus.FORBIDDEN);
        } catch (Exception e) {
            logger.error("웹훅 시그니처 검증 중 오류 발생: {}", e.getMessage(), e);
            return new ResponseEntity<>("error during signature verification", HttpStatus.INTERNAL_SERVER_ERROR);
        }
        Gson gson = new Gson();
        Map<String, Object> payloadMap = gson.fromJson(payload, Map.class);
        String status = (String) payloadMap.get("status");
        String transactionId = (String) payloadMap.get("transactionId");

        if ("PAID".equals(status)) {
            // ... (기존 결제 성공 로직) ...
        } else if ("CANCELED".equals(status) || "FAILED".equals(status) || "REFUNDED".equals(status)) {
            // ... (기존 결제 실패/취소 로직) ...
        }

        return new ResponseEntity<>("success", HttpStatus.OK);
    }

    private String getPortOneAccessToken() throws Exception {
        URL url = new URL("https://api.portone.io/access-token");
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setRequestProperty("Content-Type", "application/json; utf-8");
        con.setDoOutput(true);

        String jsonInputString = "{\"secretKey\": \"" + PORTONE_API_SECRET_KEY + "\"}";

        try (DataOutputStream wr = new DataOutputStream(con.getOutputStream())) {
            wr.write(jsonInputString.getBytes(StandardCharsets.UTF_8));
            wr.flush();
        }

        int responseCode = con.getResponseCode();
        if (responseCode != HttpURLConnection.HTTP_OK) {
            String errorResponse = readResponse(con.getErrorStream());
            logger.error("PortOne Access Token 발급 실패 (응답 코드: {}): {}", responseCode, errorResponse);
            throw new Exception("PortOne Access Token 발급 실패: " + errorResponse);
        }

        try (BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
            Gson gson = new Gson();
            JsonObject jsonObject = gson.fromJson(response.toString(), JsonObject.class);
            return jsonObject.get("accessToken").getAsString();
        }
    }

    private String getPaymentInfo(String paymentId, String accessToken) throws Exception {
        URL url = new URL("https://api.portone.io/payments/" + paymentId);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("GET");
        con.setRequestProperty("Authorization", "Bearer " + accessToken);

        int responseCode = con.getResponseCode();
        if (responseCode != HttpURLConnection.HTTP_OK) {
            String errorResponse = readResponse(con.getErrorStream());
            logger.error("PortOne 결제 정보 조회 실패 (응답 코드: {}): {}", responseCode, errorResponse);
            throw new Exception("PortOne 결제 정보 조회 실패: " + errorResponse);
        }

        try (BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
            return response.toString();
        }
    }

    private String readResponse(java.io.InputStream is) throws Exception {
        if (is == null) return "";
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
            return response.toString();
        }
    }
}