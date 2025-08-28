package com.spring.teamProject.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.teamProject.service.MemberService;
import com.spring.teamProject.service.ReservationService;
import com.spring.teamProject.service.StoreService;
import com.spring.teamProject.service.WaitingService;
import com.spring.teamProject.vo.MemberVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.UserDetailsVO;
import com.spring.teamProject.vo.WaitingVO;

@Controller
@RequestMapping("/owner")
public class OwnerController {

	private static final Logger logger = LoggerFactory.getLogger(OwnerController.class);

    @Autowired
    private MemberService memberService;

    @Autowired
    private StoreService storeService; // 가게 정보 조회를 위해 추가

    @Autowired
    private ReservationService reservationService; // 예약 서비스

    @Autowired
    private WaitingService waitingService; // 웨이팅 서비스

    /**
     * 점주 대시보드의 메인 페이지를 보여줍니다.
     * @throws Exception
     */
    @GetMapping("/dashboard")
    public String dashboard(@AuthenticationPrincipal Object principal, Model model) throws Exception {
        MemberVO memberInfo = getMemberInfoFromPrincipal(principal);
        if (memberInfo == null) {
            return "redirect:/member/login";
        }

        List<StoreVO> stores = storeService.getStoresByOwnerId(memberInfo.getMemberId());
        Map<Long, Long> reservationCounts = new HashMap<>();
        Map<Long, Long> waitingCounts = new HashMap<>();

        Map<Long, Long> todayConfirmedCounts = new HashMap<>();
        Map<Long, Long> totalConfirmedCounts = new HashMap<>();

        for (StoreVO store : stores) {
            try {
                // long reservationCount = reservationService.getReservationCountByStoreId(store.getStoreId());

                long waitingCount = waitingService.getWaitingCountByStoreId(store.getStoreId());

                long todayConfirmedCount = reservationService.getTodaysConfirmedReservationCount(store.getStoreId());
                long totalConfirmedCount = reservationService.getTotalConfirmedReservationCount(store.getStoreId());

                // ⭐ 이 부분이 문제입니다. `reservationCount` 변수 대신 `todayConfirmedCount`를 사용하도록 수정하세요.
                reservationCounts.put(store.getStoreId(), todayConfirmedCount);
                waitingCounts.put(store.getStoreId(), waitingCount);

                todayConfirmedCounts.put(store.getStoreId(), todayConfirmedCount);
                totalConfirmedCounts.put(store.getStoreId(), totalConfirmedCount);

                //System.out.println("매장 ID " + store.getStoreId() + "의 오늘 확정 건수: " + todayConfirmedCount);
                //System.out.println("매장 ID " + store.getStoreId() + "의 총 확정 건수: " + totalConfirmedCount);

            } catch (Exception e) {
                logger.error("매장 ID {}의 확정된 예약 카운트 조회 중 오류 발생: {}", store.getStoreId(), e.getMessage());

                reservationCounts.put(store.getStoreId(), 0L);
                waitingCounts.put(store.getStoreId(), 0L);
                todayConfirmedCounts.put(store.getStoreId(), 0L);
                totalConfirmedCounts.put(store.getStoreId(), 0L);
            }
        }

        model.addAttribute("stores", stores);
        model.addAttribute("reservationCounts", reservationCounts);
        model.addAttribute("waitingCounts", waitingCounts);

        model.addAttribute("todayConfirmedCounts", todayConfirmedCounts);
        model.addAttribute("totalConfirmedCounts", totalConfirmedCounts);

        model.addAttribute("body", "owner/owner_dashboard.jsp");
        return "owner/owner_layout";
    }

    // ✨ --- [1. 신규] 프로필 수정 페이지를 보여주는 메소드 추가 --- ✨
    @GetMapping("/edit-profile")
    public String editProfileForm(@AuthenticationPrincipal Object principal, Model model) {
        MemberVO memberInfo = getMemberInfoFromPrincipal(principal);
        if (memberInfo == null) {
            return "redirect:/member/login";
        }
        model.addAttribute("memberInfo", memberInfo);
        model.addAttribute("body", "owner/owner_edit_profile.jsp"); // 점주 전용 수정 페이지
        return "owner/owner_layout";
    }

    // ✨ --- [2. 신규] 프로필 수정을 처리하는 메소드 추가 --- ✨
    @PostMapping("/edit-profile")
    public String editProfile(MemberVO memberVO, @AuthenticationPrincipal Object principal, RedirectAttributes redirectAttributes) {
        MemberVO currentMember = getMemberInfoFromPrincipal(principal);
        if (currentMember == null) {
            return "redirect:/member/login";
        }

        memberVO.setMemberId(currentMember.getMemberId());

        try {
            boolean isSuccess = memberService.updateMember(memberVO);

            if (isSuccess) {
                redirectAttributes.addFlashAttribute("msg", "프로필이 성공적으로 수정되었습니다.");

                // 세션 갱신 로직
                MemberVO updatedMember = memberService.findById(currentMember.getMemberId());
                Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
                UserDetailsVO newPrincipal = new UserDetailsVO(updatedMember);
                Authentication newAuth = new UsernamePasswordAuthenticationToken(newPrincipal, authentication.getCredentials(), newPrincipal.getAuthorities());
                SecurityContextHolder.getContext().setAuthentication(newAuth);

                return "redirect:/owner/dashboard"; // 수정 완료 후 대시보드로 이동
            } else {
                redirectAttributes.addFlashAttribute("error", "현재 비밀번호가 일치하지 않습니다.");
                return "redirect:/owner/edit-profile";
            }
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/owner/edit-profile";
        }
    }

