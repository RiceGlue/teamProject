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

import jakarta.servlet.http.HttpSession;

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
     * storeDetail.jsp에서 전송한 GET 요청을 처리
     */
    @GetMapping("/bookForm")
    public String showBookingForm(@RequestParam("storeId") Long storeId,
                                  @RequestParam(value = "reservationTime", required = false) String reservationTime,
                                  @RequestParam(value = "tableId", required = false) Long tableId,
                                  @RequestParam(value = "guestCount", required = false, defaultValue = "1") Integer guestCount,
                                  Model model) {
        logger.info("고객 예약 폼 요청 - storeId: {}, reservationTime: {}, tableId: {}, guestCount: {}",
                storeId, reservationTime, tableId, guestCount);

        // StoreDetail.jsp에서 넘겨받은 파라미터를 Model에 담아 bookingForm.jsp로 전달
        model.addAttribute("storeId", storeId);
        model.addAttribute("selectedReservationTime", reservationTime);
        model.addAttribute("selectedTableId", tableId);
        model.addAttribute("guestCount", guestCount);

        // reservationTime 파라미터에서 날짜 부분만 추출하여 bookingForm.jsp에 전달
        String currentDate = (reservationTime != null && reservationTime.length() >= 10)
                             ? reservationTime.substring(0, 10)
                             : LocalDate.now().toString();
        model.addAttribute("currentDate", currentDate);

        // DB에서 Store 정보를 조회하여 Model에 추가 (임시 데이터 사용)
        StoreVO store = getDummyStoreInfo(storeId);
        model.addAttribute("store", store);

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
                                     @RequestParam("reservationTimeStr") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime reservationTime,
                                     HttpSession session,
                                     RedirectAttributes redirectAttributes) {

        reservation.setReservationTime(reservationTime);

        logger.info("예약 폼 제출됨 - ReservationVO: {}", reservation);

        Long memberId = (Long) session.getAttribute("memberId");
        if (memberId == null) {
            memberId = 1L; // 테스트용 임시 memberId
        }
        reservation.setMemberId(memberId);
        reservation.setStatus("PENDING");

        try {
            // **추가된 로직: tableId가 null인 경우 서버에서 직접 할당**
            if (reservation.getTableId() == null) {
                Optional<Long> availableTableId = reservationService.findAvailableTable(
                    reservation.getStoreId(),
                    reservation.getReservationTime(),
                    reservation.getGuestCount()
                );

                if (availableTableId.isPresent()) {
                    reservation.setTableId(availableTableId.get());
                    logger.info("사용 가능한 테이블 ID가 할당되었습니다: {}", reservation.getTableId());
                } else {
                    redirectAttributes.addFlashAttribute("errorMessage", "해당 시간에 예약 가능한 테이블이 없습니다. 다른 시간을 선택해주세요.");
                    return "redirect:/reservation/customer/bookForm?storeId=" + reservation.getStoreId();
                }
            }

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