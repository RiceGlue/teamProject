package com.spring.teamProject.controller;

import com.spring.teamProject.service.MemberService; // MemberService를 import합니다.
import com.spring.teamProject.service.ReservationService;
import com.spring.teamProject.vo.MemberVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.UserDetailsVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import jakarta.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/mypage")
public class MyPageController {

    @Autowired
    private ReservationService reservationService;

    // [신규] MemberService 주입
    @Autowired
    private MemberService memberService;

    /**
     * [수정] 마이페이지 요청 시, 사용자의 역할(Role)에 따라 다른 뷰를 반환합니다.
     * @AuthenticationPrincipal을 통해 현재 로그인한 사용자 정보를 가져옵니다.
     * @param principal Spring Security의 Principal 객체 (UserDetailsVO 또는 OAuth2User)
     * @param model 뷰로 데이터를 전달하는 모델
     * @return 뷰 경로
     */
    @GetMapping
    public String mypage(@AuthenticationPrincipal Object principal, Model model, HttpSession session) {
        MemberVO memberInfo = getMemberInfoFromPrincipal(principal);
        if (memberInfo == null) {
            return "redirect:/member/login";
        }

        String role = memberInfo.getRole();
        session.setAttribute("memberId", memberInfo.getMemberId()); // 세션에 memberId 저장 (테스트용)

        if ("ADMIN".equals(role)) {
            // 관리자의 경우, AdminController의 dashboard로 리다이렉트합니다.
            return "redirect:/admin/dashboard";
        } else if ("OWNER".equals(role)) {
            // TODO: 점주 대시보드 컨트롤러 및 뷰 생성 필요
            model.addAttribute("memberInfo", memberInfo);
            model.addAttribute("body", "member/mypage.jsp"); // 임시로 일반 마이페이지 표시
            return "layout/layout";
        } else { // USER
            // 일반 사용자의 경우 기존 마이페이지를 보여줍니다.
            model.addAttribute("memberInfo", memberInfo);

            // TODO: ReservationService에 실제 메서드를 구현해야 합니다.
            List<ReservationVO> myReservations = reservationService.getReservationsByMemberId(memberInfo.getMemberId());
            model.addAttribute("myReservations", myReservations);

            model.addAttribute("body", "member/mypage.jsp");
            return "layout/layout";
        }
    }

    /**
     * [신규] Principal 객체에서 MemberVO를 안전하게 가져오는 헬퍼 메소드
     */
    private MemberVO getMemberInfoFromPrincipal(Object principal) {
        if (principal instanceof UserDetailsVO) {
            return ((UserDetailsVO) principal).getMemberVO();
        } else if (principal instanceof OAuth2User) {
            // [수정] OAuth2User의 이메일을 기반으로 MemberService를 통해 MemberVO를 조회합니다.
            String email = ((OAuth2User) principal).getAttribute("email");
            return memberService.findByEmail(email);
        }
        return null;
    }
}
