package com.spring.teamProject.controller;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.teamProject.service.ReservationService;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreTableVO;
import com.spring.teamProject.vo.StoreVO;

import jakarta.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

@Controller
@RequestMapping("/reservation/customer")
public class ReservationCustomerController {

    private static final Logger logger = LoggerFactory.getLogger(ReservationCustomerController.class);

    @Autowired
    private ReservationService reservationService;

    // TODO: PortOne API 설정 정보 - 실제 관리자 페이지에서 발급받은 Secret Key로 변경해야 합니다!
    private static final String PORTONE_SECRET_KEY = "portone-api-key-11881682-d208-4707-8709-1ac268b64c31";

    /**
     * 예약 신청 폼을 보여주는 메서드
     */
    @GetMapping("/bookForm")
    public String showBookingForm(@RequestParam("storeId") Long storeId,
                                  @RequestParam(value = "reservationTime", required = false) String reservationTime,
                                  @RequestParam(value = "tableId", required = false) Long tableId,
                                  @RequestParam(value = "guestCount", required = false, defaultValue = "1") Integer guestCount,
                                  Model model) {
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

        // 더미 매장 정보 (실제 DB에서 가져와야 함)
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
     * 예약 신청 폼 제출 처리 메소드
     * 이 메서드는 결제 검증이 완료된 후에만 호출됩니다.
     */
    @PostMapping("/book")
    public String processBookingForm(@ModelAttribute("reservationVO") ReservationVO reservation,
                                     @RequestParam("reservationTimeStr") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime reservationTime,
                                     @RequestParam("paymentId") String paymentId,
                                     HttpSession session,
                                     RedirectAttributes redirectAttributes) {

        reservation.setReservationTime(reservationTime);
        reservation.setPaymentId(paymentId);

        logger.info("예약 폼 제출됨 - ReservationVO: {}", reservation);
        logger.info("결제 ID: {}", paymentId);

        Long memberId = (Long) session.getAttribute("memberId");
        if (memberId == null) {
            memberId = 1L; // 테스트용 임시 memberId
        }
        reservation.setMemberId(memberId);
        reservation.setStatus("CONFIRMED"); // 결제 검증이 끝났으므로 바로 'CONFIRMED' 상태로 변경

        try {
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
     * PortOne 결제 결과 처리를 위한 엔드포인트
     * 결제 위/변조를 검증하고 최종 예약을 처리합니다.
     */
    @GetMapping("/payment-result")
    public String handlePaymentResult(@RequestParam("paymentId") String paymentId,
                                      @RequestParam("code") String resultCode,
                                      @RequestParam Map<String, String> params,
                                      HttpSession session,
                                      RedirectAttributes redirectAttributes) {

        logger.info("PortOne 결제 결과 리다이렉트 - paymentId: {}, resultCode: {}", paymentId, resultCode);

        // 결제 실패 또는 취소 시 PortOne이 보내는 resultCode가 '0000'이 아님
        if (!"0000".equals(resultCode)) {
            redirectAttributes.addFlashAttribute("errorMessage", "결제가 취소되었거나 실패했습니다. 다시 시도해주세요.");
            return "redirect:/reservation/customer/bookForm";
        }

        try {
            // 1. PortOne API 호출을 위한 Access Token 발급
            String accessToken = getPortOneAccessToken();
            if (accessToken == null) {
                throw new Exception("PortOne Access Token 발급 실패");
            }

            // 2. Access Token을 이용해 결제 정보 조회
            String paymentData = getPaymentInfo(paymentId, accessToken);
            if (paymentData == null) {
                throw new Exception("PortOne 결제 정보 조회 실패");
            }

            // 3. 결제 상태 및 금액 위/변조 검증
            Gson gson = new Gson();
            JsonObject paymentObject = gson.fromJson(paymentData, JsonObject.class);
            String paymentStatus = paymentObject.get("status").getAsString();
            int paymentAmount = paymentObject.get("amount").getAsInt();

            // TODO: 실제 예약 금액과 비교하는 로직으로 변경 필요
            // 이 예시에서는 1000원으로 고정
            int expectedAmount = 1000;

            if ("PAID".equals(paymentStatus) && paymentAmount == expectedAmount) {
                logger.info("결제 검증 성공! paymentId: {}", paymentId);

                // 4. 결제 검증 성공 후 예약 정보를 DB에 저장 (세션 또는 파라미터 활용)
                // 이 부분은 고객님의 비즈니스 로직에 맞춰 구현해야 합니다.
                //
                // 예시: reservationService.addReservationWithPaymentId(paymentId, "CONFIRMED");

                redirectAttributes.addFlashAttribute("message", "예약이 성공적으로 완료되었습니다!");

                // 예약 완료 페이지로 리다이렉트
                Long reservationId = 1234L; // TODO: 실제 예약 ID로 변경
                return "redirect:/reservation/customer/bookingConfirm?storeId=" + 1L + "&reservationId=" + reservationId;
            } else {
                logger.warn("결제 검증 실패! paymentId: {}, status: {}, amount: {}", paymentId, paymentStatus, paymentAmount);
                redirectAttributes.addFlashAttribute("errorMessage", "결제 상태가 유효하지 않습니다. 다시 시도해주세요.");

                // TODO: 결제 취소 API 호출 로직 추가 (필요 시)

                return "redirect:/reservation/customer/bookForm";
            }
        } catch (Exception e) {
            logger.error("결제 검증 중 오류 발생: {}", e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "결제 검증 중 오류가 발생했습니다. 다시 시도해주세요.");
            return "redirect:/reservation/customer/bookForm";
        }
    }

    /**
     * PortOne Access Token 발급
     */
    private String getPortOneAccessToken() throws Exception {
        URL url = new URL("https://api.portone.io/access-token");
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setRequestProperty("Content-Type", "application/json; utf-8");
        con.setDoOutput(true);

        String jsonInputString = "{\"secretKey\": \"" + PORTONE_SECRET_KEY + "\"}";

        try (DataOutputStream wr = new DataOutputStream(con.getOutputStream())) {
            wr.write(jsonInputString.getBytes("utf-8"));
            wr.flush();
        }

        try (BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "utf-8"))) {
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
            Gson gson = new Gson();
            JsonObject jsonObject = gson.fromJson(response.toString(), JsonObject.class);
            return jsonObject.get("accessToken").getAsString();
        }
    }

    /**
     * PortOne 결제 정보 조회
     */
    private String getPaymentInfo(String paymentId, String accessToken) throws Exception {
        URL url = new URL("https://api.portone.io/payments/" + paymentId);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("GET");
        con.setRequestProperty("Authorization", "Bearer " + accessToken);

        try (BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "utf-8"))) {
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine.trim());
            }
            return response.toString();
        }
    }

    // 더미 매장 정보를 생성하는 private 메서드
    private StoreVO getDummyStoreInfo(Long storeId) {
        StoreVO store = new StoreVO();
        store.setStoreId(storeId);
        store.setStoreName("더미 레스토랑 (ID:" + storeId + ")");
        store.setAddress("서울시 가짜구 더미동 123");
        return store;
    }
}