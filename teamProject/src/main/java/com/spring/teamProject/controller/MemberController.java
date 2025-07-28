package com.spring.teamProject.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.teamProject.service.MemberService;
import com.spring.teamProject.vo.MemberVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/member")
public class MemberController {

    @Autowired
    private MemberService memberService;

    // --- 회원가입 유형 선택 페이지 ---
    @GetMapping("/join-select")
    public String joinSelectForm(Model model) {
        model.addAttribute("body", "member/join_select.jsp");
        return "layout/layout";
    }

    // --- 로그인 페이지 보여주기 (GET) ---
    @GetMapping("/login")
    public String loginForm(Model model) {
        model.addAttribute("body", "member/login.jsp");
        return "layout/layout";
    }

    // --- 로그아웃 ---
    @GetMapping("/logout")
    public String logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        return "redirect:/";
    }

    // --- 일반 & 가맹점주 회원가입 폼 ---
    @GetMapping("/join")
    public String joinForm(@RequestParam("role") String role, Model model) {
        if ("OWNER".equals(role)) {
            model.addAttribute("body", "member/join_owner.jsp");
        } else {
            model.addAttribute("body", "member/join_user.jsp");
        }
        return "layout/layout";
    }

    // --- 일반 & 가맹점주 회원가입 처리 ---
    @PostMapping("/join")
    public String join(MemberVO memberVO, RedirectAttributes redirectAttributes) {
        try {
            memberService.join(memberVO);
            redirectAttributes.addFlashAttribute("msg", "회원가입이 완료되었습니다. 로그인해주세요.");
            return "redirect:/member/login";
        } catch (DuplicateKeyException e) {
            // (신규) DB에 중복된 값이 있을 경우 예외 처리
            redirectAttributes.addFlashAttribute("error", "이미 사용 중인 아이디, 이메일 또는 전화번호입니다.");
            // 가입 폼으로 다시 돌려보냄 (사용자가 입력한 role 값을 유지)
            return "redirect:/member/join?role=" + memberVO.getRole();
        }
    }
    
    // --- 소셜 로그인 후 추가 정보 입력 페이지 ---
    @GetMapping("/join-social")
    public String joinSocialForm(Model model, HttpSession session) {
        Object socialUserInfo = session.getAttribute("socialUserInfo");
        if (socialUserInfo == null) {
            return "redirect:/"; // 비정상 접근 시 메인으로
        }
        model.addAttribute("socialUserInfo", socialUserInfo);
        model.addAttribute("body", "member/join-social.jsp");
        return "layout/layout";
    }

    // --- 소셜 회원가입 최종 처리 ---
    @PostMapping("/join-social")
    public String joinSocial(MemberVO memberVO, HttpSession session, RedirectAttributes redirectAttributes) {
        Map<String, Object> socialUserInfo = (Map<String, Object>) session.getAttribute("socialUserInfo");
        
        if (socialUserInfo != null) {
            memberVO.setSocialProvider("GOOGLE");
            memberVO.setSocialId((String) socialUserInfo.get("sub"));
            memberVO.setEmail((String) socialUserInfo.get("email"));
            memberVO.setMemberName((String) socialUserInfo.get("name"));
            memberVO.setRole("USER");

            try {
                memberService.joinSocial(memberVO);
                session.removeAttribute("socialUserInfo");
                redirectAttributes.addFlashAttribute("msg", "회원가입이 완료되었습니다. 다시 로그인해주세요.");
                return "redirect:/member/login";
            } catch (DuplicateKeyException e) {
                // (신규) DB에 중복된 값이 있을 경우 예외 처리
                session.setAttribute("socialUserInfo", socialUserInfo); // 세션 정보 유지
                redirectAttributes.addFlashAttribute("error", "이미 가입된 전화번호 또는 이메일입니다.");
                return "redirect:/member/join-social";
            }
        }
        return "redirect:/member/login";
    }
}
