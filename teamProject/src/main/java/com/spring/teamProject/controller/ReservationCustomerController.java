package com.spring.teamProject.controller;

import com.spring.teamProject.vo.StoreVO; // StoreVO 임포트
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping; // PostMapping 임포트 추가
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/reservation/customer")
public class ReservationCustomerController {

    private static final Logger logger = LoggerFactory.getLogger(ReservationCustomerController.class);

    // JSP에 전달할 가데이터 StoreVO 생성 (화면에 표시될 매장 정보를 위한 더미 데이터)
    private StoreVO getDummyStoreInfo(Long storeId) {
        StoreVO store = new StoreVO();
        store.setStoreId(storeId);
        store.setStoreName("더미 레스토랑"); // JSP에 표시될 가데이터
        store.setAddress("서울시 가짜구 더미동 123");
        // 필요하다면 다른 필드도 여기에 추가하세요.
        return store;
    }

    /**
     * 예약 신청 폼을 보여주는 메서드
     * GET /reservation/customer/bookForm?storeId={storeId}
     * 이 메서드는 오직 bookingForm.jsp 화면을 반환하는 역할만 합니다.
     */
    @GetMapping("/bookForm")
    public String showBookingForm(@RequestParam("storeId") Long storeId, Model model) {
        logger.info("고객 예약 폼 요청 - storeId: {}", storeId);

        // JSP에서 사용할 더미 상점 정보를 Model에 추가
        StoreVO store = getDummyStoreInfo(storeId);
        model.addAttribute("store", store);
        model.addAttribute("storeId", storeId); // storeId도 필요할 수 있으니 추가

        // Spring Form 태그를 사용하지 않으므로 ReservationVO 객체를 Model에 추가하지 않습니다.
        // `bookingForm.jsp`가 `form:form modelAttribute="reservationVO"`를 사용하지 않도록 변경할 것입니다.

        // JSP 파일 경로 (이전 설정 유지)
        return "reservation/customer/bookingForm";
    }

    /**
     * 예약 신청 폼 제출 처리 메소드 (기능 제거, 단순히 다음 페이지로 이동)
     * POST /reservation/customer/book
     * 현재는 폼 제출 시 에러 발생을 막고 단순히 다음 화면으로 넘어가는 역할만 합니다.
     * 실제 데이터 처리 로직은 여기에 구현되지 않습니다.
     */
    @PostMapping("/book")
    public String processBookingForm() {
        logger.info("예약 폼 제출됨 - 단순히 다음 화면으로 이동");
        // 실제 로직 없이, 예약 완료 페이지로 리다이렉트합니다.
        // storeId가 필요하다면 hidden input 등으로 받아와서 넘겨줄 수 있습니다.
        return "redirect:/reservation/customer/bookingConfirm?storeId=1"; // 임시로 storeId=1 사용
    }

    /**
     * 임시로 만들 "예약 완료" 페이지 (화면만 띄울 목적)
     * GET /reservation/customer/bookingConfirm?storeId={storeId}
     */
    @GetMapping("/bookingConfirm")
    public String bookingConfirm(@RequestParam("storeId") Long storeId, Model model) {
        StoreVO store = getDummyStoreInfo(storeId);
        model.addAttribute("store", store);
        model.addAttribute("storeId", storeId);
        model.addAttribute("message", "예약이 접수되었습니다! (이것은 가데이터 화면입니다.)");
        return "reservation/customer/bookingConfirm"; // 이 JSP 파일을 새로 만들어야 합니다.
    }
}