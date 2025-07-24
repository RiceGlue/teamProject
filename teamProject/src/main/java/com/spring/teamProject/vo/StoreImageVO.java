package com.spring.teamProject.vo;

import java.util.Date;

public class StoreImageVO {
	private long imageId;
	private long storeId;
	private String imageUrl;
	private boolean imageType;
	private int displayNo;
	private Date createdAt;
	
	
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
	public String getImageUrl() {
		return imageUrl;
	}
	public void setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}
	public boolean isImageType() {
		return imageType;
	}
	public void setImageType(boolean imageType) {
		this.imageType = imageType;
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
}
