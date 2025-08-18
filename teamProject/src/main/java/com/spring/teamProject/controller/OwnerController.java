package com.spring.teamProject.controller;

import org.springframework.beans.factory.annotation.Autowired;
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
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.teamProject.service.MemberService;
import com.spring.teamProject.vo.MemberVO;
import com.spring.teamProject.vo.UserDetailsVO;

@Controller
@RequestMapping("/owner")
public class OwnerController {

    // MemberService를 주입받아 회원 정보를 처리합니다.
    @Autowired
    private MemberService memberService;

    /**
     * 점주 대시보드의 메인 페이지를 보여줍니다.
     */
    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        // TODO: 나중에 실제 점주의 매장 목록 데이터를 DB에서 조회해서 모델에 추가해야 합니다.
        // 예: List<StoreVO> storeList = storeService.findByOwnerId(ownerId);
        // model.addAttribute("storeList", storeList);

        // owner_layout.jsp를 메인 레이아웃으로 사용하고,
        // 본문(body)에는 owner_dashboard.jsp를 포함시킵니다.
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

}
