package com.spring.teamProject.controller;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.spring.teamProject.common.ViewUtil;
import com.spring.teamProject.service.FtpService;
import com.spring.teamProject.service.ReviewServiceImpl;
import com.spring.teamProject.vo.ImageFileVO;
import com.spring.teamProject.vo.ManageReviewVO;
import com.spring.teamProject.vo.ReviewLikeVO;
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.StoreVO;
import com.spring.teamProject.vo.UserDetailsVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Controller("reviewController")
@RequestMapping(value="/review")
public class ReviewControllerImpl implements ReviewController{

	@Autowired
	private ReviewServiceImpl reviewService;

	@Autowired
	private FtpService ftpService;

	// application.properties에 설정된 파일 업로드 경로를 주입받습니다.
	@Value("${file.upload-dir}")
	private String uploadDir;


	@RequestMapping(value = "/reviewForm")
	public ModelAndView reviewForm(@ModelAttribute ReviewVO reviewVO, HttpServletRequest req, HttpServletResponse res) throws Exception {
	    String viewName = (String) req.getAttribute("viewName");
	    ModelAndView mav = ViewUtil.layout(viewName);

	    Long reservationId = reviewVO.getReservationId();
	    Long waitingId = reviewVO.getWaitingId();
	    Long memberId = reviewVO.getMemberId();

	    System.out.println("가게 아이디 : "+reviewVO.getStoreId());

	    StoreVO storeInfo = reviewService.selectStoreInfo(reviewVO.getStoreId());

	    if(reservationId != null && reservationId != 0) {
			mav.addObject("reservationId", reservationId);
	    } else if(waitingId != null && waitingId != 0) {
	    	mav.addObject("waitingId", waitingId);
	    }

	    mav.addObject("memberId", memberId);
	    mav.addObject("review", reviewVO);
	    mav.addObject("storeInfo", storeInfo);

	    return mav;
	}

	@RequestMapping(value="/modifyReviewForm")
	public ModelAndView modifyReviewForm(@ModelAttribute ReviewVO reviewVO, HttpServletRequest req, HttpServletResponse res) throws Exception {
        String viewName = (String) req.getAttribute("viewName");
        ModelAndView mav = ViewUtil.layout(viewName);

        long reviewId = reviewVO.getReviewId();
        ReviewVO review = reviewService.getRivew(reviewId);
        List<ImageFileVO> imglist = reviewService.getImageFile(reviewId);

        long storeId = review.getStoreId();
        StoreVO store = reviewService.selectStoreInfo(storeId);

        mav.addObject("storeInfo", store);
        mav.addObject("review", review);
        mav.addObject("imglist", imglist);
        return mav;
	}
	
	@RequestMapping(value="/reviewManage")
	public ModelAndView reviewManage(@AuthenticationPrincipal UserDetailsVO userDetailsVO, @RequestParam("storeId") long storeId, HttpServletRequest req, HttpServletResponse res) throws Exception {
	    
	    String viewName = (String) req.getAttribute("viewName");
	    ModelAndView mav = ViewUtil.ownerLayout(viewName);

	    Long ownerId = (userDetailsVO != null) ? (long) userDetailsVO.getMemberVO().getMemberId() : null;

	    // 전체 리뷰
	    List<ReviewVO> reviewList = reviewService.getStoreAllReview(storeId);

	    // 매핑용 Map
	    Map<Long, ManageReviewVO> manageMap = new HashMap<>();
	    Map<Long, List<ImageFileVO>> imageMap = new HashMap<>();

	    // 상태별 리스트
	    List<ReviewVO> approvedReviewList = new ArrayList<>();
	    List<ManageReviewVO> requestedOrInProgressList = new ArrayList<>();
	    List<ManageReviewVO> rejectedList = new ArrayList<>();

	    for (ReviewVO review : reviewList) {
	        long reviewId = review.getReviewId();

	        // 이미지 세팅
	        List<ImageFileVO> imageList = reviewService.getImageFile(reviewId);
	        imageMap.put(reviewId, imageList);

	        // 검열 상태 가져오기
	        ManageReviewVO manageReview = reviewService.getReviewManageStatus(reviewId);
	        if (manageReview != null) {
	            manageMap.put(reviewId, manageReview);

	            switch (manageReview.getStatus()) {
	                case "REQUESTED":
	                case "IN_PROGRESS":
	                    requestedOrInProgressList.add(manageReview);
	                    break;
	                case "REJECTED":
	                    rejectedList.add(manageReview);
	                    break;
	                case "APPROVED":
	                    approvedReviewList.add(review); // 리뷰만 저장
	                    break;
	            }
	        }
	    }

	    // 모델 세팅
	    mav.addObject("ownerId", ownerId);
	    mav.addObject("reviewList", reviewList); // 전체 리뷰
	    mav.addObject("approvedReviewList", approvedReviewList); // 승인된 리뷰만 따로
	    mav.addObject("requestedOrInProgressList", requestedOrInProgressList);
	    mav.addObject("rejectedList", rejectedList);
	    mav.addObject("manageMap", manageMap); // reviewId → manageReviewVO
	    mav.addObject("imageMap", imageMap);   // reviewId → imageList

	    return mav;
	}

