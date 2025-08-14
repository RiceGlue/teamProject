package com.spring.teamProject.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
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
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.teamProject.service.MemberService;
import com.spring.teamProject.service.RecaptchaService;
import com.spring.teamProject.vo.MemberVO;
import com.spring.teamProject.vo.SocialAccountVO;
import com.spring.teamProject.vo.UserDetailsVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/member")
public class MemberController {

    @Autowired
    private MemberService memberService;

    @Autowired
    private RecaptchaService recaptchaService;

    @Value("${google.recaptcha.site-key}")
    private String recaptchaSiteKey;

    // --- (신규) 아이디 중복 확인 API ---
    @PostMapping("/check-id")
    @ResponseBody
    public Map<String, Boolean> checkIdDuplicate(@RequestParam("loginId") String loginId) {
        Map<String, Boolean> response = new HashMap<>();
        int count = memberService.checkIdDuplicate(loginId);
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
        model.addAttribute("recaptchaSiteKey", recaptchaSiteKey);
        if ("OWNER".equals(role)) {
            model.addAttribute("body", "member/join_owner.jsp");
        } else {
            model.addAttribute("body", "member/join_user.jsp");
        }
        return "layout/layout";
    }

    // 일반 회원가입 처리
    @PostMapping("/join")
    public String join(MemberVO memberVO, 
                       @RequestParam("g-recaptcha-response") String recaptchaResponse,
                       RedirectAttributes redirectAttributes) {
        
        boolean isRecaptchaVerified = recaptchaService.verifyRecaptcha(recaptchaResponse);
        if (!isRecaptchaVerified) {
            redirectAttributes.addFlashAttribute("error", "reCAPTCHA 인증에 실패했습니다. 다시 시도해주세요.");
            redirectAttributes.addFlashAttribute("memberVO", memberVO);
            return "redirect:/member/join?role=" + memberVO.getRole();
        }

        try {
            memberService.join(memberVO);
            redirectAttributes.addFlashAttribute("msg", "회원가입이 완료되었습니다. 로그인해주세요.");
            return "redirect:/member/login";
        } catch (IllegalArgumentException e) { // ? --- [핵심 수정] --- ?
            redirectAttributes.addFlashAttribute("error", e.getMessage()); // 서비스에서 던진 메시지 사용
            redirectAttributes.addFlashAttribute("memberVO", memberVO);
            return "redirect:/member/join?role=" + memberVO.getRole();
        } catch (DuplicateKeyException e) {
            redirectAttributes.addFlashAttribute("error", "이미 사용 중인 아이디, 이메일 또는 전화번호입니다.");
            redirectAttributes.addFlashAttribute("memberVO", memberVO);
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
        model.addAttribute("recaptchaSiteKey", recaptchaSiteKey);
        model.addAttribute("socialUserInfo", socialUserInfo);
        model.addAttribute("body", "member/join_social.jsp");
        return "layout/layout";
    }

    // [수정] 소셜 회원가입 최종 처리 로직 변경
    @PostMapping("/join_social")
    public String joinSocial(MemberVO memberVO, 
                             @RequestParam("g-recaptcha-response") String recaptchaResponse,
                             HttpSession session, 
                             RedirectAttributes redirectAttributes) {
        
        boolean isRecaptchaVerified = recaptchaService.verifyRecaptcha(recaptchaResponse);
        if (!isRecaptchaVerified) {
            redirectAttributes.addFlashAttribute("error", "reCAPTCHA 인증에 실패했습니다. 다시 시도해주세요.");
            session.setAttribute("socialUserInfo", session.getAttribute("socialUserInfo"));
            return "redirect:/member/join_social";
        }
        
        Map<String, Object> socialUserInfo = (Map<String, Object>) session.getAttribute("socialUserInfo");
        
        if (socialUserInfo != null) {
        	// 1. memberVO에 기본 정보 설정 (비밀번호, 아이디는 없음)
            memberVO.setEmail((String) socialUserInfo.get("email"));
            memberVO.setRole("USER");

            // 2. SocialAccountVO 생성 및 정보 설정
            SocialAccountVO socialAccount = new SocialAccountVO();
            socialAccount.setProvider("GOOGLE");
            socialAccount.setSocialId((String) socialUserInfo.get("sub"));
            
            // 3. MemberVO에 소셜 계정 리스트를 담아 전달
            List<SocialAccountVO> socialAccounts = new ArrayList<>();
            socialAccounts.add(socialAccount);
            memberVO.setSocialAccounts(socialAccounts);

            try {
                // 4. 통합된 join 서비스 호출
                memberService.join(memberVO);
                session.removeAttribute("socialUserInfo");
                redirectAttributes.addFlashAttribute("msg", "회원가입이 완료되었습니다. 다시 로그인해주세요.");
                return "redirect:/member/login";
            } catch (IllegalArgumentException e) { // ? --- [핵심 수정] --- ?
                session.setAttribute("socialUserInfo", socialUserInfo);
                redirectAttributes.addFlashAttribute("error", e.getMessage());
                return "redirect:/member/join_social";
            } catch (DuplicateKeyException e) {
                session.setAttribute("socialUserInfo", socialUserInfo);
                redirectAttributes.addFlashAttribute("error", "이미 가입된 전화번호 또는 이메일입니다.");
                return "redirect:/member/join_social";
            }
        }
        return "redirect:/member/login";
    }

    // --- 마이페이지, 프로필 수정, 회원 탈퇴 ---
    
    /**
     * [수정] 마이페이지 요청 시, 사용자의 역할(Role)에 따라 다른 뷰를 반환합니다.
     */
    @GetMapping("/mypage")
    public String mypage(@AuthenticationPrincipal Object principal, Model model) {
        MemberVO memberInfo = getMemberInfoFromPrincipal(principal);
        if (memberInfo == null) {
            return "redirect:/member/login";
        }

        String role = memberInfo.getRole();

        // ? --- 여기가 핵심 수정 부분입니다 --- ?
        if ("ADMIN".equals(role)) {
            // 관리자의 경우, AdminController의 dashboard로 리다이렉트합니다.
            return "redirect:/admin/dashboard";
        } else if ("OWNER".equals(role)) {
            // TODO: 점주 대시보드 컨트롤러 생성 필요
            // return "redirect:/owner/dashboard"; 
            model.addAttribute("memberInfo", memberInfo);
            model.addAttribute("body", "member/mypage.jsp"); // 임시로 일반 마이페이지 표시
            return "layout/layout";
        }
        else {
            // 일반 사용자의 경우 기존 마이페이지를 보여줍니다.
            model.addAttribute("memberInfo", memberInfo);
            model.addAttribute("body", "member/mypage.jsp");
            return "layout/layout";
        }
    }

    @GetMapping("/edit-profile")
    public String editProfileForm(@AuthenticationPrincipal Object principal, Model model) {
        MemberVO memberInfo = getMemberInfoFromPrincipal(principal);
        if (memberInfo == null) {
            return "redirect:/member/login";
        }
        model.addAttribute("memberInfo", memberInfo);
        model.addAttribute("body", "member/edit_profile.jsp");
        return "layout/layout";
    }

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
                
                return "redirect:/member/mypage";
            } else {
                redirectAttributes.addFlashAttribute("error", "현재 비밀번호가 일치하지 않습니다.");
                return "redirect:/member/edit-profile";
            }
        } catch (IllegalArgumentException e) { // ? --- [핵심 수정] --- ?
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/member/edit-profile";
        }
    }
    
    /**
     * [신규] 소셜 계정 연동을 시작하기 전, 세션에 '연동 요청' 표식을 남기는 준비 단계
     * @param provider 소셜 서비스 제공자 (예: google)
     * @param session 현재 HttpSession
     * @return 소셜 서비스의 인증 페이지로 리다이렉트
     */
    @GetMapping("/prepare-link/{provider}")
    public String prepareLinkSocial(@PathVariable String provider, HttpSession session) {
        session.setAttribute("socialLinkRequest", true);
        return "redirect:/oauth2/authorization/" + provider;
    }

    // [신규] 소셜 계정 연동 해제 요청 처리
    @PostMapping("/unlink-social")
    public String unlinkSocial(@RequestParam("provider") String provider, 
                               @AuthenticationPrincipal Object principal, 
                               RedirectAttributes redirectAttributes) {
        
        MemberVO currentMember = getMemberInfoFromPrincipal(principal);
        if (currentMember == null) {
            return "redirect:/member/login";
        }

        boolean isSuccess = memberService.unlinkSocialAccount(currentMember.getMemberId(), provider);

        if (isSuccess) {
            redirectAttributes.addFlashAttribute("msg", provider + " 계정 연동이 해제되었습니다.");
            
            // 중요: 세션 정보 갱신
            MemberVO updatedMember = memberService.findById(currentMember.getMemberId());
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            UserDetailsVO newPrincipal = new UserDetailsVO(updatedMember);
            Authentication newAuth = new UsernamePasswordAuthenticationToken(newPrincipal, authentication.getCredentials(), newPrincipal.getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(newAuth);
        } else {
            redirectAttributes.addFlashAttribute("error", "마지막 로그인 수단은 연동 해제할 수 없습니다. 먼저 비밀번호를 설정해주세요.");
        }

        return "redirect:/member/edit-profile";
    }

    // [수정] 회원 탈퇴 (논리적 삭제)
    @PostMapping("/withdraw")
    public String withdraw(@AuthenticationPrincipal Object principal, HttpServletRequest request) {
        MemberVO currentMember = getMemberInfoFromPrincipal(principal);
        
        if (currentMember != null) {
            memberService.deactivateMember(currentMember.getMemberId());
        }
        
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        return "redirect:/";
    }

    // [신규] Principal 객체에서 MemberVO를 안전하게 가져오는 헬퍼 메소드
    private MemberVO getMemberInfoFromPrincipal(Object principal) {
        if (principal instanceof UserDetailsVO) {
            return ((UserDetailsVO) principal).getMemberVO();
        } else if (principal instanceof OAuth2User) {
            String email = ((OAuth2User) principal).getAttribute("email");
            return memberService.findByEmail(email);
        }
        return null;
    }
}