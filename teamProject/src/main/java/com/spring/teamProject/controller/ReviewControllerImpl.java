package com.spring.teamProject.controller;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
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
import jakarta.servlet.http.HttpSession;

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
	public ResponseEntity<?> addReview(@ModelAttribute ReviewVO review, MultipartHttpServletRequest multiReq) {
		long regId = review.getMemberId();
		long storeId = review.getStoreId();
		long reservationId = review.getReservationId();
		long waitingId = review.getWaitingId();

		String contextPath = multiReq.getContextPath();

		System.out.println("---- addReview 메서드 시작 ----");
	    System.out.println("memberId: " + regId);
	    System.out.println("storeId: " + storeId);
	    System.out.println("reservationId: " + reservationId);
	    System.out.println("waitingId: " + waitingId);

		try {
			long reviewId;

			System.out.println("1. 리뷰 ID 생성 시도");
			if (reservationId != 0) {
				reviewId = reviewService.addReservationReview(review);
				System.out.println("리뷰 ID (예약): " + reviewId);
				System.out.print(reviewId);
			} else if (waitingId != 0) {
				reviewId = reviewService.addWaitingReview(review);
				System.out.println("리뷰 ID (웨이팅): " + reviewId);
			} else {
				System.out.println("예약/웨이팅 정보 누락. HTTP 400 반환.");
				return ResponseEntity.badRequest().body("예약 또는 웨이팅 정보가 누락되었습니다.");
			}

			List<MultipartFile> files = multiReq.getFiles("fileName");
			List<ImageFileVO> imgList = new ArrayList<>();

			System.out.println("2. 이미지 파일 처리 시작. 파일 수: " + files.size());
			for (MultipartFile file : files) {
				if (file.isEmpty()) {
					System.out.println(" - 빈 파일 건너뛰기");
					continue;
				}

				String originalFilename = file.getOriginalFilename();
				String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
				String savedFilename = UUID.randomUUID().toString() + extension;

				System.out.println(" - 원본 파일명: " + originalFilename + ", 저장 파일명: " + savedFilename);

				File tempFile = File.createTempFile("upload-", extension);
				file.transferTo(tempFile);

				System.out.println("3. FTP 업로드 시도");
				boolean uploadSuccess = ftpService.uploadFile(tempFile, "review", savedFilename);
				tempFile.delete();

				if (!uploadSuccess) {
					System.out.println("4. FTP 업로드 실패! 예외 발생.");
					throw new Exception("FTP 업로드 실패");
				}
				System.out.println("4. FTP 업로드 성공.");

				ImageFileVO imageFile = new ImageFileVO();
				imageFile.setFileName(savedFilename);
				imageFile.setRegId(regId);
				imageFile.setStoreId(storeId);
				imageFile.setReviewId(reviewId);
				imageFile.setDisplayNo(imgList.size());

				imgList.add(imageFile);
				System.out.println(" - 이미지 VO 리스트에 추가");
			}

			System.out.println("5. 이미지 DB 저장 시도. 이미지 수: " + imgList.size());
			if (!imgList.isEmpty()) {
			    reviewService.addReviewImageFiles(imgList);
			}

			// HTTP 응답 헤더를 설정하여 JSON임을 명시합니다.
	        HttpHeaders headers = new HttpHeaders();
	        headers.setContentType(MediaType.APPLICATION_JSON);

	        System.out.println("6. 최종 성공 응답 반환");
	        return new ResponseEntity<>(Map.of(
	                "success", true,
	                "message", "리뷰가 성공적으로 등록되었습니다."
	            ), headers, HttpStatus.OK);

		    } catch (Exception e) {
		    	System.out.println("---- catch 블록 실행됨! ----");
		        e.printStackTrace();
		        System.out.println("예외 메시지: " + e.getMessage());
		        return ResponseEntity.internalServerError().body(Map.of( "error", true, "message", "리뷰 등록 중 오류 발생"  ));
		    }
	}

	@Override
	@PostMapping("/modifyReview")
	public ResponseEntity<?> modifyReview(@ModelAttribute ReviewVO review, MultipartHttpServletRequest multiReq) throws Exception {
	    String directoryName = "review";

	    long reviewId = review.getReviewId();
	    long memberId = review.getMemberId();
	    long storeId = review.getStoreId();

	    String[] deleteFileNames = multiReq.getParameterValues("deleteFileName");

	    List<ImageFileVO> addedFiles = new ArrayList<>();
	    Iterator<String> fileNames = multiReq.getFileNames();

	    while (fileNames.hasNext()) {
	        String fileName = fileNames.next();
	        List<MultipartFile> files = multiReq.getFiles(fileName);

	        for (MultipartFile mf : files) {
	            if (!mf.isEmpty()) {
	                // 기존 파일명에서 확장자를 추출하고, UUID로 고유한 파일명 생성
	                String originalFilename = mf.getOriginalFilename();
	                String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
	                String savedFilename = UUID.randomUUID().toString() + extension;

	                File tempFile = File.createTempFile("upload-", extension);
	                mf.transferTo(tempFile);

	                // FTP 업로드 시 UUID로 생성된 고유 파일명 사용
	                boolean uploadResult = ftpService.uploadFile(tempFile, directoryName, savedFilename);

	                if (uploadResult) {
	                    ImageFileVO fileVO = new ImageFileVO();
	                    // ImageFileVO에 고유한 파일명(savedFilename) 저장
	                    fileVO.setFileName(savedFilename);
	                    addedFiles.add(fileVO);
	                } else {
	                    tempFile.delete();
	                    throw new IOException("FTP 업로드 실패: " + originalFilename);
	                }
	                tempFile.delete();
	            }
	        }
	    }

	    int deleteCount = deleteFileNames != null ? deleteFileNames.length : 0;
	    int addCount = addedFiles.size();

	    try {
	        reviewService.modifyReview(review);

	        int displayNo = 5 - deleteCount;

	        if (deleteCount > 0 && addCount > 0) {
	            int min = Math.min(deleteCount, addCount);

	            for (int i = 0; i < min; i++) {
	                ImageFileVO oldFile = new ImageFileVO();
	                String oldFileName = deleteFileNames[i];
	                oldFile.setFileName(oldFileName);
	                oldFile.setReviewId(reviewId);
	                long imageId = reviewService.getImageId(oldFile);
	                ImageFileVO newFile = addedFiles.get(i);
	                newFile.setImageId(imageId);
	                newFile.setReviewId(reviewId);
	                reviewService.modifyReviewImage(newFile);
	                ftpService.deleteFile(directoryName, oldFileName);
	            }

	            for (int i = min; i < addCount; i++) {
	                ImageFileVO newFile = addedFiles.get(i);
	                populateFileMeta(newFile, storeId, reviewId, memberId, displayNo++);
	                reviewService.addReviewImage(newFile);
	            }

	            for (int i = min; i < deleteCount; i++) {
	                String oldFileName = deleteFileNames[i];
	                reviewService.deleteReviewImage(oldFileName);
	                ftpService.deleteFile(directoryName, oldFileName);
	            }
	        } else if (deleteCount > 0) {
	            for (String fileName : deleteFileNames) {
	                reviewService.deleteReviewImage(fileName);
	                ftpService.deleteFile(directoryName, fileName);
	            }

	        } else if (addCount > 0) {
	            for (ImageFileVO newFile : addedFiles) {
	                populateFileMeta(newFile, storeId, reviewId, memberId, displayNo++);
	                reviewService.addReviewImage(newFile);
	            }
	        }

	        return ResponseEntity.ok().body(Map.of(
	            "status", "success",
	            "reviewId", reviewId,
	            "memberId", memberId
	        ));
	    } catch (Exception e) {
	        e.printStackTrace();
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
	            "status", "error",
	            "message", "리뷰 수정 중 오류 발생"
	        ));
	    }
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

		if(result) {
			System.out.println("리뷰 좋아요 누름");
		} else {
			System.out.println("리뷰 좋아요 안누름");
		}
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
