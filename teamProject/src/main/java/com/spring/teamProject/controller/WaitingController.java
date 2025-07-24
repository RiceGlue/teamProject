package com.spring.teamProject.controller;

import com.spring.teamProject.service.WaitingService;
import com.spring.teamProject.vo.WaitingVO;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/waiting")
public class WaitingController {

    private final WaitingService waitingService;

    public WaitingController(WaitingService waitingService) {
        this.waitingService = waitingService;
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
