package com.spring.teamProject.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.spring.teamProject.service.WaitingService;
import com.spring.teamProject.vo.WaitingVO;


@Controller
@RequestMapping("/waiting/customer")
public class WaitingCustomerController {

    @Autowired
    private WaitingService waitingService;

    @GetMapping("/register")
    public String showForm() {
        return "waiting/customer/register";
    }

    @PostMapping("/register")
    public String submitForm(@ModelAttribute WaitingVO waitingVO, Model model) {
        // 이제 폼에서 넘어온 waitingVO에는 fcmToken 값이 포함되어야 합니다.
        // (JSP/HTML 폼에 fcmToken을 담을 hidden input이 필요합니다)
        waitingService.insertWaiting(waitingVO); // 이 메서드 호출 시 자동으로 Firebase 동기화가 이루어집니다.
        model.addAttribute("waiting", waitingVO);
        return "waiting/customer/result";
    }
    
    @GetMapping
    public List<WaitingVO> getAllWaitings() {
        return waitingService.getAllWaitings();
    }

    @GetMapping("/{id}")
    public WaitingVO getWaitingById(@PathVariable Long id) {
        return waitingService.getWaitingById(id);
    }

    @PostMapping
    public void insertWaiting(@RequestBody WaitingVO waiting) {
        waitingService.insertWaiting(waiting);
    }

    @PutMapping("/{id}")
    public void updateWaitingStatus(@PathVariable Long id, @RequestParam String status) {
        waitingService.updateWaitingStatus(id, status);
    }

    @DeleteMapping("/{id}")
    public void deleteWaiting(@PathVariable Long id) {
        waitingService.deleteWaiting(id);
    }
}
