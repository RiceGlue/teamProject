package com.spring.teamProject.controller;

import org.springframework.beans.factory.annotation.Autowired;
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

    // --- (삭제) @PostMapping("/login") 메소드는 스프링 시큐리티가 처리하므로 삭제합니다. ---

    // --- 로그아웃 ---
    @GetMapping("/logout")
    public String logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        return "redirect:/";
    }

    // --- 회원가입 폼 ---
    @GetMapping("/join")
    public String joinForm(@RequestParam("role") String role, Model model) {
        if ("OWNER".equals(role)) {
            model.addAttribute("body", "member/join_owner.jsp");
        } else {
            model.addAttribute("body", "member/join_user.jsp");
        }
        return "layout/layout";
    }

    // --- 회원가입 처리 ---
    @PostMapping("/join")
    public String join(MemberVO memberVO, RedirectAttributes redirectAttributes) {
        memberService.join(memberVO);
        redirectAttributes.addFlashAttribute("msg", "회원가입이 완료되었습니다. 로그인해주세요.");
        return "redirect:/member/login";
    }
}
