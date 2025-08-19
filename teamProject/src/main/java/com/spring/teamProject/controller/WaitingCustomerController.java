package com.spring.teamProject.controller;

import java.util.HashMap; // Map을 사용하기 위해 임포트 추가
import java.util.List;
import java.util.Map;     // Map을 사용하기 위해 임포트 추가

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication; // Authentication 클래스 임포트
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
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.teamProject.service.MemberService;
import com.spring.teamProject.service.WaitingService;
import com.spring.teamProject.vo.UserDetailsVO;
import com.spring.teamProject.vo.WaitingVO;

@Controller
@RequestMapping("/waiting/customer")
public class WaitingCustomerController {

    private static final Logger logger = LoggerFactory.getLogger(WaitingCustomerController.class);

    @Autowired
    private WaitingService waitingService;

    @Autowired
    private MemberService memberService;

    // GET 요청: 웨이팅 등록 폼을 보여줍니다.
    @GetMapping("/form")
    public String showForm(@RequestParam("storeId") Long storeId, Model model) {
    	logger.info("GET /form 요청이 들어왔습니다.");
    	model.addAttribute("storeId", storeId);
        return "waiting/customer/register";
    }

    // POST 요청: 웨이팅 등록 폼 데이터를 처리합니다.
    @PostMapping("/register")
    public String submitForm(@ModelAttribute WaitingVO waitingVO, Authentication authentication, RedirectAttributes redirectAttributes) {
    	logger.info("POST /register 요청이 들어왔습니다.");
        try {
        	if (authentication != null && authentication.getPrincipal() instanceof UserDetailsVO) {
                // principal 객체를 UserDetailsVO 타입으로 형 변환
                UserDetailsVO userDetailsVO = (UserDetailsVO) authentication.getPrincipal();
                // UserDetailsVO에 추가한 getMemberId() 메서드를 사용하여 바로 값을 가져옴
                Long memberId = userDetailsVO.getMemberId();

                // ⭐️ 추가된 로직: 중복 웨이팅 확인
                boolean hasExistingWaiting = waitingService.checkExistingWaiting(memberId);
                if (hasExistingWaiting) {
                    redirectAttributes.addFlashAttribute("error", "이미 웨이팅 중인 내역이 있습니다.");
                    return "redirect:/waiting/customer/form?storeId=" + waitingVO.getStoreId() + "&error=true";
                }

                waitingVO.setMemberId(memberId);

            } else {
                redirectAttributes.addFlashAttribute("error", "로그인이 필요합니다.");
                return "redirect:/member/login";
            }

            //waitingVO.setLoginId(loginId); // WaitingVO에 로그인한 사용자 ID 설정

            //만약 WaitingVO에 memberId 필드를 꼭 채워야 한다면,
            //memberId를 가져오는 서비스 로직을 추가해야 합니다.
//	        MemberVO member = memberService.findByLoginId(loginId);
//	        if(member != null) {
//	        	waitingVO.setMemberId(member.getMemberId());
//	        }

            waitingVO.setStatus("WAITING"); // 초기 웨이팅 상태 설정

            logger.info("Received WaitingVO: memberId={}, storeId={}, guestCount={}, fcmToken={}",
                        waitingVO.getMemberId(), waitingVO.getStoreId(), waitingVO.getGuestCount(), waitingVO.getFcmToken());

            waitingService.insertWaiting(waitingVO); // 데이터베이스 삽입 및 Firebase 동기화

            redirectAttributes.addFlashAttribute("waiting", waitingVO);

            // 성공 시 리다이렉트할 URL
            return "redirect:/waiting/customer/result";

        } catch (IllegalStateException e) { // <-- 이 부분 추가: 서비스에서 던지는 IllegalStateException 처리
            logger.error("웨이팅 등록 불가: {}", e.getMessage());
            redirectAttributes.addFlashAttribute("error", e.getMessage()); // 서비스에서 보낸 메시지를 그대로 사용자에게 전달
            //return "redirect:/waiting/customer/form?error=true"; // 등록 폼으로 다시 보내면서 에러 메시지 표시
            return "redirect:/waiting/customer/form?storeId=" + waitingVO.getStoreId() + "&error=true";
        }
        catch (Exception e) {
            logger.error("Error submitting waiting form: ", e);
            redirectAttributes.addFlashAttribute("error", "웨이팅 등록 중 알 수 없는 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/errorPage"; // 기타 오류 발생 시 오류 페이지로 리다이렉트
        }
    }

    // GET 요청: 웨이팅 등록 성공 후 보여줄 페이지 (리다이렉트 대상)
    @GetMapping("/result")
    public String showResultPage(Model model) {
        return "waiting/customer/result";
    }

    // --- REST API 관련 메서드들 ---

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
    // 이 API도 웨이팅 제한 로직의 영향을 받습니다.
    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<Map<String, String>> insertWaitingApi(@RequestBody WaitingVO waiting) {
        Map<String, String> response = new HashMap<>();
        try {
            waiting.setStatus("WAITING"); // 초기 상태 설정
            waitingService.insertWaiting(waiting);
            response.put("message", "웨이팅이 성공적으로 접수되었습니다.");
            return ResponseEntity.ok(response);
        } catch (IllegalStateException e) {
            logger.warn("API 웨이팅 등록 불가: {}", e.getMessage());
            response.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response); // 400 Bad Request
        } catch (Exception e) {
            logger.error("API 웨이팅 등록 중 오류 발생: {}", e.getMessage(), e);
            response.put("error", "웨이팅 등록 중 알 수 없는 오류가 발생했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response); // 500 Internal Server Error
        }
    }

    // 웨이팅 상태 업데이트 (API)
    @PutMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<Void> updateWaitingStatus(
            @PathVariable("id") String idString,
            @RequestParam("status") String status) {
        try {
            Long id = Long.parseLong(idString);

            logger.info("Received update request for waitingId: {}, status: {}", id, status);
            waitingService.updateWaitingStatus(id, status);

            return ResponseEntity.ok().build();
        } catch (NumberFormatException e) {
            logger.error("Invalid waiting ID format: {}", idString, e);
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            logger.error("Error updating waiting status for id {}: {}", idString, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // 웨이팅 삭제 (API)
    @DeleteMapping("/api/{id}")
    @ResponseBody
    public void deleteWaiting(@PathVariable Long id) {
        waitingService.deleteWaiting(id);
    }
}