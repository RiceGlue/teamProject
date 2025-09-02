package com.spring.teamProject.controller;

import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.savedrequest.HttpSessionRequestCache;
import org.springframework.security.web.savedrequest.RequestCache;
import org.springframework.security.web.savedrequest.SavedRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.teamProject.service.MemberService;
import com.spring.teamProject.service.RecaptchaService;
import com.spring.teamProject.service.ReservationService;
import com.spring.teamProject.service.ReviewService;
import com.spring.teamProject.service.StoreService;
import com.spring.teamProject.service.WaitingService;
import com.spring.teamProject.service.WishlistService;
import com.spring.teamProject.tool.DebugEmailUtil;
import com.spring.teamProject.tool.FtpConnectionTestUtil;
import com.spring.teamProject.vo.MemberVO;
import com.spring.teamProject.vo.ReservationVO;
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.SocialAccountVO;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.UserDetailsVO;
import com.spring.teamProject.vo.WaitingVO;
import com.spring.teamProject.vo.WishlistEntity;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/member")
public class MemberController {

    private static final Logger logger = LoggerFactory.getLogger(MemberController.class);

    @Autowired
    private MemberService memberService;

    @Autowired
    private StoreService storeService;

    @Autowired
    private WaitingService waitingService;

    @Autowired
    private RecaptchaService recaptchaService;

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private WishlistService wishlistService;
    
    @Autowired
    private ReviewService reviewService;

    @Value("${google.recaptcha.site-key}")
    private String recaptchaSiteKey;

    @Autowired
    private DebugEmailUtil debugEmailUtil; // Added for email testing

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
    public String joinSelectForm(Model model, HttpSession session) {
        if (isAuthenticated() && !isGuest()) {
            session.setAttribute("errorMessage", "이미 로그인되어 있습니다.");
            return "redirect:/";
        }
        model.addAttribute("body", "member/join_select.jsp");
        return "layout/layout";
    }

    @GetMapping("/login")
    public String loginForm(Model model, HttpServletRequest request, HttpServletResponse response, HttpSession session) {
        if (isAuthenticated() && !isGuest()) {
            session.setAttribute("errorMessage", "이미 로그인되어 있습니다.");
            return "redirect:/";
        }

        // Spring Security가 저장한 '원래 가려던 페이지' 정보를 가져옵니다.
        RequestCache requestCache = new HttpSessionRequestCache();
        SavedRequest savedRequest = requestCache.getRequest(request, response);

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
    public String joinForm(@RequestParam("role") String role, Model model, @ModelAttribute("memberVO") MemberVO memberVO, HttpSession session) {
        if (isAuthenticated() && !isGuest()) {
            session.setAttribute("errorMessage", "이미 로그인되어 있습니다.");
            return "redirect:/";
        }

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
        } catch (IllegalArgumentException e) {
            // Service에서 보낸 '소셜 계정 이메일 중복' 메시지를 로그인 페이지로 전달합니다.
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/member/login"; // 회원가입 페이지가 아닌 로그인 페이지로 이동
        } catch (DuplicateKeyException e) {
            // DB의 UNIQUE 제약 조건에 걸린 경우 (일반 계정 이메일, 아이디, 전화번호 중복)
            redirectAttributes.addFlashAttribute("error", "이미 사용 중인 아이디, 이메일 또는 전화번호입니다.");
            redirectAttributes.addFlashAttribute("memberVO", memberVO);
            return "redirect:/member/join?role=" + memberVO.getRole();
        }
    }