    // ✨ --- [3. 신규] 로그인한 사용자 정보를 가져오는 헬퍼 메소드 추가 --- ✨
    private MemberVO getMemberInfoFromPrincipal(Object principal) {
        if (principal instanceof UserDetailsVO) {
            return ((UserDetailsVO) principal).getMemberVO();
        } else if (principal instanceof OAuth2User) {
            String email = ((OAuth2User) principal).getAttribute("email");
            return memberService.findByEmail(email);
        }
        return null;
    }


 // --- 특정 매장의 예약 목록 조회 ---
    @GetMapping("/reservations/manage")
    public String manageReservations(
            @AuthenticationPrincipal Object principal,
            @RequestParam("storeId") Long storeId,
            Model model) {

        // TODO: 로그인한 점주가 해당 매장의 소유주인지 확인하는 로직 추가

        try {
            // 예외가 발생할 수 있는 코드를 try 블록 안에 넣습니다.
            List<ReservationVO> reservations = reservationService.getReservationsByStoreId(storeId);
            model.addAttribute("reservations", reservations);
            model.addAttribute("storeId", storeId);
        } catch (Exception e) {
            // 예외가 발생하면 이곳으로 이동하여 처리합니다.
            // 로그를 남겨서 어떤 오류인지 확인하는 것이 좋습니다.
            // 예시로 logger.error를 추가했습니다.
            // private static final Logger logger = LoggerFactory.getLogger(OwnerController.class); 를 클래스 상단에 추가해야 합니다.
            // logger.error("예약 목록 조회 중 오류 발생: {}", e.getMessage(), e);

            model.addAttribute("error", "예약 정보를 불러오는 중 오류가 발생했습니다.");
            // 오류 페이지 또는 대시보드 페이지로 리다이렉트할 수 있습니다.
            model.addAttribute("body", "common/error.jsp");
            return "owner/owner_layout";
        }

        model.addAttribute("body", "reservation/owner/manageBookingList.jsp");
        return "owner/owner_layout";
    }

    // --- [2. 신규] 특정 매장의 실시간 웨이팅 목록 조회 ---
    @GetMapping("/waitings/manage")
    public String manageWaitings(@AuthenticationPrincipal Object principal, @RequestParam("storeId") Long storeId, Model model) {
        // TODO: 로그인한 점주가 해당 매장의 소유주인지 확인하는 로직 추가

        List<WaitingVO> waitings = waitingService.getCurrentWaitings(storeId);
        model.addAttribute("waitings", waitings);
        model.addAttribute("storeId", storeId);
        model.addAttribute("body", "waiting/owner/currentWaitingList.jsp"); // 기존 JSP 재활용
        return "owner/owner_layout";
    }

    // --- [3. 신규] 예약 상태 업데이트 (API) ---
    // 기존 ReservationOwnerController의 POST /updateStatus 메서드 로직을 가져옵니다.
    @PostMapping("/reservations/updateStatus")
    public String updateReservationStatus(@RequestParam("reservationId") Long reservationId,
                                          @RequestParam("status") String status,
                                          @RequestParam("storeId") Long storeId,
                                          RedirectAttributes redirectAttributes) {
        try {
            reservationService.updateReservationStatus(reservationId, status);
            // 온도 변경 로직은 서비스 레이어에서 처리
            redirectAttributes.addFlashAttribute("message", "예약 상태가 성공적으로 업데이트되었습니다.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "예약 상태 업데이트 중 오류가 발생했습니다.");
        }
        return "redirect:/owner/reservations/manage?storeId=" + storeId;
    }

    // --- [4. 신규] 웨이팅 상태 업데이트 (API) ---
    // 기존 WaitingOwnerController의 POST /api/updateStatus 로직을 가져옵니다.
    @PostMapping("/waitings/updateStatus")
    @ResponseBody
    public ResponseEntity<?> updateWaitingStatus(@RequestBody Map<String, Object> payload) {
        // ... (기존 로직 그대로 복사)
        return null; // 기존 로직을 복사하여 반환
    }

    // --- [5. 신규] 레이아웃 에디터 페이지로 이동 ---
    @GetMapping("/store/layoutEditor")
    public String layoutEditor(@RequestParam("storeId") Long storeId, Model model) {
        // TODO: 로그인한 점주가 해당 매장의 소유주인지 확인하는 로직 추가

        model.addAttribute("storeId", storeId);
        model.addAttribute("body", "reservation/owner/layout_editor.jsp");
        return "owner/owner_layout";
    }

    @GetMapping("/api/realtimeWaitingCounts")
    @ResponseBody
    public Map<Long, Integer> getRealtimeWaitingCounts(@AuthenticationPrincipal UserDetailsVO userDetailsVO) {
        // 1. 로그인 점주 ID 확인
        if (userDetailsVO == null || !"OWNER".equals(userDetailsVO.getMemberVO().getRole())) {
            return new HashMap<>();
        }
        Long ownerId = (long) userDetailsVO.getMemberVO().getMemberId();

        Map<Long, Integer> waitingCounts = new HashMap<>();

        try {
            List<StoreVO> stores = storeService.getStoresByOwnerId(ownerId);

            for (StoreVO store : stores) {
                // 예외가 발생할 수 있는 메소드를 try 블록 내에 둡니다.
                int count = waitingService.getCurrentWaitingCount(store.getStoreId());
                waitingCounts.put(store.getStoreId(), count);
            }
        } catch (Exception e) {
            // 예외 발생 시 로그를 남기고 빈 Map을 반환하거나,
            // 사용자에게 에러를 알리는 다른 처리를 할 수 있습니다.
            logger.error("실시간 웨이팅 수를 가져오는 중 오류 발생: {}", e.getMessage(), e);
            // 또는 특정 HTTP 상태 코드를 가진 ResponseEntity를 반환할 수도 있습니다.
        }

        return waitingCounts;
    }


}
