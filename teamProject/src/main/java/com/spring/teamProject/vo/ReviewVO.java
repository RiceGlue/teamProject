package com.spring.teamProject.vo;

import java.util.Date;

public class ReviewVO {

	private long reviewId;
	private long memberId;
	private String writerId;
	private long storeId;
	private long reservationId;
	private long waitingId;
	
	private int rating;
	private String content;
	private Date createdAt;
	private Date updatedAt;
	
	private int avgRating;
	private int countRating;
	private int countScoreRating;
	
	private int taste;
	private int mood;
	private int service;
	private int clean;
	
	public long getReviewId() {
		return reviewId;
	}
	public void setReviewId(long reviewId) {
		this.reviewId = reviewId;
	}
	public long getMemberId() {
		return memberId;
	}
	public void setMemberId(long memberId) {
		this.memberId = memberId;
	}
	public String getWriterId() {
		return writerId;
	}
	public void setWriterId(String writerId) {
		this.writerId = writerId;
	}
	public long getStoreId() {
		return storeId;
	}
	public void setStoreId(long storeId) {
		this.storeId = storeId;
	}
	public long getReservationId() {
		return reservationId;
	}
	public void setReservationId(long reservationId) {
		this.reservationId = reservationId;
	}
	public long getWaitingId() {
		return waitingId;
	}
	public void setWaitingId(long waitingId) {
		this.waitingId = waitingId;
	}
	public int getRating() {
		return rating;
	}
	public void setRating(int rating) {
		this.rating = rating;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public Date getCreatedAt() {
		return createdAt;
	}
	public void setCreatedAt(Date createdAt) {
		this.createdAt = createdAt;
	}
	public Date getUpdatedAt() {
		return updatedAt;
	}
	public void setUpdatedAt(Date updatedAt) {
		this.updatedAt = updatedAt;
	}
	public int getAvgRating() {
		return avgRating;
	}
	public void setAvgRating(int avgRating) {
		this.avgRating = avgRating;
	}
	public int getCountRating() {
		return countRating;
	}
	public void setCountRating(int countRating) {
		this.countRating = countRating;
	}
	public int getCountScoreRating() {
		return countScoreRating;
	}
	public void setCountScoreRating(int countScoreRating) {
		this.countScoreRating = countScoreRating;
	}
	public int getTaste() {
		return taste;
	}
	public void setTaste(int taste) {
		this.taste = taste;
	}
	public int getMood() {
		return mood;
	}
	public void setMood(int mood) {
		this.mood = mood;
	}
	public int getService() {
		return service;
	}
	public void setService(int service) {
		this.service = service;
	}
	public int getClean() {
		return clean;
	}
	public void setClean(int clean) {
		this.clean = clean;
	}
	
}
