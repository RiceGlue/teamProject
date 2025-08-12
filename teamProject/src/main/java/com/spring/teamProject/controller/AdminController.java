package com.spring.teamProject.controller;

import java.util.List; // List import 추가

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.teamProject.service.MemberService;
import com.spring.teamProject.vo.MemberVO;

@Controller
@RequestMapping("/admin") // /admin으로 시작하는 모든 요청은 이 컨트롤러가 처리합니다.
public class AdminController {

    @Autowired
    private MemberService memberService;

    /**
     * 관리자 대시보드 메인 페이지를 보여줍니다.
     */
    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("body", "admin/dashboard.jsp");
        return "admin/admin_layout";
    }

    /**
     * 가맹점주 계정 목록을 DB에서 조회하여 뷰로 전달합니다.
     */
    @GetMapping("/owners")
    public String ownerList(Model model) {
        List<MemberVO> ownerList = memberService.findOwners();
        model.addAttribute("ownerList", ownerList);
        model.addAttribute("body", "admin/owner_list.jsp");
        return "admin/admin_layout";
    }

    /**
     * 가맹점주 계정 생성 폼 페이지를 보여줍니다.
     */
    @GetMapping("/owners/new")
    public String ownerJoinForm(Model model) {
        model.addAttribute("body", "admin/owner_join.jsp");
        return "admin/admin_layout"; // 관리자 전용 레이아웃을 사용합니다.
    }

    /**
     * [신규] 가맹점주 계정 생성 요청을 처리합니다.
     * @param memberVO 폼에서 입력된 가맹점주 정보
     * @param redirectAttributes 리다이렉트 시 메시지 전달용
     * @return 성공 시 목록 페이지, 실패 시 다시 생성 폼으로 이동
     */
    @PostMapping("/owners")
    public String createOwner(MemberVO memberVO, RedirectAttributes redirectAttributes) {
        try {
            memberService.join(memberVO);
            redirectAttributes.addFlashAttribute("msg", "가맹점주 계정이 성공적으로 생성되었습니다.");
            return "redirect:/admin/owners"; // 성공 시 목록 페이지로 이동
        } catch (DuplicateKeyException e) {
            redirectAttributes.addFlashAttribute("error", "이미 사용 중인 아이디, 이메일 또는 전화번호입니다.");
            redirectAttributes.addFlashAttribute("memberVO", memberVO); // 입력 데이터 유지를 위해 전달
            return "redirect:/admin/owners/new"; // 실패 시 다시 생성 폼으로 이동
        }
    }
}
