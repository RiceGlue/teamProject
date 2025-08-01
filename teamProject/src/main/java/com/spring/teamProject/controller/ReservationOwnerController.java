// src/main/java/com/spring/teamProject/controller/ReservationOwnerController.java
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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/reservation/owner")
public class ReservationOwnerController {

    private static final Logger logger = LoggerFactory.getLogger(ReservationOwnerController.class);

    @Autowired
    private ReservationService reservationService;

    // JSP에 전달할 가데이터 StoreVO 생성
    private StoreVO getDummyStoreInfo(Long storeId) {
        StoreVO store = new StoreVO();
        store.setStoreId(storeId);
        store.setStoreName("더미 매장 (ID:" + storeId + ")");
        store.setAddress("서울시 가짜구 더미동 123");
        return store;
    }

    /**
     * 점주용 예약 목록을 보여주는 메서드
     * GET /reservation/owner/manageList?storeId={storeId}
     * 이 메서드는 manageBookingList.jsp 화면을 반환하고 해당 매장의 예약 목록을 전달합니다.
     */
    @GetMapping("/manageList")
    public String manageReservations(@RequestParam("storeId") Long storeId, Model model) {
        logger.info("점주 예약 관리 목록 요청 - storeId: {}", storeId);

        StoreVO store = getDummyStoreInfo(storeId);
        model.addAttribute("store", store);
        model.addAttribute("storeId", storeId);

        try {
            List<ReservationVO> reservations = reservationService.getReservationsByStoreId(storeId);
            model.addAttribute("reservations", reservations);
            logger.info("매장 ID {}의 예약 {}건 조회.", storeId, reservations.size());
        } catch (Exception e) {
            logger.error("매장 ID {} 예약 목록 조회 중 오류 발생: {}", storeId, e.getMessage(), e);
            model.addAttribute("errorMessage", "예약 목록을 불러오는데 오류가 발생했습니다.");
        }

        return "reservation/owner/manageBookingList";
    }

    /**
     * 예약 상태 업데이트 메소드
     * POST /reservation/owner/updateStatus
     */
    @PostMapping("/updateStatus")
    public String updateReservationStatus(@RequestParam("reservationId") Long reservationId,
                                          @RequestParam("status") String status,
                                          @RequestParam("storeId") Long storeId,
                                          RedirectAttributes redirectAttributes) {
        logger.info("예약 상태 업데이트 요청 - reservationId: {}, status: {}", reservationId, status);
        try {
            reservationService.updateReservationStatus(reservationId, status);
            redirectAttributes.addFlashAttribute("message", "예약 상태가 성공적으로 업데이트되었습니다.");
        } catch (Exception e) {
            logger.error("예약 상태 업데이트 중 오류 발생: {}", e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "예약 상태 업데이트 중 오류가 발생했습니다: " + e.getMessage());
        }
        return "redirect:/reservation/owner/manageList?storeId=" + storeId;
    }
}