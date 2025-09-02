package com.spring.teamProject.controller;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.util.UriComponentsBuilder;

import com.spring.teamProject.service.PaymentService;
import com.spring.teamProject.service.ReservationService;
import com.spring.teamProject.service.StoreService;
import com.spring.teamProject.vo.PaymentVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.UserDetailsVO;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/reservation/customer")
public class ReservationCustomerController {

    private static final Logger logger = LoggerFactory.getLogger(ReservationCustomerController.class);

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private StoreService storeService;

    @GetMapping("/bookForm")
    public String showBookingForm(@RequestParam("storeId") Long storeId,
                                  @RequestParam(value = "reservationTime", required = false) String reservationTime,
                                  @RequestParam(value = "tableIds", required = false) List<Long> tableIds,
                                  @RequestParam(value = "guestCount", required = false, defaultValue = "1") Integer guestCount,
                                  Model model,
                                  HttpSession session) throws Exception {
        logger.info("고객 예약 폼 요청 - storeId: {}, reservationTime: {}, tableIds: {}, guestCount: {}",
                storeId, reservationTime, tableIds, guestCount);

        model.addAttribute("storeId", storeId);
        model.addAttribute("selectedReservationTime", reservationTime);
        model.addAttribute("selectedTableIds", tableIds);
        model.addAttribute("guestCount", guestCount);

        String currentDate = (reservationTime != null && reservationTime.length() >= 10)
                ? reservationTime.substring(0, 10)
                : LocalDate.now().toString();
        model.addAttribute("currentDate", currentDate);

        StoreVO store = storeService.getStoreById(storeId);
        model.addAttribute("store", store);

        session.removeAttribute("pendingReservation");
        session.removeAttribute("pendingPayment");

        //return "layout/layout";
        model.addAttribute("body", "reservation/customer/bookingForm.jsp");
        return "layout/layout";
    }

    @GetMapping("/available-slots")
    @ResponseBody
    public Map<String, List<StoreTableVO>> getAvailableSlots(@RequestParam("storeId") Long storeId,
                                                             @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        logger.info("예약 가능한 시간대 요청 - storeId: {}, date: {}", storeId, date);
        try {
            return reservationService.getAvailableTimeSlots(storeId, date.toString());
        } catch (Exception e) {
            logger.error("예약 가능 시간대 조회 중 오류 발생: {}", e.getMessage(), e);
            return Map.of();
        }
    }


    // 결제 성공 후 최종 예약을 처리하는 새로운 엔드포인트
    @PostMapping("/book-final")
    @ResponseBody
    public String saveFinalReservation(@RequestParam("paymentId") String paymentId) {
        logger.info("최종 예약 정보 저장 요청 (결제 ID): {}", paymentId);

        try {
            // 1. 임시 예약 상태를 '확정'으로 업데이트합니다.
            boolean success = reservationService.updateReservationToConfirmed(paymentId);

            if (success) {
                // 2. 예약 확정 성공 시 'success' 반환
                return "success";
            } else {
                // 3. 예약 확정 실패 시 (e.g., 이미 예약되었거나 존재하지 않는 경우) 'failure' 반환
                return "failure";
            }
        } catch (Exception e) {
            logger.error("최종 예약 정보 저장 중 오류 발생", e);
            return "error";
        }
    }

