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

@Controller
@RequestMapping("/reservation/customer")
public class ReservationCustomerController {

    private static final Logger logger = LoggerFactory.getLogger(ReservationCustomerController.class);

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private PaymentService paymentService; // PaymentService 주입

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

        // 이전 세션 정보 초기화 (선택 사항)
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
     * 이 메서드는 클라이언트에서 `amount`, `paymentMethod`, `transactionId`를 함께 받아야 합니다.
     */
    @PostMapping("/book-temp")
    @ResponseBody
    public String processBookingFormTemp(@ModelAttribute ReservationVO reservation,
                                         @RequestParam("reservationTimeStr") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime reservationTime,
                                         @RequestParam("amount") BigDecimal amount, // 클라이언트에서 받아야 함
                                         @RequestParam("paymentMethod") String paymentMethod, // 클라이언트에서 받아야 함
                                         @RequestParam("transactionId") String transactionId, // 클라이언트에서 받아야 함
                                         HttpSession session) {

        try {
            // 1. ReservationVO 객체에 예약 시간 및 멤버 정보 설정
            reservation.setReservationTime(reservationTime);
            Long memberId = (Long) session.getAttribute("memberId");
            if (memberId == null) {
                memberId = 1L; // 테스트용 임시 memberId
            }
            reservation.setMemberId(memberId);
            reservation.setStatus("PENDING"); // 예약 상태는 PENDING으로 시작

            // 2. 예약 정보 DB에 저장 (reservationId가 여기서 생성됨)
            reservationService.addReservation(reservation);
            logger.info("임시 예약 정보 DB 저장 완료. reservationId: {}", reservation.getReservationId());

            // 3. PaymentVO 객체 생성 및 결제 정보 설정
            PaymentVO payment = new PaymentVO();
            payment.setReservationId(reservation.getReservationId()); // 생성된 예약 ID를 결제 정보에 연결
            payment.setAmount(amount);
            payment.setPaymentMethod(paymentMethod);
            payment.setTransactionId(transactionId);
            payment.setStatus("PENDING"); // 결제 상태는 PENDING으로 시작

            // 4. 결제 정보 DB에 저장
            paymentService.addPayment(payment);
            logger.info("임시 결제 정보 DB 저장 완료. transactionId: {}", payment.getTransactionId());

            // 세션에 예약 ID와 결제 transactionId 저장 (결제 결과 리다이렉트 시 사용)
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
     * 예약 확정 후 사용자에게 최종적으로 보여주는 페이지.
     * 웹훅 처리에서 예약 확정이 완료되면 이 페이지로 리다이렉트될 수 있습니다.
     */
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
                // 1. ReservationVO 조회
                ReservationVO confirmedReservation = reservationService.getReservationById(reservationId);
                model.addAttribute("confirmedReservation", confirmedReservation);

                // ⭐ 2. PaymentVO 추가 조회 및 모델에 paymentId 추가 ⭐
                if (confirmedReservation != null) {
                    PaymentVO payment = paymentService.getPaymentByReservationId(reservationId); // 예약 ID로 결제 정보 조회
                    if (payment != null) {
                        model.addAttribute("paymentId", payment.getPaymentId()); // paymentId를 모델에 추가
                        model.addAttribute("transactionId", payment.getTransactionId()); // transactionId도 필요하면 추가
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
     * PortOne 결제 리다이렉트 엔드포인트
     * 결제 완료 후 사용자 브라우저가 이동하는 페이지.
     * 실제 결제 검증은 웹훅에서 처리되므로, 이 페이지는 사용자에게 처리 중임을 알립니다.
     */
    @GetMapping("/payment-result")
    public String handlePaymentResult(@RequestParam("transactionId") String transactionId,
                                      @RequestParam(value = "code", required = false) String resultCode,
                                      RedirectAttributes redirectAttributes,
                                      Model model) {
        logger.info("PortOne 결제 결과 리다이렉트 수신 - transactionId: {}, resultCode: {}", transactionId, resultCode);

        if (resultCode != null && !"0000".equals(resultCode)) {
            redirectAttributes.addFlashAttribute("errorMessage", "결제가 취소되었거나 실패했습니다. 다시 시도해주세요.");
            return "redirect:/reservation/customer/bookForm";
        }

        try {
            PaymentVO payment = paymentService.getPaymentByTransactionId(transactionId);

            if (payment != null && payment.getReservationId() != null) {
                Long reservationId = payment.getReservationId();

                redirectAttributes.addAttribute("storeId", getDummyStoreInfo(payment.getReservationId()).getStoreId());
                redirectAttributes.addAttribute("reservationId", reservationId);

                return "redirect:/reservation/customer/bookingConfirm";
            } else {
                logger.error("결제 ID({})에 해당하는 예약 정보를 찾을 수 없습니다.", transactionId);
                redirectAttributes.addFlashAttribute("errorMessage", "예약 정보를 찾을 수 없습니다. 고객센터에 문의해주세요.");
                return "redirect:/reservation/customer/bookForm";
            }

        } catch (Exception e) {
            logger.error("결제 처리 후 리다이렉션 중 오류 발생: {}", e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "결제 처리 중 오류가 발생했습니다. 고객센터에 문의해주세요.");
            return "redirect:/reservation/customer/bookForm";
        }
    }


    // 더미 매장 정보 제공 헬퍼 메서드
    private StoreVO getDummyStoreInfo(Long storeId) {
        StoreVO store = new StoreVO();
        store.setStoreId(storeId);
        store.setStoreName("더미 레스토랑 (ID:" + storeId + ")");
        store.setAddress("서울시 가짜구 더미동 123");
        return store;
    }
}