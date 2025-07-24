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
        waitingService.insertWaiting(waitingVO);
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