    // 복구된 임시 예약 생성 엔드포인트
    @PostMapping("/book-temp")
    @ResponseBody
    public String processBookingFormTemp(@ModelAttribute ReservationVO reservation,
    									 @AuthenticationPrincipal UserDetailsVO userDetailsVO,
                                         @RequestParam("reservationTimeStr") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime reservationTime,
                                         @RequestParam("amount") BigDecimal amount,
                                         @RequestParam("paymentMethod") String paymentMethod,
                                         @RequestParam("transactionId") String transactionId,
                                         @RequestParam("tableIds") List<Long> tableIds,
                                         HttpSession session) {

    	Long memberId = (long) userDetailsVO.getMemberVO().getMemberId();
        logger.info("로그인된 사용자 ID: {}", memberId);

        try {
            reservation.setReservationTime(reservationTime);
            reservation.setMemberId(memberId);
            reservation.setStatus("PENDING");

            List<StoreTableVO> tables = tableIds.stream()
                .map(id -> {
                    StoreTableVO table = new StoreTableVO();
                    table.setTableId(id);
                    return table;
                })
                .collect(Collectors.toList());
            reservation.setTables(tables);

            reservationService.addReservation(reservation);
            logger.info("임시 예약 정보 DB 저장 완료. reservationId: {}", reservation.getReservationId());

            PaymentVO payment = new PaymentVO();
            payment.setReservationId(reservation.getReservationId());
            payment.setAmount(amount.longValue());
            payment.setPaymentMethod(paymentMethod);
            payment.setTransactionId(transactionId);
            payment.setStatus("PENDING");

            logger.info("임시 결제 정보 DB 저장 시작. transactionId: {}, amount: {}", payment.getTransactionId(), payment.getAmount());
            paymentService.addPayment(payment);
            logger.info("임시 결제 정보 DB 저장 완료. transactionId: {}", payment.getTransactionId());

            session.setAttribute("currentReservationId", reservation.getReservationId());
            session.setAttribute("currentTransactionId", payment.getTransactionId());

            return "success";
        } catch (Exception e) {
            logger.error("임시 예약 및 결제 정보 저장 중 오류 발생: {}", e.getMessage(), e);
            return "error";
        }
    }

    // 새로 추가된 임시 예약 취소 엔드포인트
    /**
     * 결제창 취소/실패 시 임시 예약 정보를 삭제하는 엔드포인트
     * @param transactionId 결제 요청 시 생성된 고유 ID
     * @return 성공 여부 문자열
     */
    @PostMapping("/cancel-temp")
    @ResponseBody
    public String cancelTempReservation(@RequestParam("transactionId") String transactionId) {
        logger.info("결제 취소로 인한 임시 예약 삭제 요청 - transactionId: {}", transactionId);
        try {
            boolean success = reservationService.deleteTempReservationByTransactionId(transactionId);
            if (success) {
                logger.info("임시 예약 및 결제 정보 삭제 성공. transactionId: {}", transactionId);
                return "success";
            } else {
                logger.warn("해당 transactionId로 임시 예약 정보를 찾을 수 없거나 삭제 실패. transactionId: {}", transactionId);
                return "failure";
            }
        } catch (Exception e) {
            logger.error("임시 예약 삭제 중 오류 발생: {}", e.getMessage(), e);
            return "error";
        }
    }

    @GetMapping("/complete-payment")
    @ResponseBody
    public Map<String, Object> completePayment(@RequestParam String paymentId) throws Exception {
        Map<String, Object> response = new HashMap<>();
        PaymentVO payment = paymentService.getPaymentByTransactionId(paymentId);
        if (payment != null) {
            response.put("status", payment.getStatus());
            if ("COMPLETED".equals(payment.getStatus())) {
                response.put("result", "success");
            } else {
                response.put("result", "pending");
            }
        } else {
            response.put("result", "not_found");
        }
        return response;
    }

