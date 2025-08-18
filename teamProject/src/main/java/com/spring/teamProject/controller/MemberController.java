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
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;
import org.springframework.security.web.savedrequest.RequestCache;
import org.springframework.security.web.savedrequest.SavedRequest;
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
import jakarta.servlet.http.HttpServletResponse;
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

    // =================================================================
    // == 회원가입 / 로그인 / 로그아웃 (Join / Login / Logout)
    // =================================================================

    @PostMapping("/check-id")
    @ResponseBody
    public Map<String, Boolean> checkIdDuplicate(@RequestParam("loginId") String loginId) {
        Map<String, Boolean> response = new HashMap<>();
        int count = memberService.checkIdDuplicate(loginId);
        response.put("isDuplicate", count > 0);
        return response;
    }

    @GetMapping("/join-select")
    public String joinSelectForm(Model model) {
        model.addAttribute("body", "member/join_select.jsp");
        return "layout/layout";
    }

    @GetMapping("/login")
    public String loginForm(Model model, HttpServletRequest request, HttpServletResponse response) {
        // Spring Security가 저장한 '원래 가려던 페이지' 정보를 가져옵니다.
        RequestCache requestCache = new HttpSessionRequestCache();
        SavedRequest savedRequest = requestCache.getRequest(request, response);

        // '원래 가려던 페이지' 정보가 있다면, 로그인 유도 메시지를 모델에 추가합니다.
        if (savedRequest != null) {
            model.addAttribute("loginRedirectMessage", "로그인이 필요한 서비스입니다. 로그인 후 이전 페이지로 이동합니다.");
        }
        
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
        } catch (DuplicateKeyException e) {
            redirectAttributes.addFlashAttribute("error", "이미 사용 중인 아이디, 이메일 또는 전화번호입니다.");
            redirectAttributes.addFlashAttribute("memberVO", memberVO);
            return "redirect:/member/join?role=" + memberVO.getRole();
        }
    }

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
            memberVO.setEmail((String) socialUserInfo.get("email"));
            memberVO.setRole("USER");

            SocialAccountVO socialAccount = new SocialAccountVO();
            socialAccount.setProvider("GOOGLE");
            socialAccount.setSocialId((String) socialUserInfo.get("sub"));

            List<SocialAccountVO> socialAccounts = new ArrayList<>();
            socialAccounts.add(socialAccount);
            memberVO.setSocialAccounts(socialAccounts);

            try {
                memberService.join(memberVO);
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

    // =================================================================
    // == 마이페이지 (MyPage) - USER, OWNER, ADMIN 공통 진입점
    // =================================================================
    
    @GetMapping("/mypage")
    public String mypage(@AuthenticationPrincipal Object principal, Model model) {
        MemberVO memberInfo = getMemberInfoFromPrincipal(principal);
        if (memberInfo == null) {
            return "redirect:/member/login";
        }

        String role = memberInfo.getRole();

        if ("ADMIN".equals(role)) {
            return "redirect:/admin/dashboard";
        } else if ("OWNER".equals(role)) {
            return "redirect:/owner/dashboard";
        } else { // USER
            model.addAttribute("memberInfo", memberInfo);
            // TODO: ReservationService에 실제 메서드를 구현해야 합니다.
            // List<ReservationVO> myReservations = reservationService.getReservationsByMemberId(memberInfo.getMemberId());
            // model.addAttribute("myReservations", myReservations);
            model.addAttribute("body", "member/mypage.jsp");
            return "layout/layout";
        }
    }

    // =================================================================
    // == 프로필 수정 관련 (Edit Profile)
    // =================================================================

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
            redirectAttributes.addFlashAttribute("error", "현재 비밀번호가 일치하지 않거나, 정보 수정에 실패했습니다.");
            return "redirect:/member/edit-profile";
        }
    }

    // =================================================================
    // == 소셜 계정 연동 관련 (Social Link)
    // =================================================================

    @GetMapping("/prepare-link/{provider}")
    public String prepareLinkSocial(@PathVariable String provider, HttpSession session) {
        session.setAttribute("socialLinkRequest", true);
        return "redirect:/oauth2/authorization/" + provider;
    }

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

    // =================================================================
    // == 회원 탈퇴 (Withdraw)
    // =================================================================

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

    // =================================================================
    // == 헬퍼 메소드 (Helper Method)
    // =================================================================

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