	@Override
	@PostMapping("/addReview")
	@ResponseBody
	public ModelAndView addReview(@ModelAttribute ReviewVO review, MultipartHttpServletRequest multiReq) throws Exception {
		ModelAndView mav = new ModelAndView();
		
		long regId = review.getMemberId();
		long storeId = review.getStoreId();
		long reservationId = review.getReservationId();
		long waitingId = review.getWaitingId();

		String contextPath = multiReq.getContextPath();

		try {
			long reviewId;
			
			if (reservationId != 0) {
				reviewId = reviewService.addReservationReview(review);
				System.out.println("리뷰 ID (예약): " + reviewId);
				System.out.print(reviewId);
			} else if (waitingId != 0) {
				reviewId = reviewService.addWaitingReview(review);
				System.out.println("리뷰 ID (웨이팅): " + reviewId);
			} else {
				System.out.println("예약/웨이팅 정보 누락. HTTP 400 반환.");
				mav = ViewUtil.layout("/member/mypage");
				return mav;
			}

			List<MultipartFile> files = multiReq.getFiles("reviewImage");
			System.out.println("업로드된 파일 개수: " + files.size());
			for (MultipartFile file : files) {
			    System.out.println("파일 이름: " + file.getOriginalFilename());
			}

			
			List<ImageFileVO> imgList = new ArrayList<>();

			for (MultipartFile file : files) {
				if (file.isEmpty()) continue;

				String originalFilename = file.getOriginalFilename();
				String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
				String savedFilename = UUID.randomUUID().toString() + extension;

				System.out.println(" - 원본 파일명: " + originalFilename + ", 저장 파일명: " + savedFilename);

				File tempFile = File.createTempFile("upload-", extension);
				file.transferTo(tempFile);

				boolean uploadSuccess = ftpService.uploadFile(tempFile, "review", savedFilename);
				tempFile.delete();

				ImageFileVO imageFile = new ImageFileVO();
				imageFile.setFileName(savedFilename);
				imageFile.setRegId(regId);
				imageFile.setStoreId(storeId);
				imageFile.setReviewId(reviewId);
				imageFile.setDisplayNo(imgList.size());

				imgList.add(imageFile);
			}

			if (!imgList.isEmpty()) {
			    reviewService.addReviewImageFiles(imgList);
			}

	        mav.setViewName("redirect:/member/mypage");
		    } catch (Exception e) {
		        e.printStackTrace();
		        System.out.println("예외 메시지: " + e.getMessage());
		        if(reservationId!=0) {
		        	mav.setViewName("redirect:/review/reviewForm?memberId="+regId+"&storeId="+storeId+"&reservationId="+reservationId);
		        	return mav;
		        } else if(waitingId!=0) {
		        	mav.setViewName("redirect:/review/reviewForm?memberId="+regId+"&storeId="+storeId+"&waitingId="+waitingId);
		        	return mav;
		        }
		    }
		 return mav;
	}