    @GetMapping("/bookingConfirm")
    public String bookingConfirm(@RequestParam(value = "storeId", required = false) Long storeId,
                                 @RequestParam(value = "reservationId", required = false) Long reservationId,
                                 Model model,
                                 HttpSession session) {

        if (reservationId == null) {
            reservationId = (Long) session.getAttribute("currentReservationId");
            logger.info("세션에서 reservationId를 가져옴: {}", reservationId);
        }

        logger.info("예약 완료 페이지 요청 - storeId: {}, reservationId: {}", storeId, reservationId);

        if (storeId == null && reservationId != null) {
             try {
                 ReservationVO reservation = reservationService.getReservationById(reservationId);
                 if (reservation != null) {
                    storeId = reservation.getStoreId();
                    logger.info("reservationId를 통해 storeId를 찾음: {}", storeId);
                 }
             } catch (Exception e) {
                 logger.error("storeId 조회 오류: {}", e.getMessage(), e);
             }
        }

        if (storeId != null) {
            try {
                StoreVO store = storeService.getStoreById(storeId);
                model.addAttribute("store", store);
                logger.info("DB에서 가게 정보 조회 완료: {}", store);
            } catch (Exception e) {
                logger.error("가게 정보 조회 오류: {}", e.getMessage(), e);
                model.addAttribute("errorMessage", "가게 정보를 불러오는 데 실패했습니다.");
            }
        }

        if (reservationId != null) {
            try {
                ReservationVO reservationFromDb = reservationService.getReservationById(reservationId);
                if (reservationFromDb != null) {
                    model.addAttribute("confirmedReservation", reservationFromDb);

                    if (reservationFromDb.getTables() != null && !reservationFromDb.getTables().isEmpty()) {
                        String tableNames = reservationFromDb.getTables().stream()
                            .map(StoreTableVO::getTableName)
                            .collect(Collectors.joining(", "));
                        model.addAttribute("tableNames", tableNames);
                    } else {
                        model.addAttribute("tableNames", "지정되지 않음");
                    }

                    Date reservationDate = Date.from(reservationFromDb.getReservationTime().atZone(ZoneId.systemDefault()).toInstant());
                    model.addAttribute("reservationDate", reservationDate);

                    PaymentVO payment = paymentService.getPaymentByReservationId(reservationId);
                    if (payment != null) {
                        model.addAttribute("payment", payment);
                        model.addAttribute("paymentId", payment.getPaymentId());
                        model.addAttribute("transactionId", payment.getTransactionId());
                    }
                    model.addAttribute("message", "예약이 성공적으로 접수되었습니다!");
                } else {
                    model.addAttribute("errorMessage", "예약 정보를 불러오는 데 실패했습니다.");
                }
            } catch (Exception e) {
                logger.error("예약 상세 조회 오류: {}", e.getMessage(), e);
                model.addAttribute("errorMessage", "예약 정보를 불러오는데 오류가 발생했습니다.");
            }
        } else {
            model.addAttribute("errorMessage", "예약 정보를 불러오는 데 실패했습니다.");
        }

        //return "reservation/customer/bookingConfirm";
        model.addAttribute("body", "reservation/customer/bookingConfirm.jsp");
        return "layout/layout";

    }

    @GetMapping("/api/payment-status")
    @ResponseBody
    public String getPaymentStatus(@RequestParam("transactionId") String transactionId) {
        try {
            PaymentVO payment = paymentService.getPaymentByTransactionId(transactionId);
            if (payment != null && "COMPLETED".equals(payment.getStatus())) {
            	logger.info("결제 상태 완료 확인. transactionId: {}", transactionId);
                return "success";
            }
        } catch (Exception e) {
        	logger.error("결제 상태 조회 중 오류 발생: {}", e.getMessage());
            return "error";
        }
        logger.info("결제 상태 대기 중. transactionId: {}", transactionId);
        return "pending";
    }

    @GetMapping("/payment-result")
    public String handlePaymentResult(@RequestParam("transactionId") String transactionId,
                                      @RequestParam(value = "code", required = false) String resultCode,
                                      RedirectAttributes redirectAttributes,
                                      HttpSession session) throws Exception {
        logger.info("PortOne 결제 결과 리다이렉트 수신 - transactionId: {}, resultCode: {}", transactionId, resultCode);

        if (resultCode != null && !"0000".equals(resultCode)) {
            // 결제 실패 또는 취소 시 임시 예약 삭제
            reservationService.deleteTempReservationByTransactionId(transactionId);
            redirectAttributes.addFlashAttribute("errorMessage", "결제가 취소되었거나 실패했습니다. 다시 시도해주세요.");
            PaymentVO payment = paymentService.getPaymentByTransactionId(transactionId);
            if (payment != null && payment.getReservationId() != null) {
                redirectAttributes.addAttribute("storeId", reservationService.getReservationById(payment.getReservationId()).getStoreId());
            }
            return "redirect:/reservation/customer/bookForm";
        }

        try {
            PaymentVO payment = null;
            // 결제 상태를 확인하는 로직에 트랜잭션 ID로 결제 완료 처리를 추가
            boolean success = paymentService.completePayment(transactionId);

            if (success) {
                payment = paymentService.getPaymentByTransactionId(transactionId);
                if (payment != null && payment.getReservationId() != null) {
                    Long reservationId = payment.getReservationId();
                    ReservationVO reservation = reservationService.getReservationById(reservationId);
                    if (reservation != null) {
                        logger.info("결제 완료 후 URL 파라미터로 예약 ID 전달: {}", reservationId);
                        redirectAttributes.addAttribute("storeId", reservation.getStoreId());
                        redirectAttributes.addAttribute("reservationId", reservationId);
                        session.removeAttribute("currentReservationId");
                        session.removeAttribute("currentTransactionId");
                        return "redirect:/reservation/customer/bookingConfirm";
                    }
                }
            }

            logger.error("결제 ID({})에 해당하는 확정된 예약 정보를 찾을 수 없거나 예약 정보 조회 실패.", transactionId);
            redirectAttributes.addFlashAttribute("errorMessage", "예약 정보를 찾을 수 없습니다. 고객센터에 문의해주세요.");
            return "redirect:/reservation/customer/bookForm";

        } catch (Exception e) {
            logger.error("결제 처리 후 리다이렉션 중 오류 발생: {}", e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "결제 처리 중 오류가 발생했습니다. 고객센터에 문의해주세요.");
            return "redirect:/reservation/customer/bookForm";
        }
    }

