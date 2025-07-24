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
@RequestMapping("/member") //member로 시작하는 요청을 이 컨트롤러가 모두 처리 함
public class MemberController {
	
	@Autowired
	private MemberService memberService;
	
	//회원가입 유형 선택
	@GetMapping("/join_select")
	public String joinSelectForm(Model model) {
		model.addAttribute("body", "member/join_select.jsp");
		return "layout/layout";
	}
	
	
	//로그인
	@GetMapping("/login")
	public String loginForm(Model model) {
		model.addAttribute("body", "member/login.jsp");
		return "layout/layout";
	}
	
	@PostMapping("/login")
	public String login(MemberVO memberVO, HttpServletRequest request, RedirectAttributes redirectAttributes) {
		MemberVO loginMember = memberService.login(memberVO);
		
		if (loginMember != null) {
			//로그인 성공
			HttpSession session = request.getSession();
			session.setAttribute("loginMember", loginMember);
			return "redirect:/";				//메인 페이지로 리다이렉트
		} else {
			//로그인 실패
			redirectAttributes.addFlashAttribute("msg", "아이디 또는 비밀번호가 일치하지 않습니다");
			return "redirect:/member/login";	//로그인 페이지로 리다이렉트
		}
	}
	
	
	//로그아웃
	@GetMapping("/logout")
	public String logout(HttpServletRequest request) {
		HttpSession session = request.getSession(false);
		if (session != null) {
			session.invalidate();			//세션 무효화
		}
		return "redirect:/";
	}
	
	//회원가입
	@GetMapping("/join")
	public String joinForm(@RequestParam("role") String role, Model model) {
		if ("OWNER".equals(role)) {
			model.addAttribute("body", "member/join_owner.jsp");
		} else {
			model.addAttribute("body", "member/join_user.jsp");
		}
		return "layout/layout";
	}
	
	@PostMapping("/join")
	public String join(MemberVO memberVO, RedirectAttributes redirectAttributes) {
		memberService.join(memberVO);
		redirectAttributes.addFlashAttribute("msg", "회원가입이 완료되었습니다. 로그인해주세요");
		return "redirect:/member/login";	//회원가입 후 로그인 페이지로
	}
	
	// 회원정보 수정과 탈퇴는 나중에 추가 예정
}
