package com.spring.teamProject.controller;

import com.spring.teamProject.vo.StoreVO; // StoreVO 임포트
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/reservation/owner")
public class ReservationOwnerController {

    private static final Logger logger = LoggerFactory.getLogger(ReservationOwnerController.class);

    // JSP에 전달할 가데이터 StoreVO 생성
    private StoreVO getDummyStoreInfo(Long storeId) {
        StoreVO store = new StoreVO();
        store.setStoreId(storeId);
        store.setStoreName("더미 매장"); // 점주 페이지에 표시될 가데이터
        store.setAddress("서울시 가짜구 더미동 123");
        // 필요하다면 다른 필드도 여기에 추가하세요.
        return store;
    }

    /**
     * 점주용 예약 목록을 보여주는 메서드
     * GET /reservation/owner/manageList?storeId={storeId}
     * 이 메서드는 오직 manageBookingList.jsp 화면을 반환하는 역할만 합니다.
     */
    @GetMapping("/manageList")
    public String manageReservations(@RequestParam("storeId") Long storeId, Model model) {
        logger.info("점주 예약 관리 목록 요청 - storeId: {}", storeId);

        // JSP에서 사용할 더미 상점 정보를 Model에 추가
        StoreVO store = getDummyStoreInfo(storeId);
        model.addAttribute("store", store);
        model.addAttribute("storeId", storeId); // storeId도 필요할 수 있으니 추가

        // 예약 목록도 가데이터로 JSP에 직접 넣거나, 간단한 리스트를 넘겨줄 수 있습니다.
        // 현재는 JSP에서 직접 가데이터를 표시하도록 하겠습니다.

        // JSP 파일 경로 (이전 설정 유지)
        return "reservation/owner/manageBookingList";
    }

    // 예약 상태 업데이트 메소드 등 다른 기능 관련 @PostMapping 등은
    // 현재는 화면만 띄울 목적이므로 잠시 주석 처리하거나 비워둡니다.
    // @PostMapping("/updateStatus")
    // public String updateReservationStatus(...) {
    //     return "redirect:/reservation/owner/manageList?storeId=1";
    // }
}