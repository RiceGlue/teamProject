// src/main/java/com/spring/teamProject/controller/ReservationOwnerController.java
package com.spring.teamProject.controller;

import com.spring.teamProject.service.ReservationService;
import com.spring.teamProject.service.StoreService;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreVO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/reservation/owner")
public class ReservationOwnerController {

    private static final Logger logger = LoggerFactory.getLogger(ReservationOwnerController.class);

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private StoreService storeService;

    /**
     * 점주용 예약 목록을 보여주는 메서드 (JSP 화면 반환)
     * GET /reservation/owner/manageList?storeId={storeId}
     */
    @GetMapping("/manageList")
    public String manageReservations(@RequestParam("storeId") Long storeId, Model model) {
        logger.info("점주 예약 관리 목록 페이지 요청 - storeId: {}", storeId);

        try {
            // 실제 DB에서 StoreVO 데이터를 가져옵니다.
            StoreVO store = storeService.getStoreById(storeId);
            model.addAttribute("store", store);
            model.addAttribute("storeId", storeId);
            logger.info("매장 ID {}의 정보 조회 성공: {}", storeId, store.getStoreName());

        } catch (Exception e) {
            logger.error("매장 ID {} 정보 조회 중 오류 발생: {}", storeId, e.getMessage(), e);
            model.addAttribute("errorMessage", "매장 정보를 불러오는데 오류가 발생했습니다.");
        }

        model.addAttribute("body", "reservation/owner/manageBookingList.jsp");

        return "owner/owner_layout";
    }

    /**
     * 무한 스크롤을 위한 예약 목록 API
     * GET /reservation/owner/api/reservations
     * @throws Exception
     */
    @GetMapping("/api/reservations")
    @ResponseBody
    public List<ReservationVO> getReservationsByApi(@RequestParam("storeId") Long storeId,
                                                    @RequestParam("status") String status,
                                                    @RequestParam("page") int page,
                                                    @RequestParam("size") int size) throws Exception {
        logger.info("무한 스크롤을 위한 예약 목록 API 요청 - storeId: {}, status: {}, page: {}, size: {}", storeId, status, page, size);

        List<ReservationVO> reservationsFromService = reservationService.getReservationsByStoreIdAndStatusWithPaging(storeId, status, page, size);
        logger.info("무한 스크롤 API 응답 - {} 건의 데이터 반환", reservationsFromService.size());

        return reservationsFromService;
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

            if(status.equals("CONFIRMED")) {
            	reservationService.increaseUserTemperatureByReservation(reservationId);
            } else if (status.equals("NO_SHOW")) {
            	reservationService.decreaseUserTemperatureByReservation(reservationId);
            }

            redirectAttributes.addFlashAttribute("message", "예약 상태가 성공적으로 업데이트되었습니다.");
        } catch (Exception e) {
            logger.error("예약 상태 업데이트 중 오류 발생: {}", e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "예약 상태 업데이트 중 오류가 발생했습니다: " + e.getMessage());
        }
        return "redirect:/reservation/owner/manageList?storeId=" + storeId;
    }

    /*
     * 가맹점 회원이 매장 테이블을 생성합니다 (벽, 유리, 테이블)
     */
    @GetMapping("/layout_editor")
    public String layoutEditor(@RequestParam("storeId") Long storeId, Model model) throws Exception {
        logger.info("레이아웃 에디터 요청 - storeId: {}", storeId);
        StoreVO store = storeService.getStoreById(storeId);
        model.addAttribute("store", store);
        model.addAttribute("storeId", storeId);
        return "reservation/owner/layout_editor";
    }
}