	@Override
	@PostMapping("/modifyReview")
	public ModelAndView modifyReview(@ModelAttribute ReviewVO review, MultipartHttpServletRequest multiReq) throws Exception {
	    String directoryName = "review";
	    ModelAndView mav = new ModelAndView();

	    long reviewId = review.getReviewId();
	    long memberId = review.getMemberId();
	    long storeId = review.getStoreId();

	    // 이미지 ID 기반 삭제 요청
	    String[] deleteFiles = multiReq.getParameterValues("deleteFiles");
	    
	    if(deleteFiles != null) {
	    	for(int i=0;i<deleteFiles.length;i++) {
	    		System.out.println("삭제할 이미지 Id" + deleteFiles[i]);
	    	}
	    }

	    // 새로 추가된 이미지 파일
	    List<MultipartFile> newFiles = multiReq.getFiles("newFiles");
	    
	    try {
	    	
	        // 1. 리뷰 본문 수정
	        reviewService.modifyReview(review);
	        System.out.println("리뷰 수정 완료");
	        
	        // 2. 삭제할 이미지 처리 (imageId 기준)
	        if (deleteFiles != null && deleteFiles.length > 0) {
	            for (String idStr : deleteFiles) {
	                if (idStr != null && !idStr.isBlank()) {
	                    try {
	                        long imageId = Long.parseLong(idStr);
	                        System.out.println("삭제 이미지 아이디 :" +imageId);

	                        // 이미지 정보 조회
	                        ImageFileVO image = reviewService.getReviewImageById(imageId);
	                        if (image != null) {
	                            // DB 삭제
	                            reviewService.deleteReviewImage(imageId);
	                            System.out.println("이미지 DB삭제 완료");

	                            // FTP 삭제
	                            ftpService.deleteFile(directoryName, image.getFileName());
	                            System.out.println("이미지 삭제 완료");
	                        }
	                    } catch (NumberFormatException e) {
	                        // 무시 또는 로그
	                        System.err.println("잘못된 이미지 ID 형식: " + idStr);
	                    }
	                }
	            }
	        }

	        // 3. 새 이미지 추가 처리
	        if (newFiles != null && !newFiles.isEmpty()) {
	        	System.out.println("이미지 추가");
	            // 기존 이미지 개수로 displayNo 계산
	            int displayNo = reviewService.getImageFile(reviewId).size();

	            for (MultipartFile file : newFiles) {
	                if (!file.isEmpty()) {
	                    String originalFilename = file.getOriginalFilename();
	                    String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
	                    String savedFilename = UUID.randomUUID().toString() + extension;

	                    // 임시 파일 저장
	                    File tempFile = File.createTempFile("upload-", extension);
	                    file.transferTo(tempFile);

	                    // FTP 업로드
	                    boolean uploaded = ftpService.uploadFile(tempFile, directoryName, savedFilename);

	                    // 임시 파일 삭제
	                    tempFile.delete();

	                    if (!uploaded) {
	                        throw new IOException("FTP 업로드 실패: " + originalFilename);
	                    }

	                    // DB 저장
	                    ImageFileVO image = new ImageFileVO();
	                    image.setReviewId(reviewId);
	                    image.setFileName(savedFilename);
	                    image.setStoreId(storeId);
	                    image.setRegId(memberId);
	                    image.setDisplayNo(++displayNo);

	                    reviewService.addReviewImage(image);
	                }
	            }
	        }

	        // 성공 시 마이페이지로 이동
	        mav.setViewName("redirect:/member/mypage");

	    } catch (Exception e) {
	        e.printStackTrace();
	        mav.setViewName("redirect:/review/modifyReviewForm?reviewId=" + reviewId);
	    }

	    return mav;
	}
	
	
	@Override
	@RequestMapping(value="/deleteReview", method=RequestMethod.POST)
	public ModelAndView deleteReview(@RequestParam("reviewId") long reviewId) throws Exception {
		ModelAndView mav = new ModelAndView();
		String directoryName = "review";

		try {
			List<ImageFileVO> imglist = reviewService.getImageFile(reviewId);

			for(int i=0;i<imglist.size();i++) {
			String fileName = imglist.get(i).getFileName();
			reviewService.deleteReviewImage(imglist.get(i).getImageId());
			ftpService.deleteFile(directoryName, fileName);
			}

			reviewService.deleteReview(reviewId);

			mav.addObject("success", true);
			mav.setViewName("redirect:/member/mypage");
		} catch (Exception e) {
			e.printStackTrace();
			mav.addObject("error", true);
			mav.setViewName("redirect:/review/modifyReviewForm?reviewId=" + reviewId);
		}

		return mav;
	}
	