    @GetMapping("/join_social")
    public String joinSocialForm(Model model, HttpSession session) {
        if (isAuthenticated() && !isGuest()) {
            session.setAttribute("errorMessage", "이미 로그인되어 있습니다.");
            return "redirect:/";
        }

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
    // == 아이디 / 비밀번호 찾기 (Find Account)
    // =================================================================

    @GetMapping("/find-account")
    public String findAccountForm(Model model) {
        model.addAttribute("body", "member/find_account.jsp");
        return "layout/layout";
    }

    @PostMapping("/find-id/send-code")
    @ResponseBody
    public Map<String, Object> sendCodeForFindId(@RequestParam("memberName") String memberName,
                                                 @RequestParam("email") String email,
                                                 HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        String result = memberService.sendVerificationCodeForId(memberName, email);

        if (result != null) {
            String[] parts = result.split(":");
            String code = parts[0];
            String loginId = parts[1];
            String maskedEmail = parts[2];

            // 세션에 인증번호와 찾은 아이디를 저장 (3분 유효)
            session.setAttribute("verificationCodeForId", code);
            session.setAttribute("loginIdForVerification", loginId);
            session.setMaxInactiveInterval(180);

            response.put("success", true);
            response.put("message", maskedEmail + "(으)로 인증번호를 발송했습니다.");
        } else {
            response.put("success", false);
            response.put("message", "일치하는 회원 정보를 찾을 수 없습니다.");
        }
        return response;
    }

    @PostMapping("/find-id/verify-code")
    @ResponseBody
    public Map<String, Object> verifyCodeForFindId(@RequestParam("code") String code,
                                                   HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        String sessionCode = (String) session.getAttribute("verificationCodeForId");
        String loginId = (String) session.getAttribute("loginIdForVerification");

        if (sessionCode != null && sessionCode.equals(code)) {
            response.put("success", true);
            response.put("loginId", loginId);
            // 성공 시 세션 정보 즉시 삭제
            session.removeAttribute("verificationCodeForId");
            session.removeAttribute("loginIdForVerification");
        } else {
            response.put("success", false);
            response.put("message", "인증번호가 일치하지 않습니다.");
        }
        return response;
    }

    @PostMapping("/reset-password")
    public String resetPassword(@RequestParam("loginId") String loginId,
                                @RequestParam("email") String email,
                                RedirectAttributes redirectAttributes) {

        boolean isSuccess = memberService.resetPassword(loginId, email);

        if (isSuccess) {
            redirectAttributes.addFlashAttribute("msg", "가입하신 이메일로 임시 비밀번호가 발송되었습니다.");
        } else {
            redirectAttributes.addFlashAttribute("error", "일치하는 회원 정보를 찾을 수 없습니다.");
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

            try {
                // 1. 예약 정보 목록 가져오기
                List<ReservationVO> reservations = reservationService.getReservationsByMemberId((long) memberInfo.getMemberId());
                logger.info("사용자 {}의 예약 목록: {}건", memberInfo.getLoginId(), reservations.size());

                // ? 추가: LocalDateTime을 Date로 변환하는 로직
                List<Map<String, Object>> displayReservations = reservations.stream().map(res -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("reservationId", res.getReservationId());
                    map.put("storeName", res.getStoreName());
                    map.put("status", res.getStatus());
                    map.put("guestCount", res.getGuestCount());
                    map.put("paymentId", res.getPaymentId());
                    map.put("storeId", res.getStoreId());

                    // LocalDateTime -> java.util.Date로 변환
                    if (res.getReservationTime() != null) {
                        Date reservationDate = Date.from(res.getReservationTime().atZone(ZoneId.systemDefault()).toInstant());
                        map.put("reservationDate", reservationDate);
                    }
                    return map;
                }).collect(Collectors.toList());

                // 수정된 리스트를 모델에 추가
                model.addAttribute("reservations", displayReservations);

                // 2. 위시리스트 정보 목록 가져오기
                List<WishlistEntity> wishlists = wishlistService.getWishlistByMemberId((long) memberInfo.getMemberId());
                
                List<StoreVO> wishlistStore = new ArrayList<>();
                
                for (int i=0;i<wishlists.size();i++) {
                    StoreVO storeVO = storeService.getStoreById(wishlists.get(i).getStoreId());
                    wishlistStore.add(storeVO);
                }
//
//                // 위시리스트 엔티티에 가게 정보를 추가하여 새로운 리스트를 만듭니다.
//                List<Map<String, Object>> displayWishlists = wishlists.stream().map(wish -> {
//                    Map<String, Object> map = new HashMap<>();
//                    map.put("wishlistId", wish.getWishlistId());
//                    map.put("storeId", wish.getStoreId());
//
//                    try {
//                        StoreVO store = storeService.getStoreById(wish.getStoreId());
//                        if (store != null) {
//                            map.put("store", store);
//                            map.put("storeFileName", store.getFileName()); // storeFileName 추가
//                        } else {
//                            map.put("storeName", "알 수 없는 가게");
//                            map.put("storeFileName", null);
//                        }
//                    } catch (Exception e) {
//                        map.put("storeName", "가게 정보 오류");
//                        map.put("storeFileName", null);
//                    }
//                    return map;
//                }).collect(Collectors.toList());
                model.addAttribute("wishlistStore", wishlistStore);

                // 3. 웨이팅 정보 목록 가져오기
                List<WaitingVO> waitings = waitingService.getWaitingsByMemberId((long) memberInfo.getMemberId());
                List<Map<String, Object>> displayWaitings = waitings.stream().map(wait -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("waitingId", wait.getWaitingId());
                    map.put("storeId", wait.getStoreId());
                    map.put("partySize", wait.getGuestCount());
                    map.put("status", wait.getStatus());

                    try {
                        StoreVO store = storeService.getStoreById(wait.getStoreId());
                        map.put("storeName", store != null ? store.getStoreName() : "알 수 없는 가게");
                    } catch (Exception e) {
                        map.put("storeName", "가게 정보 오류");
                    }

                    if ("WAITING".equals(wait.getStatus())) {
                        List<WaitingVO> currentWaitings = waitingService.getCurrentWaitings(wait.getStoreId());
                        for (int i = 0; i < currentWaitings.size(); i++) {
                            if (currentWaitings.get(i).getWaitingId().equals(wait.getWaitingId())) {
                                map.put("waitingNumber", (i + 1)); // 순번은 1부터 시작
                                map.put("aheadCount", i); // 내 앞 대기 팀 수
                                break;
                            }
                        }
                    } else {
                        map.put("waitingNumber", "종료"); // 'WAITING' 상태가 아니면 순번 없음
                        map.put("aheadCount", "-");
                    }

                    return map;
                }).collect(Collectors.toList());
                model.addAttribute("waitings", displayWaitings);
                
                List<ReviewVO> reviewList = reviewService.getUserReview((long) memberInfo.getMemberId());
                model.addAttribute("reviewList", reviewList);

            } catch (Exception e) {
                 logger.error("마이페이지 정보 조회 중 오류 발생: {}", e.getMessage(), e);
                model.addAttribute("error", "페이지 정보를 불러오는 데 실패했습니다.");
            }

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
                redirectAttributes.addFlashAttribute("error", "현재 비밀번호가 일치하지 않거나, 정보 수정에 실패했습니다.");
                return "redirect:/member/edit-profile";
            }
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/member/edit-profile";
        }
    }

    // =================================================================
    // == 소셜 계정 연동 및 전환 (Social Link & Conversion)
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

    @PostMapping("/set-password")
    public String setPasswordForSocialUser(@RequestParam("loginId") String loginId,
                                           @RequestParam("newLoginPw") String newPassword,
                                           @AuthenticationPrincipal Object principal,
                                           RedirectAttributes redirectAttributes) {
        MemberVO currentMember = getMemberInfoFromPrincipal(principal);
        if (currentMember == null) {
            return "redirect:/member/login";
        }

        try {
            boolean isSuccess = memberService.setPasswordForSocialUser(currentMember.getMemberId(), loginId, newPassword);

            if (isSuccess) {
                redirectAttributes.addFlashAttribute("msg", "일반 계정으로 전환되었습니다. 이제 아이디와 비밀번호로 로그인할 수 있습니다.");

                // 세션 갱신
                MemberVO updatedMember = memberService.findById(currentMember.getMemberId());
                Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
                UserDetailsVO newPrincipal = new UserDetailsVO(updatedMember);
                Authentication newAuth = new UsernamePasswordAuthenticationToken(newPrincipal, authentication.getCredentials(), newPrincipal.getAuthorities());
                SecurityContextHolder.getContext().setAuthentication(newAuth);

                return "redirect:/member/edit-profile";
            } else {
                redirectAttributes.addFlashAttribute("error", "계정 전환에 실패했습니다. 다시 시도해주세요.");
                return "redirect:/member/edit-profile";
            }
        } catch (DuplicateKeyException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/member/edit-profile";
        }
    }

    @GetMapping("/link-account")
    public String linkAccountForm(Model model, HttpSession session) {
        Object socialLinkInfo = session.getAttribute("socialLinkInfo");
        if (socialLinkInfo == null) {
            return "redirect:/";
        }
        model.addAttribute("socialLinkInfo", socialLinkInfo);
        model.addAttribute("body", "member/link_account.jsp");
        return "layout/layout";
    }

    @PostMapping("/link-account/confirm")
    public String linkAccountConfirm(@RequestParam("loginId") String loginId,
                                     @RequestParam("password") String password,
                                     HttpSession session,
                                     RedirectAttributes redirectAttributes) {

        Map<String, Object> socialLinkInfo = (Map<String, Object>) session.getAttribute("socialLinkInfo");
        if (socialLinkInfo == null) {
            return "redirect:/";
        }

        String email = (String) socialLinkInfo.get("email");
        String provider = (String) socialLinkInfo.get("provider");
        String socialId = (String) socialLinkInfo.get("socialId");

        try {
            MemberVO linkedMember = memberService.verifyIdAndPasswordAndLinkAccount(email, loginId, password, provider, socialId);

            // 연동 성공 시, 수동으로 로그인 처리
            UserDetailsVO userDetails = new UserDetailsVO(linkedMember);
            Authentication authentication = new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(authentication);

            session.removeAttribute("socialLinkInfo");
            session.setAttribute("successMessage", "소셜 계정이 성공적으로 연동되었습니다.");

            return "redirect:/";

        } catch (BadCredentialsException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/member/link-account";
        }
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
    // == 테스트용 기능 (Test Utilities)
    // =================================================================
    @Autowired
    private FtpConnectionTestUtil ftpTestUtil;

    @GetMapping("/testEmailSend")
    @ResponseBody
    public String testEmailSend(@RequestParam String to) {
        try {
            boolean success = debugEmailUtil.sendTestEmail(to);
            if (success) {
                return "테스트 이메일 발송 성공: " + to;
            } else {
                return "테스트 이메일 발송 실패: " + to + ". 서버 로그를 확인하세요.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "테스트 이메일 발송 중 예외 발생: " + e.getMessage();
        }
    }

    @GetMapping("/testFtp")
    @ResponseBody
    public String testFtpConnection() {
        logger.info("FTP 연결 테스트 API 호출됨.");
        boolean success = ftpTestUtil.runFtpTest();
        if (success) {
            return "FTP 테스트 성공! 서버 콘솔 로그와 FTP 서버의 /srv/ftp/riceGlue/upload/test_folder_from_java/ 폴더를 확인하세요.";
        } else {
            return "FTP 테스트 실패. 서버 콘솔 로그를 확인하여 원인을 분석하세요.";
        }
    }

    // =================================================================
    // == 헬퍼 메소드 (Helper Method)
    // =================================================================

    private boolean isAuthenticated() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || authentication instanceof AnonymousAuthenticationToken) {
            return false;
        }
        return authentication.isAuthenticated();
    }
    
    private boolean isGuest() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()) {
            return authentication.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_GUEST"));
        }
        return false;
    }

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

