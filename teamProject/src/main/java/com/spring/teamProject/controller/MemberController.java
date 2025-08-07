package com.spring.teamProject.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.teamProject.service.MemberService;
import com.spring.teamProject.service.RecaptchaService; // RecaptchaService import
import com.spring.teamProject.vo.MemberVO;
import com.spring.teamProject.vo.UserDetailsVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/member")
public class MemberController {

    @Autowired
    private MemberService memberService;

    // RecaptchaService 주입
    @Autowired
    private RecaptchaService recaptchaService;

    // application.properties에서 사이트 키 값을 주입받습니다.
    @Value("${google.recaptcha.site-key}")
    private String recaptchaSiteKey;

    // --- (신규) 아이디 중복 확인 API ---
    @PostMapping("/check-id")
    @ResponseBody   // 이 메소드는 뷰(JSP)가 아닌, 데이터(JSON)를 반환합니다.
    public Map<String, Boolean> checkIdDuplicate(@RequestParam("loginId") String loginId) {
        Map<String, Boolean> response = new HashMap<>();
        // 아이디가 존재하면 count는 1 이상, 존재하지 않으면 0
        int count = memberService.checkIdDuplicate(loginId);
        // isDuplicate 키에 중복 여부(true/false)를 담아 반환
        response.put("isDuplicate", count > 0);
        return response;
    }

    // --- 회원가입 및 로그인/로그아웃 관련 메소드 ---

    @GetMapping("/join-select")
    public String joinSelectForm(Model model) {
        model.addAttribute("body", "member/join_select.jsp");
        return "layout/layout";
    }

    @GetMapping("/login")
    public String loginForm(Model model) {
        model.addAttribute("body", "member/login.jsp");
        return "layout/layout";
    }
    
