// src/main/java/com/spring/teamProject/controller/PaymentController.java

package com.spring.teamProject.controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.spring.teamProject.service.PaymentService;
import com.spring.teamProject.vo.PaymentVO;
import jakarta.servlet.http.HttpServletRequest;
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

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Map;

@Controller
@RequestMapping("/payment")
public class PaymentController {

    private static final Logger logger = LoggerFactory.getLogger(PaymentController.class);

    @Autowired
    private PaymentService paymentService;

    // PortOne API Secret Key - 관리자 페이지에서 발급받은 실제 Secret Key로 변경해야 합니다!
    private static final String PORTONE_API_SECRET_KEY = "portone-api-key-11881682-d208-4707-8709-1ac268b64c31";

    // PortOne 웹훅 시크릿 키
    private static final String PORTONE_WEBHOOK_SECRET_KEY = "your-webhook-secret-key-from-portone";

    /**
     * PortOne 웹훅 요청을 처리하는 엔드포인트
     */
    @PostMapping("/webhook")
    @ResponseBody
    public ResponseEntity<String> handlePaymentWebhook(@RequestBody String payload, HttpServletRequest request) {
        logger.info("PortOne 웹훅 요청 수신: {}", payload);

        try {
            // 1. 웹훅 시그니처 검증
            String signature = request.getHeader(HttpHeaders.AUTHORIZATION);
            if (!verifyWebhookSignature(payload, signature)) {
                logger.warn("웹훅 시그니처 검증 실패. 요청이 위조되었을 수 있습니다.");
                return new ResponseEntity<>("signature verification failed", HttpStatus.FORBIDDEN);
            }
        } catch (Exception e) {
            logger.error("웹훅 시그니처 검증 중 오류 발생: {}", e.getMessage());
            return new ResponseEntity<>("error", HttpStatus.INTERNAL_SERVER_ERROR);
        }

        Gson gson = new Gson();
        Map<String, Object> payloadMap = gson.fromJson(payload, Map.class);
        String status = (String) payloadMap.get("status");
        String transactionId = (String) payloadMap.get("transactionId");

        if ("PAID".equals(status)) {
            try {
                // 2. PortOne API를 통해 결제 정보 조회 및 위/변조 검증
                String accessToken = getPortOneAccessToken();
                String paymentData = getPaymentInfo(transactionId, accessToken);

                JsonObject paymentObject = gson.fromJson(paymentData, JsonObject.class);
                String paymentStatus = paymentObject.get("status").getAsString();
                BigDecimal paymentAmount = paymentObject.get("amount").getAsBigDecimal();

                // 3. DB에서 transactionId로 결제 정보 조회
                PaymentVO payment = paymentService.getPaymentByTransactionId(transactionId);

                if (payment != null) {
                    // TODO: DB에 저장된 예약 금액과 비교하는 로직 추가
                    if (paymentAmount.compareTo(payment.getAmount()) == 0) {
                         if ("PAID".equals(paymentStatus)) {
                            logger.info("웹훅을 통한 결제 검증 성공! transactionId: {}", transactionId);

                            // 4. 결제 상태 업데이트 (COMPLETED)
                            payment.setStatus("COMPLETED");
                            payment.setPaidAt(LocalDateTime.now());
                            paymentService.updatePaymentStatus(payment);

                            logger.info("웹훅: 결제 및 예약 상태 업데이트 성공. reservationId: {}", payment.getReservationId());
                        } else {
                             // 결제는 됐지만 상태가 PAID가 아닌 경우
                            logger.warn("웹훅 결제 검증 실패: transactionId: {}, status: {}", transactionId, paymentStatus);
                            return new ResponseEntity<>("payment verification failed", HttpStatus.BAD_REQUEST);
                        }
                    } else {
                        logger.warn("금액 불일치: PortOne 금액({}) vs DB 금액({})", paymentAmount, payment.getAmount());
                        return new ResponseEntity<>("amount mismatch", HttpStatus.BAD_REQUEST);
                    }
                } else {
                    logger.warn("웹훅: transactionId에 해당하는 결제 정보를 찾을 수 없습니다. transactionId: {}", transactionId);
                    return new ResponseEntity<>("payment not found", HttpStatus.NOT_FOUND);
                }
            } catch (Exception e) {
                logger.error("웹훅 결제 처리 중 오류 발생: {}", e.getMessage(), e);
                return new ResponseEntity<>("error", HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }

        return new ResponseEntity<>("success", HttpStatus.OK);
    }

    // ... (나머지 헬퍼 메서드들은 그대로 유지)
    private boolean verifyWebhookSignature(String payload, String signature)
            throws NoSuchAlgorithmException, InvalidKeyException {
        // ... (기존 코드)
        return false;
    }

    private String createHmacSha256(String data, String key) throws NoSuchAlgorithmException, InvalidKeyException {
        // ... (기존 코드)
        return null;
    }

    private String getPortOneAccessToken() throws Exception {
        // ... (기존 코드)
        return null;
    }

    private String getPaymentInfo(String paymentId, String accessToken) throws Exception {
        // ... (기존 코드)
        return null;
    }

    private String readResponse(java.io.InputStream is) throws Exception {
        // ... (기존 코드)
        return null;
    }
}