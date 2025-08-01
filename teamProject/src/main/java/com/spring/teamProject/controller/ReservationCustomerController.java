// src/main/java/com/spring/teamProject/controller/ReservationCustomerController.java
package com.spring.teamProject.controller;

import com.spring.teamProject.service.ReservationService;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.StoreTableVO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import jakarta.servlet.http.HttpSession; // HttpSession import 추가

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

    // JSP에 전달할 가데이터 StoreVO 생성
    private StoreVO getDummyStoreInfo(Long storeId) {
        StoreVO store = new StoreVO();
        store.setStoreId(storeId);
        store.setStoreName("더미 레스토랑 (ID:" + storeId + ")");
        store.setAddress("서울시 가짜구 더미동 123");
        return store;
    }

    /**
     * 예약 신청 폼을 보여주는 메서드
     */
    @GetMapping("/bookForm")
    public String showBookingForm(@RequestParam("storeId") Long storeId,
                                  @RequestParam(value = "date", required = false)
                                  @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
                                  Model model) {
        logger.info("고객 예약 폼 요청 - storeId: {}", storeId);

        if (date == null) {
            date = LocalDate.now();
        }

        StoreVO store = getDummyStoreInfo(storeId);
        model.addAttribute("store", store);
        model.addAttribute("storeId", storeId);
        model.addAttribute("reservationVO", new ReservationVO());
        model.addAttribute("currentDate", date);

        return "reservation/customer/bookingForm";
    }

    /**
     * 예약 가능한 시간대 및 테이블 정보를 JSON 형태로 반환하는 AJAX 엔드포인트
     */
    @GetMapping("/available-slots")
    @ResponseBody
    public Map<String, List<StoreTableVO>> getAvailableSlots(@RequestParam("storeId") Long storeId,
                                                             @RequestParam("date")
                                                             @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        logger.info("예약 가능한 시간대 요청 - storeId: {}, date: {}", storeId, date);

        try {
            return reservationService.getAvailableTimeSlots(storeId, date);
        } catch (Exception e) {
            logger.error("예약 가능 시간대 조회 중 오류 발생: {}", e.getMessage(), e);
            return Map.of();
        }
    }


    /**
     * 예약 신청 폼 제출 처리 메소드 (단일 테이블 선택으로 원복)
     */
    @PostMapping("/book")
    public String processBookingForm(@ModelAttribute("reservationVO") ReservationVO reservation,
                                     HttpSession session,
                                     RedirectAttributes redirectAttributes) {
        logger.info("예약 폼 제출됨 - ReservationVO: {}", reservation);

        // TODO: 로그인된 사용자 ID를 세션에서 가져와야 함 (더미 데이터 사용)
        Long memberId = (Long) session.getAttribute("memberId");
        if (memberId == null) {
            memberId = 1L; // 테스트용 임시 memberId
        }
        reservation.setMemberId(memberId);
        reservation.setStatus("PENDING");

        try {
            reservationService.addReservation(reservation);
            logger.info("예약 성공: {}", reservation.getReservationId());
            redirectAttributes.addFlashAttribute("message", "예약이 성공적으로 접수되었습니다!");
            return "redirect:/reservation/customer/bookingConfirm?storeId=" + reservation.getStoreId() + "&reservationId=" + reservation.getReservationId();
        } catch (Exception e) {
            logger.error("예약 중 오류 발생: {}", e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "예약 처리 중 오류가 발생했습니다. 다시 시도해주세요.");
            return "redirect:/reservation/customer/bookForm?storeId=" + reservation.getStoreId();
        }
    }

    /**
     * 임시로 만들 "예약 완료" 페이지
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
}