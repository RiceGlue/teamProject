package com.spring.teamProject.controller;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
import org.springframework.web.bind.annotation.ResponseBody; // REST API 응답을 위해 추가
import org.springframework.web.servlet.mvc.support.RedirectAttributes; // RedirectAttributes 임포트 추가!

import com.spring.teamProject.service.WaitingService;
import com.spring.teamProject.vo.WaitingVO;


@Controller
@RequestMapping("/waiting/customer")
public class WaitingCustomerController {

    private static final Logger logger = LoggerFactory.getLogger(WaitingCustomerController.class); // 로거 추가

    @Autowired
    private WaitingService waitingService;

    // GET 요청: 웨이팅 등록 폼을 보여줍니다.
    @GetMapping("/register")
    public String showForm() {
        return "waiting/customer/register";
    }

    // POST 요청: 웨이팅 등록 폼 데이터를 처리합니다.
    @PostMapping("/register")
    public String submitForm(@ModelAttribute WaitingVO waitingVO, RedirectAttributes redirectAttributes) { // Model 대신 RedirectAttributes 사용
        try {
            waitingVO.setStatus("WAITING"); // 초기 웨이팅 상태 설정

            logger.info("Received WaitingVO: memberId={}, storeId={}, guestCount={}, fcmToken={}",
                        waitingVO.getMemberId(), waitingVO.getStoreId(), waitingVO.getGuestCount(), waitingVO.getFcmToken());

            waitingService.insertWaiting(waitingVO); // 데이터베이스 삽입 및 Firebase 동기화

            // RedirectAttributes를 사용하여 다음 GET 요청으로 데이터를 전달
            // addFlashAttribute는 URL에 노출되지 않으며, 한 번 사용 후 사라집니다.
            redirectAttributes.addFlashAttribute("waiting", waitingVO);
            
            // 성공 시 리다이렉트할 URL
            return "redirect:/waiting/customer/result"; 

        } catch (Exception e) {
            logger.error("Error submitting waiting form: ", e); 
            redirectAttributes.addFlashAttribute("error", "웨이팅 등록 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/errorPage"; // 오류 발생 시 오류 페이지로 리다이렉트
        }
    }
    
    // GET 요청: 웨이팅 등록 성공 후 보여줄 페이지 (리다이렉트 대상)
    @GetMapping("/result")
    public String showResultPage(Model model) { // @ModelAttribute("waiting")은 필요 없고, Model에 자동으로 추가됩니다.
        // RedirectAttributes로 전달된 "waiting" 객체가 자동으로 Model에 추가됩니다.
        // 따라서 JSP에서 ${waiting.memberId} 등으로 바로 접근 가능합니다.
        
        // 만약 리다이렉트 없이 직접 접근 시, model에 waiting 객체가 없을 수 있으므로
        // 필요한 경우 model.containsAttribute("waiting") 등으로 확인하거나,
        // 이 페이지에서 다시 waiting 정보를 조회하는 로직을 추가할 수 있습니다.
        return "waiting/customer/result";
    }

    // --- REST API 관련 메서드들은 이전 수정과 동일하게 유지 ---

    // 모든 웨이팅 목록 조회 (API)
    @GetMapping("/api")
    @ResponseBody
    public List<WaitingVO> getAllWaitings() {
        return waitingService.getAllWaitings();
    }

    // 특정 ID의 웨이팅 조회 (API)
    @GetMapping("/api/{id}")
    @ResponseBody
    public WaitingVO getWaitingById(@PathVariable Long id) {
        return waitingService.getWaitingById(id);
    }

    // 웨이팅 추가 (API) - 폼 제출과 다른 방식으로 데이터를 받는 경우 (예: JSON)
    @PostMapping("/api")
    @ResponseBody
    public void insertWaitingApi(@RequestBody WaitingVO waiting) {
        waitingService.insertWaiting(waiting);
    }

    // 웨이팅 상태 업데이트 (API)
    @PutMapping("/api/{id}")
    @ResponseBody
    public void updateWaitingStatus(@PathVariable Long id, @RequestParam String status) {
        waitingService.updateWaitingStatus(id, status);
    }

    // 웨이팅 삭제 (API)
    @DeleteMapping("/api/{id}")
    @ResponseBody
    public void deleteWaiting(@PathVariable Long id) {
        waitingService.deleteWaiting(id);
    }
}