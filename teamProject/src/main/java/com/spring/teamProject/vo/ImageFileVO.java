package com.spring.teamProject.vo;

import java.util.Date;

public class ImageFileVO {
	
	//이미지 고유 아이디
	private long imageId;
	
	//가게,리뷰 고유 아이디
	private long storeId;
	private long reviewId;
	
	//파일 이름
	private String fileName;
	
	//파일 타입 true-main, false-sub
	private boolean fileType;
	
	//화면 출력 번호 (낮을수록 먼저 출력(오름차순))
	private int displayNo;
	private Date createdAt;
	
	//파일 생성 회원 고유 아이디
	private long regId;

	public long getImageId() {
		return imageId;
	}

	public void setImageId(long imageId) {
		this.imageId = imageId;
	}

	public long getStoreId() {
		return storeId;
	}

	public void setStoreId(long storeId) {
		this.storeId = storeId;
	}

	public long getReviewId() {
		return reviewId;
	}

	public void setReviewId(int reviewId) {
		this.reviewId = reviewId;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public boolean isFileType() {
		return fileType;
	}

	public void setFileType(boolean fileType) {
		this.fileType = fileType;
	}

	public int getDisplayNo() {
		return displayNo;
	}

	public void setDisplayNo(int displayNo) {
		this.displayNo = displayNo;
	}

	public Date getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Date createdAt) {
		this.createdAt = createdAt;
	}

	public long getRegId() {
		return regId;
	}

	public void setRegId(long regId) {
		this.regId = regId;
	}

}