	@Override
	@RequestMapping(value = "/requestReviewManage", method = RequestMethod.POST)
	public String requestReviewManage(@ModelAttribute ManageReviewVO manageReviewVO) throws Exception {

		long storeId = manageReviewVO.getStoreId();
		
	    try {
	        // 요청 상태 기본값 설정 (예: PENDING 상태)
	        manageReviewVO.setStatus("REQUESTED");

	        // 서비스 호출
	        reviewService.requestReviewManage(manageReviewVO);

	        // 성공 시 리다이렉트 또는 메시지 페이지
	        return "redirect:/review/reviewManage?storeId="+storeId; // 혹은 원하는 URL로

	    } catch (Exception e) {
	        e.printStackTrace(); // 또는 로깅 처리
	        // 실패 시 에러 페이지 혹은 다시 요청 페이지로
	        return "redirect:/review/reviewManage?storeId="+storeId;
	    }
	}

	@Override
	@RequestMapping(value = "/updateReviewManageStatus", method = RequestMethod.POST)
	public String updateReviewManageStatus(@ModelAttribute ManageReviewVO manageReviewVO) throws Exception {
		long reviewId = manageReviewVO.getReviewId();
		try {
			reviewService.updateReviewManage(manageReviewVO);
			
			if(manageReviewVO.getStatus().equals("APPROVED")) {
				System.out.println("여기");
				List<ImageFileVO> imageList = reviewService.getImageFile(reviewId);
				
				for(int i=0;i<imageList.size();i++) {
					String fileName = imageList.get(i).getFileName();
					System.out.println("지워야 하는 파일 이름 : " + fileName);
					
					reviewService.deleteReviewImage(imageList.get(i).getImageId());
					ftpService.deleteFile("review", fileName);
				}
				
				reviewService.deleteReview(reviewId);
			}
			return "redirect:/admin/adminReviewManage";
		}catch (Exception e) {
	        e.printStackTrace(); // 또는 로깅 처리
	        // 실패 시 에러 페이지 혹은 다시 요청 페이지로
	        return "redirect:/admin/adminReviewManage";
	    }
	}

	@Override
	@GetMapping("/getBestReview")
	public ResponseEntity<Map<String, Object>> getBestReview() throws Exception {
	    List<ReviewVO> reviewList = reviewService.getBestReviewList();
	    List<ImageFileVO> reviewImageList = new ArrayList<>();

	    for (int i = 0; i < reviewList.size(); i++) {
	        long reviewId = reviewList.get(i).getReviewId();
	        ImageFileVO imageVO = reviewService.getBestReviewImage(reviewId);

	        if (imageVO != null) {
	            reviewImageList.add(imageVO);  // null이 아닌 경우에만 추가
	        }
	    }

	    Map<String, Object> responseMap = new HashMap<>();
	    responseMap.put("reviewList", reviewList);
	    responseMap.put("reviewImageList", reviewImageList);

	    return ResponseEntity.ok(responseMap);
	}

	@PostMapping("/increaseLikes")
	@ResponseBody
	public Map<String, Object> increaseLikes(@RequestParam("reviewId") long reviewId, @RequestParam("memberId") long memberId) throws Exception {
	    ReviewLikeVO likeVO = new ReviewLikeVO();
	    likeVO.setMemberId(memberId);
	    likeVO.setReviewId(reviewId);

	    reviewService.increaseLike(likeVO);
	    int likeCount = reviewService.getLikeCount(reviewId);

	    Map<String, Object> response = new HashMap<>();
	    response.put("likes", likeCount);
	    return response;
	}

	@DeleteMapping("/decreaseLikes")
	@ResponseBody
	public Map<String, Object> decreaseLikes(@RequestParam("reviewId") long reviewId, @RequestParam("memberId") long memberId) throws Exception {
	    ReviewLikeVO likeVO = new ReviewLikeVO();
	    likeVO.setMemberId(memberId);
	    likeVO.setReviewId(reviewId);

	    reviewService.decreaseLike(likeVO);
	    int likeCount = reviewService.getLikeCount(reviewId);

	    Map<String, Object> response = new HashMap<>();
	    response.put("likes", likeCount);
	    return response;
	}

	@GetMapping("/isLiked")
	public ResponseEntity<Boolean> isLiked(@RequestParam("memberId") Long memberId, @RequestParam("reviewId") Long reviewId) throws Exception{
		boolean result = reviewService.isLiked(memberId, reviewId);
		return ResponseEntity.ok(result);
	}

	// 공통 메타 설정 함수
	private void populateFileMeta(ImageFileVO file, long storeId, long reviewId, long memberId, int displayNo) {
	    file.setStoreId(storeId);
	    file.setReviewId(reviewId);
	    file.setRegId(memberId);
	    file.setDisplayNo(displayNo);
	}

}
