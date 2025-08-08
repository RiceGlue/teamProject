// src/main/java/com/spring/teamProject/controller/ReservationCustomerController.java

package com.spring.teamProject.controller;

import com.spring.teamProject.service.PaymentService;
import com.spring.teamProject.service.ReservationService;
import com.spring.teamProject.vo.PaymentVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;
import com.spring.teamProject.vo.StoreVO;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/reservation/customer")
public class ReservationCustomerController {

    private static final Logger logger = LoggerFactory.getLogger(ReservationCustomerController.class);

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private PaymentService paymentService;

    /**
     * 예약 신청 폼을 보여주는 메서드
     */
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

    /**
     * 예약 가능한 시간대 및 테이블 정보를 JSON 형태로 반환하는 AJAX 엔드포인트
     */
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

    /**
     * 예약 신청 폼 제출 처리 메소드 (결제 전 임시 예약 및 결제 정보 저장)
     */
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
            payment.setAmount(amount);
            payment.setPaymentMethod(paymentMethod);
            payment.setTransactionId(transactionId);
            payment.setStatus("PENDING");

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


    /**
     * "예약 완료" 페이지
     */
    @GetMapping("/bookingConfirm")
    public String bookingConfirm(@RequestParam("storeId") Long storeId,
                                 @RequestParam(value = "reservationId", required = false) Long reservationId,
                                 Model model) {
        StoreVO store = getDummyStoreInfo(storeId);
        model.addAttribute("store", store);
        model.addAttribute("storeId", storeId);

        if (reservationId != null) {
            try {
                ReservationVO confirmedReservation = reservationService.getReservationById(reservationId);
                model.addAttribute("confirmedReservation", confirmedReservation);
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
     * PortOne 결제 리다이렉트 엔드포인트
     */
    @GetMapping("/payment-result")
    public String handlePaymentResult(@RequestParam("transactionId") String transactionId,
                                      @RequestParam("code") String resultCode,
                                      RedirectAttributes redirectAttributes,
                                      Model model) {
        logger.info("PortOne 결제 결과 리다이렉트 수신 - transactionId: {}, resultCode: {}", transactionId, resultCode);

        if (!"0000".equals(resultCode)) {
            redirectAttributes.addFlashAttribute("errorMessage", "결제가 취소되었거나 실패했습니다. 다시 시도해주세요.");
            return "redirect:/reservation/customer/bookForm";
        }

        model.addAttribute("transactionId", transactionId);
        model.addAttribute("message", "결제가 완료되었습니다. 예약 정보가 확정되는 대로 알림을 보내드리겠습니다.");
        return "reservation/customer/paymentProcessing";
    }


    private StoreVO getDummyStoreInfo(Long storeId) {
        StoreVO store = new StoreVO();
        store.setStoreId(storeId);
        store.setStoreName("더미 레스토랑 (ID:" + storeId + ")");
        store.setAddress("서울시 가짜구 더미동 123");
        return store;
    }
}