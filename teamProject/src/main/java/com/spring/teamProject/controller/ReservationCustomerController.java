// src/main/java/com/spring/teamProject/controller/ReservationCustomerController.java
package com.spring.teamProject.controller;

import com.spring.teamProject.service.ReservationService;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreVO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime; // LocalDateTime 사용

@Controller
@RequestMapping("/reservation/customer")
public class ReservationCustomerController {

    private static final Logger logger = LoggerFactory.getLogger(ReservationCustomerController.class);

    @Autowired
    private ReservationService reservationService;

    // JSP에 전달할 가데이터 StoreVO 생성 (화면에 표시될 매장 정보를 위한 더미 데이터)
    private StoreVO getDummyStoreInfo(Long storeId) {
        StoreVO store = new StoreVO();
        store.setStoreId(storeId);
        store.setStoreName("더미 레스토랑 (ID:" + storeId + ")");
        store.setAddress("서울시 가짜구 더미동 123");
        return store;
    }

    /**
     * 예약 신청 폼을 보여주는 메서드
     * GET /reservation/customer/bookForm?storeId={storeId}
     * 이 메서드는 bookingForm.jsp 화면을 반환하고 예약 객체를 모델에 추가합니다.
     */
    @GetMapping("/bookForm")
    public String showBookingForm(@RequestParam("storeId") Long storeId, Model model) {
        logger.info("고객 예약 폼 요청 - storeId: {}", storeId);

        StoreVO store = getDummyStoreInfo(storeId);
        model.addAttribute("store", store);
        model.addAttribute("storeId", storeId);

        model.addAttribute("reservationVO", new ReservationVO()); // 빈 예약 객체 추가

        // TODO: reservation_settings 테이블을 활용하여 예약 가능한 날짜/시간/테이블 정보를 동적으로 가져와야 합니다.
        // 현재는 폼에서 직접 입력하도록 합니다.

        return "reservation/customer/bookingForm";
    }

    /**
     * 예약 신청 폼 제출 처리 메소드
     * POST /reservation/customer/book
     * 실제 예약 데이터를 처리하고 데이터베이스에 저장합니다.
     */
    @PostMapping("/book")
    public String processBookingForm(@ModelAttribute("reservationVO") ReservationVO reservation,
                                     RedirectAttributes redirectAttributes) {
        logger.info("예약 폼 제출됨 - ReservationVO: {}", reservation);

        // TODO: 실제 사용자 ID (memberId)를 로그인 세션에서 가져와야 합니다.
        // 현재는 더미 데이터 사용
        reservation.setMemberId(1L); // 예시: 로그인된 사용자 member_id
        reservation.setStatus("PENDING"); // 초기 상태는 'PENDING' (결제대기)

        // TODO: tableId는 예약 가능한 테이블 목록에서 선택하도록 구현되어야 합니다.
        // 현재는 임시로 첫 번째 테이블 ID를 사용한다고 가정 (실제로는 동적으로 가져와야 함)
        if (reservation.getTableId() == null) {
            reservation.setTableId(1L); // 예시: 임의의 table_id
        }

        try {
            reservationService.addReservation(reservation);
            logger.info("예약 성공: {}", reservation.getReservationId());
            redirectAttributes.addFlashAttribute("message", "예약이 성공적으로 접수되었습니다!");
            // 예약 완료 페이지로 리다이렉트 시 storeId와 예약 ID를 함께 넘겨 상세 확인 가능하도록
            return "redirect:/reservation/customer/bookingConfirm?storeId=" + reservation.getStoreId() + "&reservationId=" + reservation.getReservationId();
        } catch (Exception e) {
            logger.error("예약 중 오류 발생: {}", e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "예약 처리 중 오류가 발생했습니다. 다시 시도해주세요.");
            // 오류 발생 시 다시 폼으로 돌아가거나 오류 페이지로 리다이렉트
            return "redirect:/reservation/customer/bookForm?storeId=" + reservation.getStoreId();
        }
    }

    /**
     * 임시로 만들 "예약 완료" 페이지 (화면만 띄울 목적)
     * GET /reservation/customer/bookingConfirm?storeId={storeId}&reservationId={reservationId}
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