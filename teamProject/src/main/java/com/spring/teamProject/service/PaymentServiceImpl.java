package com.spring.teamProject.service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;

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

    /**
     * 포트원 API에서 사용할 액세스 토큰을 발급받습니다.
     * @return Mono<String> 액세스 토큰
     */
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

    /**
     * PaymentVO 객체로 결제 정보를 추가합니다.
     * @param payment 추가할 결제 정보
     */
    @Override
    public void addPayment(PaymentVO payment) throws Exception {
        paymentDAO.insertPayment(payment);
    }

    /**
     * PaymentVO 객체로 결제 상태를 업데이트합니다.
     * @param payment 업데이트할 결제 정보
     */
    @Override
    public void updatePaymentStatus(PaymentVO payment) throws Exception {
        paymentDAO.updatePaymentStatus(payment.getPaymentId(), payment.getStatus());
    }

    /**
     * 거래 ID(transactionId)로 결제 정보를 조회합니다.
     * @param transactionId 거래 ID
     * @return PaymentVO 결제 정보
     */
    @Override
    public PaymentVO getPaymentByTransactionId(String transactionId) throws Exception {
        return paymentDAO.selectByTransactionId(transactionId);
    }

    /**
     * 예약 ID(reservationId)로 결제 정보를 조회합니다.
     * @param reservationId 예약 ID
     * @return PaymentVO 결제 정보
     */
    @Override
    public PaymentVO getPaymentByReservationId(Long reservationId) {
        try {
            return paymentDAO.selectByReservationId(reservationId);
        } catch (Exception e) {
            log.error("예약 ID로 결제 정보를 조회하는 중 오류가 발생했습니다: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 결제 ID(paymentId)와 상태(status)로 결제 상태를 업데이트합니다.
     * @param paymentId 결제 ID
     * @param status 새로운 상태
     * @return boolean 업데이트 성공 여부
     */
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
     * 결제 완료 후 최종 처리를 수행합니다.
     * @param transactionId 거래 ID
     * @return boolean 결제 완료 처리 성공 여부
     */
    @Override
    @Transactional
    public boolean completePayment(String transactionId) throws Exception {
        try {
            // transactionId로 결제 정보 조회
            PaymentVO paymentVO = paymentDAO.selectByTransactionId(transactionId);
            if (paymentVO == null) {
                log.error("DB에 존재하지 않는 결제 정보입니다: transactionId={}", transactionId);
                return false;
            }
            String accessToken = getAccessToken().block();
            Map portonePayment = webClient.get()
                    .uri("/v2/payment/{transactionId}", transactionId)
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
            // 여기서 updatePaymentStatus() 대신 DAO에 새로운 메서드를 호출하여 한 번에 업데이트
            paymentDAO.updatePayment(paymentVO);

            reservationDAO.updateReservationStatus(paymentVO.getReservationId(), "CONFIRMED");
            log.info("결제 및 예약 확정 성공: reservationId={}", paymentVO.getReservationId());
            return true;
        } catch (Exception e) {
            log.error("결제 완료 처리 중 오류 발생: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 예약 번호를 통해 결제를 취소(환불)합니다.
     * @param reservationId 취소할 예약의 ID
     * @throws Exception
     */
    /**
     * 예약 번호를 통해 결제를 취소(환불)합니다.
     */
    @Transactional
    @Override
    public void refundPayment(Long reservationId) throws Exception {
        log.info(">>> 디버그: refundPayment() 메서드 시작. reservationId={}", reservationId);

        // 1. reservationId로 DB에서 결제 정보(paymentVO)를 조회합니다.
        // 비관적 락을 걸어 동시성 문제 해결을 시도합니다.
        PaymentVO paymentVO = paymentDAO.selectByReservationIdWithLock(reservationId);

        if (paymentVO == null) {
            log.error("예약 ID {}에 대한 결제 정보를 찾을 수 없습니다.", reservationId);
            throw new IllegalArgumentException("결제 정보를 찾을 수 없습니다.");
        }

        log.info(">>> 디버그: DB에서 조회된 paymentVO.getPaymentId(): {}", paymentVO.getPaymentId());
        log.info(">>> 디버그: DB에서 조회된 paymentVO.getStatus(): {}", paymentVO.getStatus());

        // 2. 이미 환불되었거나 결제 실패 상태인지 확인합니다.
        if ("REFUNDED".equals(paymentVO.getStatus()) || "FAILED".equals(paymentVO.getStatus())) {
            log.warn("이미 환불되었거나 실패한 결제입니다. (현재 상태: {})", paymentVO.getStatus());
            throw new IllegalStateException("이미 처리된 결제입니다. 환불을 진행할 수 없습니다.");
        }

        // 3. 'COMPLETED' 상태의 결제만 환불 가능하도록 로직을 추가합니다.
        if (!"COMPLETED".equals(paymentVO.getStatus())) {
            log.warn("환불 가능한 상태가 아닙니다. (현재 상태: {})", paymentVO.getStatus());
            throw new IllegalStateException("환불 가능한 상태의 결제가 아닙니다.");
        }

        log.info("예약 ID {}에 대한 환불을 시작합니다...", reservationId);

        // 4. 외부 결제 시스템(포트원)에 환불 요청을 보냅니다.
        try {
            // PortOne V2 API는 transactionId로 환불 요청을 보냅니다.
            String transactionId = paymentVO.getTransactionId();
            String reason = "사용자 요청에 의한 취소";

            // WebClient를 사용하여 Access Token을 얻고, 이어서 환불 API를 호출합니다.
            String accessToken = getAccessToken().block();

            // PortOne 환불 API 호출
            Map<String, Object> requestBody = Map.of(
                "reason", reason
            );

            Map<String, Object> response = webClient.post()
                    .uri("/payments/" + transactionId + "/cancel")
                    .header("Authorization", "PortOne " + apiSecret)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(BodyInserters.fromValue(requestBody))
                    .retrieve()
                    .onStatus(HttpStatusCode::isError, clientResponse ->
                        clientResponse.bodyToMono(String.class)
                                .flatMap(errorBody -> {
                                    log.error("PortOne 환불 API 오류: {} - {}", clientResponse.statusCode(), errorBody);
                                    return Mono.error(new RuntimeException("환불 API 호출에 실패했습니다."));
                                })
                    )
                    .bodyToMono(Map.class)
                    .block(); // 블로킹하여 Mono의 결과를 동기적으로 얻습니다.

            // 5. API 호출이 성공하면, 데이터베이스의 결제 상태를 'REFUNDED'로 업데이트합니다.
            String status = Optional.ofNullable(response)
                .map(res -> (Map<String, Object>) res.get("cancellation"))
                .map(c -> (String) c.get("status"))
                .orElse("UNKNOWN");

            // 'SUCCEEDED' 또는 'REQUESTED' 상태일 때만 DB 업데이트
            if ("SUCCEEDED".equals(status)) {
                paymentDAO.updatePaymentStatus(paymentVO.getPaymentId(), "REFUNDED");
                log.info("예약 ID {}에 대한 결제 환불 처리가 완료되었습니다. DB 상태: 'REFUNDED'", reservationId);
            } else if ("REQUESTED".equals(status)) {
                 paymentDAO.updatePaymentStatus(paymentVO.getPaymentId(), "REFUND_REQUESTED");
                 log.info("예약 ID {}에 대한 결제 환불 요청이 완료되었습니다. DB 상태: 'REFUND_REQUESTED'", reservationId);
            } else {
                log.error("PortOne 환불 처리가 성공적으로 완료되지 않았습니다. API 응답 상태: {}", status);
                throw new RuntimeException("환불 처리가 성공적으로 완료되지 않았습니다.");
            }
        } catch (Exception e) {
            log.error("예약 ID {} 환불 처리 중 오류 발생: {}", reservationId, e.getMessage(), e);
            throw new RuntimeException("환불 처리에 실패했습니다.", e);
        }
    }


    /**
     * paymentId로 결제 정보를 삭제합니다.
     * ReservationService에서 임시 예약 삭제 시 호출됩니다.
     * @param paymentId 삭제할 결제 ID
     */
    @Override
    public void deletePayment(Long paymentId) {
        try {
            paymentDAO.deletePayment(paymentId);
            log.info("Successfully deleted payment with ID: {}", paymentId);
        } catch (Exception e) {
            // 결제 정보가 이미 삭제되었을 경우를 고려하여 예외를 로깅만 하고 던지지 않습니다.
            // ReservationServiceImpl에서 이 메서드를 호출할 때 예외 처리를 하지 않아도 되도록 합니다.
            log.warn("Failed to delete payment with ID: {}. It might have been deleted already. Error: {}", paymentId, e.getMessage());
        }
    }

    /**
     * paymentId로 결제 정보를 조회합니다.
     * @param paymentId 결제 ID (문자열)
     */
    @Override
    public PaymentVO getPaymentById(String paymentId) {
        try {
            // String을 Long으로 변환하여 DAO를 호출
            Long id = Long.parseLong(paymentId);
            return paymentDAO.selectById(id);
        } catch (NumberFormatException e) {
            log.error("유효하지 않은 결제 ID 형식입니다: {}", paymentId);
            return null;
        } catch (Exception e) {
            log.error("결제 ID로 결제 정보를 조회하는 중 오류가 발생했습니다: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 결제 ID(문자열)와 상태(문자열)로 결제 상태를 업데이트합니다.
     * @param paymentId 결제 ID
     * @param status 새로운 상태 ("REFUNDED" 등)
     */
    @Override
    public void updatePaymentStatus(String paymentId, String status) {
        try {
            // String을 Long으로 변환하여 DAO를 호출
            Long id = Long.parseLong(paymentId);
            paymentDAO.updatePaymentStatus(id, status);
            log.info("결제 상태 업데이트 완료. paymentId: {}, status: {}", id, status);
        } catch (NumberFormatException e) {
            log.error("유효하지 않은 결제 ID 형식입니다: {}", paymentId);
            throw new RuntimeException("결제 상태 업데이트 실패: 유효하지 않은 ID 형식", e);
        } catch (Exception e) {
            log.error("결제 상태를 업데이트하는 중 오류가 발생했습니다. paymentId={}, status={}", paymentId, status, e);
            // 예외가 발생하면 호출한 쪽에서 처리할 수 있도록 RuntimeException을 던집니다.
            throw new RuntimeException("결제 상태 업데이트 실패", e);
        }
    }
}
