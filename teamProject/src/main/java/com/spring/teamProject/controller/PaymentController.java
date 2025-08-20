package com.spring.teamProject.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.spring.teamProject.service.PaymentService;
import com.spring.teamProject.service.ReservationService;
import com.spring.teamProject.vo.PaymentVO;

import io.portone.sdk.server.errors.WebhookVerificationException;
import io.portone.sdk.server.webhook.WebhookVerifier;

import jakarta.servlet.http.HttpServletRequest;

@Controller
@RequestMapping("/payment")
public class PaymentController {

    private static final Logger logger = LoggerFactory.getLogger(PaymentController.class);

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private ReservationService reservationService; // 예약 상태 업데이트를 위해 추가

    // V2 API Secret 키
    private static final String PORTONE_API_SECRET_KEY = "hjPTj28vVQEjpoOdAP2BjPO8iicSxLhvy0i8Fn0zmptLywFYrZreldlomnU46yj9KElbhp6xYiQky544";
    private static final String PORTONE_WEBHOOK_SECRET_KEY = "whsec_ugQDC2yhirm7PWTzX7m0BaB0cDsuAO1e4+bVz+0XFS8=";

    @PostMapping("/webhook")
    @ResponseBody
    public ResponseEntity<String> handlePaymentWebhook(@RequestBody String payload, HttpServletRequest request) {
    	logger.info("PortOne 웹훅 요청 수신. payload: {}", payload);

        try {
            WebhookVerifier webhookVerifier = new WebhookVerifier(PORTONE_WEBHOOK_SECRET_KEY);
            String msgId = request.getHeader(WebhookVerifier.HEADER_ID);
            String msgSignature = request.getHeader(WebhookVerifier.HEADER_SIGNATURE);
            String msgTimestamp = request.getHeader(WebhookVerifier.HEADER_TIMESTAMP);

            webhookVerifier.verify(payload, msgId, msgSignature, msgTimestamp);
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
        String transactionId = (String) payloadMap.get("payment_id");
        logger.info("웹훅에서 추출한 transactionId: {}", transactionId);

        if ("PAID".equals(status.toUpperCase())) {
            try {
                String paymentData = getPaymentInfoByPaymentId(transactionId);

                if (paymentData == null) {
                    logger.warn("PortOne 결제 정보를 찾을 수 없습니다. (API 404 응답). 웹훅 처리를 성공으로 간주합니다. transactionId: {}", transactionId);
                    return new ResponseEntity<>("success", HttpStatus.OK);
                }

                JsonObject paymentObject = gson.fromJson(paymentData, JsonObject.class);
                String portoneStatus = paymentObject.get("status").getAsString();

                JsonObject amountObject = paymentObject.getAsJsonObject("amount");
                BigDecimal portoneAmount = amountObject.get("total").getAsBigDecimal();

                PaymentVO payment = paymentService.getPaymentByTransactionId(transactionId);

                if (payment != null) {
                    if (portoneAmount.compareTo(BigDecimal.valueOf(payment.getAmount())) == 0) {
                        if ("PAID".equals(portoneStatus.toUpperCase())) {
                            logger.info("웹훅을 통한 결제 검증 성공! transactionId: {}", transactionId);
                            payment.setStatus("COMPLETED");
                            payment.setPaidAt(LocalDateTime.now());
                            paymentService.updatePaymentStatus(payment);
                            // 결제 성공 시 예약 상태도 'CONFIRMED'로 업데이트
                            reservationService.updateReservationStatus(payment.getReservationId(), "CONFIRMED");
                            logger.info("웹훅: 결제 및 예약 상태 업데이트 성공. reservationId: {}", payment.getReservationId());
                        } else {
                            logger.warn("웹훅 결제 검증 실패: transactionId: {}, PortOne status: {}", transactionId, portoneStatus);
                            return new ResponseEntity<>("PortOne status mismatch", HttpStatus.BAD_REQUEST);
                        }
                    } else {
                        logger.warn("금액 불일치: PortOne 금액({}) vs DB 금액({})", portoneAmount, payment.getAmount());
                        return new ResponseEntity<>("amount mismatch", HttpStatus.BAD_REQUEST);
                    }
                } else {
                    logger.warn("웹훅: transactionId에 해당하는 결제 정보를 찾을 수 없습니다. transactionId: {}", transactionId);
                    return new ResponseEntity<>("payment not found in DB", HttpStatus.NOT_FOUND);
                }
            } catch (Exception e) {
                logger.error("웹훅 결제 처리 중 오류 발생: {}", e.getMessage(), e);
                return new ResponseEntity<>("error during payment processing", HttpStatus.INTERNAL_SERVER_ERROR);
            }
        } else if ("CANCELED".equals(status.toUpperCase()) || "FAILED".equals(status.toUpperCase()) || "REFUNDED".equals(status.toUpperCase())) {
            try {
                PaymentVO payment = paymentService.getPaymentByTransactionId(transactionId);
                if (payment != null) {
                    // 1. PaymentVO 상태 업데이트
                    payment.setStatus(status.toUpperCase());
                    paymentService.updatePaymentStatus(payment);
                    logger.info("웹훅: 결제 상태 업데이트 완료 ({}). transactionId: {}", status, transactionId);

                    // 2. ReservationVO 상태 업데이트
                    // 결제 실패/취소/환불 시 예약 상태를 'FAILED'로 업데이트
                    reservationService.updateReservationStatus(payment.getReservationId(), "FAILED");
                    logger.info("웹훅: 예약 상태 업데이트 완료 ({}). reservationId: {}", "FAILED", payment.getReservationId());
                } else {
                    logger.warn("웹훅: transactionId에 해당하는 결제 정보를 찾을 수 없습니다. transactionId: {}", transactionId);
                    return new ResponseEntity<>("payment not found for status update", HttpStatus.NOT_FOUND);
                }
            } catch (Exception e) {
                logger.error("웹훅 상태 업데이트 중 오류 발생: {}", e.getMessage(), e);
                return new ResponseEntity<>("error during status update", HttpStatus.INTERNAL_SERVER_ERROR);
            }
        }

        return new ResponseEntity<>("success", HttpStatus.OK);
    }


    @GetMapping("/checkStatus")
    @ResponseBody
    public Map<String, Object> checkPaymentStatus(@RequestParam("transactionId") String transactionId) {
        Map<String, Object> result = new HashMap<>();
        try {
            PaymentVO payment = paymentService.getPaymentByTransactionId(transactionId);
            if (payment != null) {
                result.put("status", payment.getStatus());
                result.put("reservationId", payment.getReservationId());
            } else {
                result.put("status", "NOT_FOUND");
            }
        } catch (Exception e) {
            logger.error("결제 상태 확인 중 오류 발생:", e);
            result.put("status", "ERROR");
        }
        return result;
    }

    /**
     * PortOne V2 API의 결제 정보를 조회하는 메서드입니다.
     * payment_id를 사용하여 결제 정보를 조회합니다.
     * @param paymentId 조회할 결제 ID
     * @return 결제 정보 JSON 문자열
     * @throws Exception API 호출 실패 시
     */
    private String getPaymentInfoByPaymentId(String paymentId) throws Exception {
        int maxRetries = 5;
        long retryDelayMillis = 3000;

        for (int retryCount = 0; retryCount < maxRetries; retryCount++) {
            HttpURLConnection con = null;
            try {
                URL url = new URL("https://api.portone.io/payments/" + paymentId);
                con = (HttpURLConnection) url.openConnection();
                con.setRequestMethod("GET");
                con.setRequestProperty("Authorization", "PortOne " + PORTONE_API_SECRET_KEY);
                con.setConnectTimeout(5000);
                con.setReadTimeout(5000);

                int responseCode = con.getResponseCode();

                if (responseCode == HttpURLConnection.HTTP_OK) {
                    return readResponse(con.getInputStream());
                } else if (responseCode == HttpURLConnection.HTTP_NOT_FOUND) {
                    if (retryCount < maxRetries - 1) {
                        logger.warn("PortOne 결제 정보 조회 실패 (응답 코드: 404). {}ms 후 재시도합니다. (시도: {}/{}). paymentId: {}",
                                    retryDelayMillis, retryCount + 1, maxRetries, paymentId);
                        Thread.sleep(retryDelayMillis);
                    } else {
                        logger.warn("PortOne 결제 정보 조회 실패 (응답 코드: 404, 재시도 횟수 초과). paymentId: {}", paymentId);
                        return null;
                    }
                } else {
                    String errorResponse = readResponse(con.getErrorStream());
                    if (errorResponse == null || errorResponse.isEmpty()) {
                        errorResponse = "응답 본문 없음";
                    }

                    if (retryCount < maxRetries - 1) {
                        logger.warn("PortOne 결제 정보 조회 실패 (응답 코드: {}). {}ms 후 재시도합니다. (시도: {}/{}). paymentId: {}",
                                    responseCode, retryDelayMillis, retryCount + 1, maxRetries, paymentId);
                        Thread.sleep(retryDelayMillis);
                    } else {
                        logger.error("PortOne 결제 정보 조회 실패 (응답 코드: {}): {}", responseCode, errorResponse);
                        throw new Exception("PortOne 결제 정보 조회 실패 (응답 코드: " + responseCode + "): " + errorResponse);
                    }
                }
            } catch (IOException e) {
                if (retryCount < maxRetries - 1) {
                    logger.warn("PortOne API 호출 중 I/O 오류 발생. {}ms 후 재시도합니다. (시도: {}/{}). paymentId: {}",
                                retryDelayMillis, retryCount + 1, maxRetries, paymentId);
                    Thread.sleep(retryDelayMillis);
                } else {
                    logger.error("PortOne API 호출 중 I/O 오류 발생 (재시도 횟수 초과): {}", e.getMessage());
                    throw e;
                }
            } finally {
                if (con != null) {
                    con.disconnect();
                }
            }
        }
        return null;
    }

    private String readResponse(java.io.InputStream is) throws Exception {
        if (is == null) return null;
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
            return response.toString();
        }
    }

