package com.spring.teamProject.controller;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
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
import com.spring.teamProject.vo.PaymentVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;
import com.spring.teamProject.vo.StoreVO;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/reservation/customer")
public class ReservationCustomerController {

    private static final Logger logger = LoggerFactory.getLogger(ReservationCustomerController.class);

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private PaymentService paymentService;

    @GetMapping("/bookForm")
    public String showBookingForm(@RequestParam("storeId") Long storeId,
                                  @RequestParam(value = "reservationTime", required = false) String reservationTime,
                                  @RequestParam(value = "tableId", required = false) Long tableId,
                                  @RequestParam(value = "guestCount", required = false, defaultValue = "1") Integer guestCount,
                                  Model model,
                                  HttpSession session) {
        logger.info("고객 예약 폼 요청 - storeId: {}, reservationTime: {}, tableId: {}, guestCount: {}",
                storeId, reservationTime, tableId, guestCount);

        model.addAttribute("storeId", storeId);
        model.addAttribute("selectedReservationTime", reservationTime);
        model.addAttribute("selectedTableId", tableId);
        model.addAttribute("guestCount", guestCount);

        String currentDate = (reservationTime != null && reservationTime.length() >= 10)
                ? reservationTime.substring(0, 10)
                : LocalDate.now().toString();
        model.addAttribute("currentDate", currentDate);

        StoreVO store = getDummyStoreInfo(storeId);
        model.addAttribute("store", store);

        session.removeAttribute("pendingReservation");
        session.removeAttribute("pendingPayment");

        return "reservation/customer/bookingForm";
    }

    @GetMapping("/available-slots")
    @ResponseBody
    public Map<String, List<StoreTableVO>> getAvailableSlots(@RequestParam("storeId") Long storeId,
                                                             @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        logger.info("예약 가능한 시간대 요청 - storeId: {}, date: {}", storeId, date);
        try {
            return reservationService.getAvailableTimeSlots(storeId, date);
        } catch (Exception e) {
            logger.error("예약 가능 시간대 조회 중 오류 발생: {}", e.getMessage(), e);
            return Map.of();
        }
    }

    @PostMapping("/book-temp")
    @ResponseBody
    public String processBookingFormTemp(@ModelAttribute ReservationVO reservation,
                                         @RequestParam("reservationTimeStr") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime reservationTime,
                                         @RequestParam("amount") BigDecimal amount,
                                         @RequestParam("paymentMethod") String paymentMethod,
                                         @RequestParam("transactionId") String transactionId,
                                         HttpSession session) {

        try {
            reservation.setReservationTime(reservationTime);
            Long memberId = (Long) session.getAttribute("memberId");
            if (memberId == null) {
                memberId = 1L;
            }
            reservation.setMemberId(memberId);
            reservation.setStatus("PENDING");

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

    @PostMapping("/complete-payment")
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
            StoreVO store = getDummyStoreInfo(storeId);
            model.addAttribute("store", store);
        }

        if (reservationId != null) {
            try {
                ReservationVO reservationFromDb = reservationService.getReservationById(reservationId);
                if (reservationFromDb != null) {
                    model.addAttribute("confirmedReservation", reservationFromDb);

                    if (reservationFromDb.getTableId() != null) {
                        StoreTableVO storeTable = reservationService.getStoreTableInfoById(reservationFromDb.getTableId());
                        if (storeTable != null) {
                            model.addAttribute("tableName", storeTable.getTableName());
                        } else {
                            model.addAttribute("tableName", "정보 없음");
                        }
                    } else {
                        model.addAttribute("tableName", "지정되지 않음");
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

        return "reservation/customer/bookingConfirm";
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
            redirectAttributes.addFlashAttribute("errorMessage", "결제가 취소되었거나 실패했습니다. 다시 시도해주세요.");
            PaymentVO payment = paymentService.getPaymentByTransactionId(transactionId);
            if (payment != null && payment.getReservationId() != null) {
                redirectAttributes.addAttribute("storeId", reservationService.getReservationById(payment.getReservationId()).getStoreId());
            }
            return "redirect:/reservation/customer/bookForm";
        }

        try {
            PaymentVO payment = null;
            for (int i = 0; i < 10; i++) {
                payment = paymentService.getPaymentByTransactionId(transactionId);
                if (payment != null && "COMPLETED".equals(payment.getStatus())) {
                    reservationService.updateReservationStatus(payment.getReservationId(), "CONFIRMED");
                    break;
                }
                Thread.sleep(1000);
            }

            if (payment != null && "COMPLETED".equals(payment.getStatus())) {
                Long reservationId = payment.getReservationId();
                if (reservationId != null) {
                    ReservationVO reservation = reservationService.getReservationById(reservationId);
                    if (reservation != null) {
                        logger.info("결제 완료 후 세션 대신 URL 파라미터로 예약 ID 전달: {}", reservationId);
                        redirectAttributes.addAttribute("storeId", reservation.getStoreId());
                        redirectAttributes.addAttribute("reservationId", reservationId); // ⭐ 이 라인이 추가되었습니다.

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

    private StoreVO getDummyStoreInfo(Long storeId) {
        StoreVO store = new StoreVO();
        store.setStoreId(storeId);
        store.setStoreName("더미 레스토랑 (ID:" + storeId + ")");
        store.setAddress("서울시 가짜구 더미동 123");
        return store;
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
            // Service 계층의 예약 취소 및 환불 로직 호출
            reservationService.cancelReservationByUser(reservationId);

            response.put("success", true);
            response.put("message", "예약이 성공적으로 취소되었습니다.");
        } catch (Exception e) {
            logger.error("예약 취소 중 오류 발생: {}", e.getMessage(), e);
            response.put("success", false);
            response.put("message", e.getMessage());
        }
        return response;
    }
}
