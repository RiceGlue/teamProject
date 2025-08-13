package com.spring.teamProject.service;

import java.time.LocalDateTime;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import com.spring.teamProject.dao.PaymentDAO;
import com.spring.teamProject.dao.ReservationDAO;
import com.spring.teamProject.vo.PaymentVO;

import reactor.core.publisher.Mono;

@Service
public class PaymentServiceImpl implements PaymentService {

    private static final Logger log = LoggerFactory.getLogger(PaymentServiceImpl.class);

    private final PaymentDAO paymentDAO;
    private final ReservationDAO reservationDAO;
    private final WebClient webClient;

    @Value("${portone.apiSecret}")
    private String apiSecret;

    @Autowired
    public PaymentServiceImpl(PaymentDAO paymentDAO, ReservationDAO reservationDAO, WebClient.Builder webClientBuilder) {
        this.paymentDAO = paymentDAO;
        this.reservationDAO = reservationDAO;
        this.webClient = webClientBuilder.baseUrl("https://api.portone.io").build();
    }

    private Mono<String> getAccessToken() {
        return webClient.post()
                .uri("/login/api-secret")
                .contentType(MediaType.APPLICATION_JSON)
                .body(BodyInserters.fromValue(Map.of("apiSecret", apiSecret)))
                .retrieve()
                .onStatus(HttpStatusCode::is4xxClientError, clientResponse ->
                    clientResponse.bodyToMono(String.class)
                            .flatMap(errorBody -> {
                                log.error("PortOne V2 인증 실패: {} - {}", clientResponse.statusCode(), errorBody);
                                return Mono.error(new RuntimeException("PortOne V2 인증에 실패했습니다."));
                            })
                )
                .bodyToMono(Map.class)
                .map(response -> (String) response.get("accessToken"))
                .doOnError(e -> log.error("액세스 토큰 발급 중 오류 발생: {}", e.getMessage()));
    }

    @Override
    public void addPayment(PaymentVO payment) throws Exception {
        paymentDAO.insertPayment(payment);
    }

    @Override
    public PaymentVO getPaymentByTransactionId(String transactionId) throws Exception {
        return paymentDAO.selectByTransactionId(transactionId);
    }

    @Override
    public void updatePaymentStatus(PaymentVO payment) throws Exception {
        // 결제 상태 업데이트 로직 구현
    	paymentDAO.updatePaymentStatus(payment.getPaymentId(), payment.getStatus());
    }

    @Override
    @Transactional
    public boolean completePayment(String paymentId) throws Exception {
        try {
            // 여기서는 paymentId 대신 transactionId를 사용
            PaymentVO paymentVO = paymentDAO.selectByTransactionId(paymentId);
            if (paymentVO == null) {
                log.error("DB에 존재하지 않는 결제 정보입니다: transactionId={}", paymentId);
                return false;
            }
            String accessToken = getAccessToken().block();
            Map portonePayment = webClient.get()
                    .uri("/v2/payment/{transactionId}", paymentId)
                    .header("Authorization", "Bearer " + accessToken)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();
            Integer portoneAmount = (Integer) ((Map) portonePayment.get("payment")).get("amount");
            if (portoneAmount.longValue() != paymentVO.getAmount()) {
                log.error("결제 금액 불일치: DB 금액={}, 포트원 금액={}", paymentVO.getAmount(), portoneAmount);
                paymentDAO.updatePaymentStatus(paymentVO.getPaymentId(), "FAILED");
                return false;
            }
            paymentVO.setStatus("COMPLETED");
            paymentVO.setPaidAt(LocalDateTime.now());
            updatePaymentStatus(paymentVO.getPaymentId(), paymentVO.getStatus());
            reservationDAO.updateReservationStatus(paymentVO.getReservationId(), "CONFIRMED");
            log.info("결제 및 예약 확정 성공: reservationId={}", paymentVO.getReservationId());
            return true;
        } catch (Exception e) {
            log.error("결제 완료 처리 중 오류 발생: {}", e.getMessage());
            return false;
        }
    }

    public void updatePaymentStatus(Long paymentId, String status) throws Exception {
        paymentDAO.updatePaymentStatus(paymentId, status);
    }

    @Override
    public PaymentVO getPaymentByReservationId(Long reservationId) throws Exception {
        try {
            return paymentDAO.selectByReservationId(reservationId);
        } catch (Exception e) {
            log.error("예약 ID로 결제 정보를 조회하는 중 오류가 발생했습니다: {}", e.getMessage());
            return null;
        }
    }
}