package com.spring.teamProject.vo;

import java.util.Date;

public class MemberVO {
	
	private int member_id;
	private String login_id;
	private String login_pw;
	
	// 소셜 로그인 필드 추가
	private String socialProvider;
	private String socialId;

	private String member_name;
	private String birth;
	private String sex;
	private String phone;
	private String email;
	private String role;
	
	// DB의 DATETIME 타입은 java.util.Date로 매핑
	private String created_at;
	private String updated_at;
	
	public int getMember_id() {
		return member_id;
	}
	public void setMember_id(int member_id) {
		this.member_id = member_id;
	}
	public String getLogin_id() {
		return login_id;
	}
	public void setLogin_id(String login_id) {
		this.login_id = login_id;
	}
	public String getLogin_pw() {
		return login_pw;
	}
	public void setLogin_pw(String login_pw) {
		this.login_pw = login_pw;
	}
	public String getSocialProvider() {
		return socialProvider;
	}
	public void setSocialProvider(String socialProvider) {
		this.socialProvider = socialProvider;
	}
	public String getSocialId() {
		return socialId;
	}
	public void setSocialId(String socialId) {
		this.socialId = socialId;
	}
	public String getMember_name() {
		return member_name;
	}
	public void setName(String member_name) {
		this.member_name = member_name;
	}
	public String getBirth() {
		return birth;
	}
	public void setBirth(String birth) {
		this.birth = birth;
	}
	public String getSex() {
		return sex;
	}
	public void setSex(String sex) {
		this.sex = sex;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getRole() {
		return role;
	}
	public void setRole(String role) {
		this.role = role;
	}
	public String getCreated_at() {
		return created_at;
	}
	public void setCreated_at(String created_at) {
		this.created_at = created_at;
	}
	public String getUpdated_at() {
		return updated_at;
	}
	public void setUpdated_at(String updated_at) {
		this.updated_at = updated_at;
	}
	
	

}
