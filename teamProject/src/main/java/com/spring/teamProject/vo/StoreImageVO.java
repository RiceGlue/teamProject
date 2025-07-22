package com.spring.teamProject.vo;

public class StoreImageVO {
	private String image_id;
	private String store_id;
	private String image_url;
	private boolean image_type;
	private int display_no;
	private String created_at;
	
	
	public String getImage_id() {
		return image_id;
	}
	public void setImage_id(String image_id) {
		this.image_id = image_id;
	}
	public String getStore_id() {
		return store_id;
	}
	public void setStore_id(String store_id) {
		this.store_id = store_id;
	}
	public String getImage_url() {
		return image_url;
	}
	public void setImage_url(String image_url) {
		this.image_url = image_url;
	}
	public boolean isImage_type() {
		return image_type;
	}
	public void setImage_type(boolean image_type) {
		this.image_type = image_type;
	}
	public int getDisplay_no() {
		return display_no;
	}
	public void setDisplay_no(int display_no) {
		this.display_no = display_no;
	}
	public String getCreated_at() {
		return created_at;
	}
	public void setCreated_at(String created_at) {
		this.created_at = created_at;
	}
	
}