    /**
     * 고객이 예약 취소 요청을 처리하는 엔드포인트
     * @param reservationId 취소할 예약의 ID
     * @return 취소 성공 여부를 담은 JSON 응답
     */
    @PostMapping("/cancel-reservation")
    @ResponseBody
    public Map<String, Object> cancelReservation(@RequestParam("reservationId") Long reservationId) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 전달받은 ID가 예약 ID인지 확인하거나,
            // ReservationService에서 이 ID를 통해 예약 정보를 찾고 결제 정보를 확인하는 로직을 수행

            ReservationVO reservation = reservationService.getReservationById(reservationId);
            if (reservation == null) {
                response.put("success", false);
                response.put("message", "유효한 예약 정보를 찾을 수 없습니다.");
                return response;
            }

            // 올바른 예약 ID를 사용해 서비스 계층 호출
            reservationService.cancelReservationByUser(reservationId);

            response.put("success", true);
            response.put("message", "예약이 성공적으로 취소되었습니다.");
        } catch (Exception e) {
            logger.error("예약 취소 중 오류 발생: {}", e.getMessage(), e);
            response.put("success", false);
            // 서비스 계층에서 발생한 특정 예외 메시지를 그대로 반환
            response.put("message", e.getMessage());
        }
        return response;
    }

    /**
     * PortOne 결제 웹훅을 처리하는 새로운 엔드포인트
     * 이 엔드포인트는 결제 성공/실패와 관계없이 PortOne이 결제 결과를 보낼 때마다 호출됩니다.
     * @param body PortOne이 보낸 결제 정보(JSON)
     * @return 200 OK 응답
     */
    @PostMapping("/payment-webhook")
    @ResponseBody
    public ResponseEntity<Void> handlePaymentWebhook(@RequestBody Map<String, Object> body) {
        logger.info("PortOne 웹훅 수신: {}", body);

        try {
            String transactionId = (String) body.get("transaction_id");
            String status = (String) body.get("status");

            if ("success".equals(status)) {
                // 결제 성공 웹훅인 경우, 결제 완료 처리를 진행합니다.
                // 이미 payment-result에서 처리했더라도, 안전을 위해 중복 처리를 고려해야 합니다.
                paymentService.completePayment(transactionId);
                logger.info("웹훅을 통해 결제 성공 처리 완료. transactionId: {}", transactionId);
            } else if ("failed".equals(status) || "cancelled".equals(status)) {
                // 결제 실패 또는 취소 웹훅인 경우, 임시 예약을 삭제합니다.
                // 이렇게 하면 사용자가 창을 닫아버려도 서버에서 안전하게 실패 처리가 가능합니다.
                reservationService.deleteTempReservationByTransactionId(transactionId);
                logger.info("웹훅을 통해 결제 실패/취소 처리 완료. transactionId: {}", transactionId);
            }
        } catch (Exception e) {
            logger.error("웹훅 처리 중 오류 발생: {}", e.getMessage(), e);
            // 오류가 발생하더라도 PortOne에 200 OK 응답을 보내야 재시도를 막을 수 있습니다.
        }

        // PortOne에 성공적으로 받았음을 알리기 위해 200 OK를 반환합니다.
        return new ResponseEntity<>(HttpStatus.OK);
    }
}
