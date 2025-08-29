package com.spring.teamProject.controller;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
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
import com.spring.teamProject.vo.ReviewLikeVO;
import com.spring.teamProject.vo.ReviewVO;
import com.spring.teamProject.vo.StoreVO;

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

	    // 기존 이미지 배열
	    String[] existingFileNames = multiReq.getParameterValues("existingFileNames");

	    // 삭제할 이미지 배열
	    String[] deleteFileNames = multiReq.getParameterValues("deleteFileNames");
	    boolean hasFilesToDelete = (deleteFileNames != null && deleteFileNames.length > 0);

	    // 새로 추가된 파일
	    List<MultipartFile> newFiles = multiReq.getFiles("newFiles");
	    boolean hasFilesToAdd = (newFiles != null && !newFiles.isEmpty() && !newFiles.get(0).isEmpty());

	    try {
	        // ✅ 조건 1: 이미지 변경 없이 본문만 수정
	        if (!hasFilesToDelete && !hasFilesToAdd) {
	            reviewService.modifyReview(review);
	            mav.setViewName("redirect:/member/mypage");
	            return mav;
	        }

	        // ✅ 모든 경우 리뷰 본문은 수정
	        reviewService.modifyReview(review);

	        // ✅ 조건 3 or 4: 삭제할 파일 처리 (기존 이미지 배열에 존재할 경우만)
	        if (hasFilesToDelete && existingFileNames != null) {
	            for(int i=0;i<existingFileNames.length;i++) {
	            	if(existingFileNames[i].equals(deleteFileNames[i])) {
	            		reviewService.deleteReviewImage(existingFileNames[i]);
	            	}
	            }
	        }

	        // ✅ 조건 2 or 4: 이미지 추가
	        if (hasFilesToAdd) {
	            // 현재 남아 있는 이미지 개수 → displayNo 설정
	            List<ImageFileVO> remainingImages = reviewService.getImageFile(reviewId);
	            int displayNo = remainingImages.size();

	            for (MultipartFile file : newFiles) {
	                if (!file.isEmpty()) {
	                    String originalFilename = file.getOriginalFilename();
	                    String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
	                    String savedFilename = UUID.randomUUID().toString() + extension;
	                    
	                    File tempFile = File.createTempFile("upload-", extension);
	    				file.transferTo(tempFile);

	    				boolean uploaded = ftpService.uploadFile(tempFile, directoryName, savedFilename);
	                    if (!uploaded) {
	                        throw new IOException("FTP 업로드 실패: " + originalFilename);
	                    }
	                    
	                    tempFile.delete();

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
			reviewService.deleteReviewImage(fileName);
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
