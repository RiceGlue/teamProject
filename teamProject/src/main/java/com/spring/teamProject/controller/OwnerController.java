package com.spring.teamProject.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/owner")
public class OwnerController {

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
        return "layout/owner_layout";
    }

    // TODO: 앞으로 '매장 관리', '정산 내역' 등 다른 점주용 페이지 요청을 처리할 메소드를 여기에 추가합니다.
}
