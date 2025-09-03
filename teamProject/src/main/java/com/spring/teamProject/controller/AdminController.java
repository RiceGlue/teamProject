package com.spring.teamProject.controller;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZoneId; // ZoneId import 추가
import java.util.ArrayList;
import java.util.Date; // Date import 추가
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.MemberService;
import com.spring.teamProject.service.ReviewService;
import com.spring.teamProject.service.SettlementService;
import com.spring.teamProject.service.StoreService;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.ManageReviewVO;
import com.spring.teamProject.vo.MemberVO;
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.SettlementsEntity;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private MemberService memberService;

    @Autowired
    private ReviewService reviewService;

    @Autowired
    private StoreService storeService;

    @Autowired
    private SettlementService settlementService;

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
     * [신규] 일반 회원 계정 목록 페이지를 보여줍니다.
     */
    @GetMapping("/users")
    public String userList(Model model) {
        List<MemberVO> userList = memberService.findUsers();
        model.addAttribute("userList", userList);
        model.addAttribute("body", "admin/user_list.jsp");
        return "admin/admin_layout";
    }

    /**
     * 가맹점주 계정 생성 폼 페이지를 보여줍니다.
     */
    @GetMapping("/owners/new")
    public String ownerJoinForm(Model model) {
        model.addAttribute("body", "admin/owner_join.jsp");
        return "admin/admin_layout";
    }

    /**
     * 가맹점주 계정 생성 요청을 처리합니다.
     * @param memberVO 폼에서 입력된 가맹점주 정보
     * @param redirectAttributes 리다이렉트 시 메시지 전달용
     * @return 성공 시 목록 페이지, 실패 시 다시 생성 폼으로 이동
     */
    @PostMapping("/owners")
    public String createOwner(MemberVO memberVO, RedirectAttributes redirectAttributes) {
        try {
            memberService.join(memberVO);
            redirectAttributes.addFlashAttribute("msg", "가맹점주 계정이 성공적으로 생성되었습니다.");
            return "redirect:/admin/owners";
        } catch (DuplicateKeyException e) {
            redirectAttributes.addFlashAttribute("error", "이미 사용 중인 아이디, 이메일 또는 전화번호입니다.");
            redirectAttributes.addFlashAttribute("memberVO", memberVO);
            return "redirect:/admin/owners/new";
        }
    }

    @RequestMapping(value="/adminReviewManage")
    public ModelAndView adminReviewManage(HttpServletRequest req, HttpServletResponse res) throws Exception {
        String viewName = (String) req.getAttribute("viewName");

        List<ManageReviewVO> manageReviewList = reviewService.selectReviewManage();
        List<ManageReviewVO> requestedOrInProgressList = new ArrayList<>();
        List<ManageReviewVO> approvedOrRejectedList = new ArrayList<>();

        for (ManageReviewVO manageReview : manageReviewList) {
            long reviewId = manageReview.getReviewId();

            ReviewVO reviewVO = reviewService.getRivew(reviewId);
            manageReview.setReview(reviewVO);

            List<ImageFileVO> imageList = reviewService.getImageFile(reviewId);
            manageReview.setImageList(imageList);

            String status = manageReview.getStatus();
            if ("REQUESTED".equals(status) || "IN_PROGRESS".equals(status)) {
                requestedOrInProgressList.add(manageReview);
            } else if ("APPROVED".equals(status) || "REJECTED".equals(status)) {
                approvedOrRejectedList.add(manageReview);
            }
        }

        System.out.println("requestedOrInProgressList 크기 :" + requestedOrInProgressList.size());

        ModelAndView mav = ViewUtil.adminLayout(viewName);
        mav.addObject("requestedOrInProgressList", requestedOrInProgressList);
        mav.addObject("approvedOrRejectedList", approvedOrRejectedList);

        return mav;
    }


    /**
     * 특정 점주의 정산 내역을 조회합니다.
     */
    @GetMapping("/settlement-history")
    public String getOwnerSettlementHistory(
            @RequestParam("ownerId") long ownerId,
            @RequestParam(value = "startDate", required = false) String startDateStr,
            @RequestParam(value = "endDate", required = false) String endDateStr,
            Model model) {

        LocalDate endDate = (endDateStr != null) ? LocalDate.parse(endDateStr) : LocalDate.now();
        LocalDate startDate = (startDateStr != null) ? LocalDate.parse(startDateStr) : endDate.minusMonths(1);

        List<SettlementsEntity> settlementList = settlementService.getSettlementHistoryByOwnerIdAndDateRange(ownerId, startDate, endDate);

        // --- 여기서부터 LocalDate/LocalDateTime을 Date로 변환하는 로직 추가 ---
        List<Map<String, Object>> displayList = new ArrayList<>();
        for (SettlementsEntity entity : settlementList) {
            Map<String, Object> map = new HashMap<>();
            map.put("settlementId", entity.getSettlementId());
            map.put("storeId", entity.getStoreId());

            // LocalDate를 Date로 변환
            map.put("settlementPeriodStart", Date.from(entity.getSettlementPeriodStart().atStartOfDay(ZoneId.systemDefault()).toInstant()));
            map.put("settlementPeriodEnd", Date.from(entity.getSettlementPeriodEnd().atStartOfDay(ZoneId.systemDefault()).toInstant()));

            map.put("totalRevenueAmount", entity.getTotalRevenueAmount());
            map.put("totalCommissionAmount", entity.getTotalCommissionAmount());
            map.put("finalSettlementAmount", entity.getFinalSettlementAmount());
            map.put("status", entity.getStatus());

            // LocalDateTime을 Date로 변환 (null 체크 포함)
            if (entity.getSettledAt() != null) {
                map.put("settledAt", Date.from(entity.getSettledAt().atZone(ZoneId.systemDefault()).toInstant()));
            } else {
                map.put("settledAt", null);
            }

            displayList.add(map);
        }
        // --- 변환 로직 끝 ---

        model.addAttribute("ownerId", ownerId);
        model.addAttribute("settlementList", displayList); // 변환된 displayList를 모델에 추가
        model.addAttribute("startDate", startDate);
        model.addAttribute("endDate", endDate);
        model.addAttribute("body", "admin/owner_settlement_history.jsp");

        return "admin/admin_layout";
    }

    /**
     * 정산 상태를 'COMPLETED'로 변경하여 승인 처리합니다.
     */
    @GetMapping("/approve-settlement")
    public String approveSettlement(@RequestParam("settlementId") long settlementId,
                                    @RequestParam("ownerId") long ownerId) {

        settlementService.approveSettlement(settlementId);

        return "redirect:/admin/settlement-history?ownerId=" + ownerId;
    }

    // ✨ 수수료율 조회 페이지
    @GetMapping("/commission-rate")
    public String getCommissionRate(Model model) {
        // 현재 수수료율을 가져오는 로직 (추후 구현)
        BigDecimal currentRate = BigDecimal.valueOf(0.05); // 임시 값
        model.addAttribute("commissionRate", currentRate);
        model.addAttribute("body", "admin/commission_rate.jsp");
        return "admin/admin_layout";
    }

    // ✨ 수수료율 업데이트 처리
    @PostMapping("/update-commission-rate")
    public String updateCommissionRate(@RequestParam("rate") BigDecimal rate, RedirectAttributes redirectAttributes) {
        // 수수료율을 업데이트하는 로직 (추후 구현)
        redirectAttributes.addFlashAttribute("msg", "수수료율이 성공적으로 변경되었습니다.");
        return "redirect:/admin/commission-rate";
    }

}