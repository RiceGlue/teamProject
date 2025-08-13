package com.spring.teamProject.controller;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
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
                response.put("result", "pending");  // 아직 웹훅 처리 대기 중
            }
        } else {
            response.put("result", "not_found");
        }
        return response;
    }


    @GetMapping("/bookingConfirm")
    public String bookingConfirm(@RequestParam("storeId") Long storeId,
                                 @RequestParam(value = "reservationId", required = false) Long reservationId,
                                 Model model) {
        logger.info("예약 완료 페이지 요청 - storeId: {}, reservationId: {}", storeId, reservationId);
        StoreVO store = getDummyStoreInfo(storeId);
        model.addAttribute("store", store);
        model.addAttribute("storeId", storeId);

        if (reservationId != null) {
            try {
                ReservationVO confirmedReservation = reservationService.getReservationById(reservationId);
                model.addAttribute("confirmedReservation", confirmedReservation);

                if (confirmedReservation != null) {
                    PaymentVO payment = paymentService.getPaymentByReservationId(reservationId);
                    if (payment != null) {
                        model.addAttribute("paymentId", payment.getPaymentId());
                        model.addAttribute("transactionId", payment.getTransactionId());
                    }
                }

                model.addAttribute("message", "예약이 성공적으로 접수되었습니다! (예약 번호: " + reservationId + ")");
            } catch (Exception e) {
                logger.error("예약 상세 조회 오류: {}", e.getMessage(), e);
                model.addAttribute("message", "예약 완료! (예약 정보를 불러오는데 오류가 있었습니다.)");
            }
        } else {
            model.addAttribute("message", "예약이 접수되었습니다! (예약 번호는 확인되지 않았습니다.)");
        }
        return "reservation/customer/bookingConfirm";
    }

    /**
     * 클라이언트로부터 결제 상태를 조회하는 API
     * @param transactionId 결제 고유 번호
     * @return 결제 상태에 따른 응답 ("success" 또는 "pending")
     */
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
                                      RedirectAttributes redirectAttributes) {

        logger.info("PortOne 결제 결과 리다이렉트 수신 - transactionId: {}, resultCode: {}", transactionId, resultCode);

        if (resultCode != null && !"0000".equals(resultCode)) {
            redirectAttributes.addFlashAttribute("errorMessage", "결제가 취소되었거나 실패했습니다. 다시 시도해주세요.");
            return "redirect:/reservation/customer/bookForm";
        }

        try {
            PaymentVO payment = null;
            for (int i = 0; i < 10; i++) {
                payment = paymentService.getPaymentByTransactionId(transactionId);
                if (payment != null && "COMPLETED".equals(payment.getStatus())) {
                    break;
                }
                Thread.sleep(1000);
            }

            if (payment != null && "COMPLETED".equals(payment.getStatus())) {
                Long reservationId = payment.getReservationId();
                ReservationVO reservation = reservationService.getReservationById(reservationId);
                if (reservation != null) {
                    redirectAttributes.addAttribute("storeId", reservation.getStoreId());
                    redirectAttributes.addAttribute("reservationId", reservationId);
                    return "redirect:/reservation/customer/bookingConfirm";
                }
            }

            logger.error("결제 ID({})에 해당하는 확정된 예약 정보를 찾을 수 없습니다.", transactionId);
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
}