    /**
     * 예약 취소 및 환불을 처리하는 API 엔드포인트입니다.
     * @param reservationId 취소할 예약 ID
     * @return 처리 결과
     */
    @PostMapping("/cancel")
    @ResponseBody
    public ResponseEntity<Map<String, String>> cancelPayment(@RequestParam("reservationId") Long reservationId) {
        Map<String, String> response = new HashMap<>();
        try {
            logger.info("예약 취소 요청 수신: reservationId = {}", reservationId);

            // 1. DB에서 예약 정보와 결제 정보 조회
            PaymentVO payment = paymentService.getPaymentByReservationId(reservationId);
            if (payment == null) {
                response.put("status", "error");
                response.put("message", "해당 예약에 대한 결제 정보를 찾을 수 없습니다.");
                logger.warn("결제 정보를 찾을 수 없음: reservationId = {}", reservationId);
                return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
            }

            // 2. 이미 취소된 건인지 확인
            if ("CANCELED".equalsIgnoreCase(payment.getStatus()) || "REFUNDED".equalsIgnoreCase(payment.getStatus())) {
                response.put("status", "success");
                response.put("message", "이미 취소 처리된 예약입니다.");
                logger.info("이미 취소된 예약: reservationId = {}", reservationId);
                return new ResponseEntity<>(response, HttpStatus.OK);
            }

            // 3. PortOne API에 환불 요청
            String refundResponse = requestRefund(payment.getTransactionId(), payment.getAmount());
            JsonObject refundResult = new Gson().fromJson(refundResponse, JsonObject.class);

            String refundStatus = refundResult.get("status").getAsString();

            if ("REFUNDED".equalsIgnoreCase(refundStatus) || "PAID".equalsIgnoreCase(refundStatus)) {
                // 환불 요청이 성공하면 DB 상태 업데이트
                paymentService.updatePaymentStatus(payment.getPaymentId(), "REFUNDED");
                reservationService.updateReservationStatus(reservationId, "CANCELED");

                response.put("status", "success");
                response.put("message", "예약이 성공적으로 취소되고 환불되었습니다.");
                logger.info("예약 취소 및 환불 성공: reservationId = {}", reservationId);
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                response.put("status", "error");
                response.put("message", "환불 처리 중 오류가 발생했습니다. 고객센터에 문의해주세요.");
                logger.error("PortOne 환불 요청 실패: {}", refundResponse);
                return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
            }

        } catch (Exception e) {
            logger.error("예약 취소 및 환불 처리 중 오류 발생: {}", e.getMessage(), e);
            response.put("status", "error");
            response.put("message", "예약 취소 처리 중 오류가 발생했습니다.");
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * PortOne에 환불을 요청하는 메서드입니다.
     * @param transactionId 환불할 결제 ID
     * @param amount 환불 금액
     * @return 환불 요청 응답 JSON 문자열
     */
    private String requestRefund(String transactionId, Long amount) throws Exception {
        URL url = new URL("https://api.portone.io/payments/merchant_uid/" + transactionId + "/refunds");
        HttpURLConnection con = null;
        try {
            con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("POST");
            con.setRequestProperty("Authorization", "PortOne " + PORTONE_API_SECRET_KEY);
            con.setRequestProperty("Content-Type", "application/json; utf-8");
            con.setDoOutput(true);

            // 환불 요청 본문 생성
            String jsonInputString = "{\"amount\": " + amount + "}";

            try(OutputStream os = con.getOutputStream()) {
                byte[] input = jsonInputString.getBytes("utf-8");
                os.write(input, 0, input.length);
            }

            int responseCode = con.getResponseCode();
            if (responseCode != HttpURLConnection.HTTP_OK && responseCode != HttpURLConnection.HTTP_CREATED) {
                String errorResponse = readResponse(con.getErrorStream());
                logger.error("PortOne 환불 요청 실패 (응답 코드: {}): {}", responseCode, errorResponse);
                throw new Exception("PortOne 환불 요청 실패: " + errorResponse);
            }

            return readResponse(con.getInputStream());

        } finally {
            if (con != null) {
                con.disconnect();
            }
        }
    }
}