    @GetMapping("/logout")
    public String logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        return "redirect:/";
    }

    // 회원가입 폼을 보여줄 때, reCAPTCHA 사이트 키를 모델에 담아 전달합니다.
    @GetMapping("/join")
    public String joinForm(@RequestParam("role") String role, Model model) {
        model.addAttribute("recaptchaSiteKey", recaptchaSiteKey); // 사이트 키 추가
        if ("OWNER".equals(role)) {
            model.addAttribute("body", "member/join_owner.jsp");
        } else {
            model.addAttribute("body", "member/join_user.jsp");
        }
        return "layout/layout";
    }

    // 일반 & 가맹점주 회원가입 처리에 reCAPTCHA 검증 추가
    @PostMapping("/join")
    public String join(MemberVO memberVO, 
                       @RequestParam("g-recaptcha-response") String recaptchaResponse,
                       RedirectAttributes redirectAttributes) {
        
        boolean isRecaptchaVerified = recaptchaService.verifyRecaptcha(recaptchaResponse);
        if (!isRecaptchaVerified) {
            redirectAttributes.addFlashAttribute("error", "reCAPTCHA 인증에 실패했습니다. 다시 시도해주세요.");
            redirectAttributes.addFlashAttribute("memberVO", memberVO); // 입력 데이터 유지
            return "redirect:/member/join?role=" + memberVO.getRole();
        }

        try {
            memberService.join(memberVO);
            redirectAttributes.addFlashAttribute("msg", "회원가입이 완료되었습니다. 로그인해주세요.");
            return "redirect:/member/login";
        } catch (DuplicateKeyException e) {
            redirectAttributes.addFlashAttribute("error", "이미 사용 중인 아이디, 이메일 또는 전화번호입니다.");
            redirectAttributes.addFlashAttribute("memberVO", memberVO); // 입력 데이터 유지
            return "redirect:/member/join?role=" + memberVO.getRole();
        }
    }
    
    // 소셜 회원가입 폼을 보여줄 때도, reCAPTCHA 사이트 키를 모델에 담아 전달합니다.
    @GetMapping("/join_social")
    public String joinSocialForm(Model model, HttpSession session) {
        Object socialUserInfo = session.getAttribute("socialUserInfo");
        if (socialUserInfo == null) {
            return "redirect:/";
        }
        model.addAttribute("recaptchaSiteKey", recaptchaSiteKey); // 사이트 키 추가
        model.addAttribute("socialUserInfo", socialUserInfo);
        model.addAttribute("body", "member/join_social.jsp");
        return "layout/layout";
    }

    // 소셜 회원가입 최종 처리에 reCAPTCHA 검증 추가
    @PostMapping("/join_social")
    public String joinSocial(MemberVO memberVO, 
                             @RequestParam("g-recaptcha-response") String recaptchaResponse,
                             HttpSession session, 
                             RedirectAttributes redirectAttributes) {
        
        boolean isRecaptchaVerified = recaptchaService.verifyRecaptcha(recaptchaResponse);
        if (!isRecaptchaVerified) {
            redirectAttributes.addFlashAttribute("error", "reCAPTCHA 인증에 실패했습니다. 다시 시도해주세요.");
            // 세션 정보를 유지해야 폼이 다시 제대로 보입니다.
            session.setAttribute("socialUserInfo", session.getAttribute("socialUserInfo"));
            return "redirect:/member/join_social";
        }
        
        Map<String, Object> socialUserInfo = (Map<String, Object>) session.getAttribute("socialUserInfo");
        
        if (socialUserInfo != null) {
            memberVO.setSocialProvider("GOOGLE");
            memberVO.setSocialId((String) socialUserInfo.get("sub"));
            memberVO.setEmail((String) socialUserInfo.get("email"));
            memberVO.setRole("USER");

            try {
                memberService.joinSocial(memberVO);
                session.removeAttribute("socialUserInfo");
                redirectAttributes.addFlashAttribute("msg", "회원가입이 완료되었습니다. 다시 로그인해주세요.");
                return "redirect:/member/login";
            } catch (DuplicateKeyException e) {
                session.setAttribute("socialUserInfo", socialUserInfo);
                redirectAttributes.addFlashAttribute("error", "이미 가입된 전화번호 또는 이메일입니다.");
                return "redirect:/member/join_social";
            }
        }
        return "redirect:/member/login";
    }

    // --- 마이페이지, 프로필 수정, 회원 탈퇴 ---
    
    @GetMapping("/mypage")
    public String mypage(@AuthenticationPrincipal Object principal, Model model) {
        MemberVO memberInfo = null;

        if (principal instanceof UserDetailsVO) {
            // Case 1: 일반 로그인 사용자
            memberInfo = ((UserDetailsVO) principal).getMemberVO();
        } else if (principal instanceof OAuth2User) {
            // Case 2: 소셜 로그인 사용자
            OAuth2User oauth2User = (OAuth2User) principal;
            String email = oauth2User.getAttribute("email");
            // DB에서 최신 회원 정보를 이메일로 조회합니다.
            memberInfo = memberService.findByEmail(email);
        }

        if (memberInfo == null) {
            // 예외 처리: 로그인 정보가 없거나 DB에서 회원을 찾지 못한 경우
            return "redirect:/member/login";
        }

        model.addAttribute("memberInfo", memberInfo);
        model.addAttribute("body", "member/mypage.jsp");
        return "layout/layout";
    }

    @GetMapping("/edit-profile")
    public String editProfileForm(@AuthenticationPrincipal Object principal, Model model) {
        MemberVO memberInfo = null;

        if (principal instanceof UserDetailsVO) {
            memberInfo = ((UserDetailsVO) principal).getMemberVO();
        } else if (principal instanceof OAuth2User) {
            OAuth2User oauth2User = (OAuth2User) principal;
            String email = oauth2User.getAttribute("email");
            memberInfo = memberService.findByEmail(email);
        }

        if (memberInfo == null) {
            return "redirect:/member/login";
        }
        
        model.addAttribute("memberInfo", memberInfo);
        model.addAttribute("body", "member/edit_profile.jsp");
        return "layout/layout";
    }

    @PostMapping("/edit-profile")
    public String editProfile(MemberVO memberVO, @AuthenticationPrincipal Object principal, RedirectAttributes redirectAttributes) {
        long currentMemberId = 0;
        String currentEmail = null; // (수정) 이메일 조회를 위해 변수 추가
        
        if (principal instanceof UserDetailsVO) {
            UserDetailsVO userDetails = (UserDetailsVO) principal;
            currentMemberId = userDetails.getMemberVO().getMemberId();
            currentEmail = userDetails.getMemberVO().getEmail();
        } else if (principal instanceof OAuth2User) {
            OAuth2User oauth2User = (OAuth2User) principal;
            String email = oauth2User.getAttribute("email");
            MemberVO currentMember = memberService.findByEmail(email);
            if (currentMember != null) {
                currentMemberId = currentMember.getMemberId();
                currentEmail = currentMember.getEmail();
            }
        }

        if (currentMemberId == 0) {
            return "redirect:/member/login";
        }
        
        memberVO.setMemberId(currentMemberId);
        
        boolean isSuccess = memberService.updateMember(memberVO);
        
        if (isSuccess) {
            redirectAttributes.addFlashAttribute("msg", "프로필이 성공적으로 수정되었습니다.");
            
            // --- ? 여기가 핵심 수정 부분입니다 ? ---
            // 1. DB에서 최신 회원 정보를 다시 조회합니다. (수정된 이메일로 조회)
            MemberVO updatedMember = memberService.findByEmail(memberVO.getEmail());
            
            // 2. 현재 사용자의 인증 정보를 가져옵니다.
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            
            // 3. 새로운 인증 정보를 생성합니다.
            UserDetailsVO newPrincipal = new UserDetailsVO(updatedMember);
            Authentication newAuth = new UsernamePasswordAuthenticationToken(newPrincipal, authentication.getCredentials(), newPrincipal.getAuthorities());
            
            // 4. SecurityContext에 새로운 인증 정보를 설정하여 세션을 갱신합니다.
            SecurityContextHolder.getContext().setAuthentication(newAuth);
            
            return "redirect:/member/mypage";
        } else {
            redirectAttributes.addFlashAttribute("error", "현재 비밀번호가 일치하지 않거나, 정보 수정에 실패했습니다.");
            return "redirect:/member/edit-profile";
        }
    }
    
    @PostMapping("/withdraw")
    public String withdraw(@AuthenticationPrincipal Object principal, HttpServletRequest request) {
        long memberId = 0;
        
        if (principal instanceof UserDetailsVO) {
            memberId = ((UserDetailsVO) principal).getMemberVO().getMemberId();
        } else if (principal instanceof OAuth2User) {
            OAuth2User oauth2User = (OAuth2User) principal;
            String email = oauth2User.getAttribute("email");
            MemberVO currentMember = memberService.findByEmail(email);
            if (currentMember != null) {
                memberId = currentMember.getMemberId();
            }
        }
        
        if (memberId != 0) {
            memberService.deleteMember(memberId);
        }
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        return "redirect:/";
    }
}