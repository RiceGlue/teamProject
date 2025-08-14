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

    @Override
    public PaymentVO getPaymentByReservationId(Long reservationId) {
        try {
            return paymentDAO.selectByReservationId(reservationId);
        } catch (Exception e) {
            log.error("예약 ID로 결제 정보를 조회하는 중 오류가 발생했습니다: {}", e.getMessage());
            return null;
        }
    }

    @Override
    public boolean updatePaymentStatus(Long paymentId, String status) {
        try {
            paymentDAO.updatePaymentStatus(paymentId, status);
            return true;
        } catch (Exception e) {
            log.error("결제 상태를 업데이트하는 중 오류가 발생했습니다. paymentId={}, status={}", paymentId, status, e);
            return false;
        }
    }

    /**
     * 결제를 환불 처리하고, 데이터베이스 상태를 'refunded'로 업데이트합니다.
     * @param paymentId 환불할 결제 건의 ID
     */
    @Transactional
    @Override
    public void refundPayment(Long paymentId) throws Exception {
        // 1. paymentId로 결제 정보를 조회합니다.
        PaymentVO payment = paymentDAO.selectById(paymentId);

        if (payment == null) {
            throw new Exception("결제 정보를 찾을 수 없습니다.");
        }
        if (!"paid".equals(payment.getStatus())) {
            throw new Exception("이미 취소되었거나 환불 불가능한 결제입니다. (현재 상태: " + payment.getStatus() + ")");
        }

        System.out.println("결제 ID " + paymentId + " 환불을 시작합니다...");

        // 2. 외부 결제 시스템(포트원 등)에 환불 요청을 보냅니다.
        // 이 부분은 실제 결제 API를 연동하는 로직으로 대체해야 합니다.
        // 현재는 성공했다고 가정합니다.
        boolean refundSuccess = true;

        if (refundSuccess) {
            // 3. 환불 요청이 성공하면, 데이터베이스의 결제 상태를 'refunded'로 업데이트합니다.
            paymentDAO.updatePaymentStatus(paymentId, "refunded");
            System.out.println("결제 ID " + paymentId + "에 대한 환불 처리가 완료되었습니다. DB 상태: 'refunded'");
        } else {
            // API 호출이 실패한 경우
            System.err.println("결제 ID " + paymentId + " 환불 처리에 실패했습니다. 결제 시스템 API를 확인해주세요.");
            throw new Exception("환불 처리에 실패했습니다.");
        }
    }
}
