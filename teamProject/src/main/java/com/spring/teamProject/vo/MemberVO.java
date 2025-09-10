package com.spring.teamProject.vo;

import java.util.Date;
import java.util.List; // List import 추가

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.multipart.MultipartFile;

public class MemberVO {
    
    private long memberId;
    private String loginId;
    private String loginPw;
    
    // [삭제] 소셜 로그인 필드 제거
    // private String socialProvider;
    // private String socialId;

    private String memberName;
    
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date birth;
    private String sex;
    private String phone;
    private String email;
    private String role;
    
    private String profileImageUrl;
    private double mannerTemperature;
    
    private boolean agreeEmail;
    private boolean agreeSms;
    private boolean agreeKakao;
    
    // [신규] 회원 상태(논리적 삭제용) 필드 추가
    private String status;
    
    private Date createdAt;
    private Date updatedAt;
    
    private String countryCode;
    
    private MultipartFile profileImageFile;
    
    private String currentLoginPw;
    private String newLoginPw;

    // [추가] 로그인 실패 횟수를 담을 필드
    private int loginFailCount;

    // [신규] 연동된 소셜 계정 목록을 담을 리스트 추가
    private List<SocialAccountVO> socialAccounts;

    // --- Getters and Setters ---
    
    public long getMemberId() {
        return memberId;
    }
    public void setMemberId(long memberId) {
        this.memberId = memberId;
    }
    public String getLoginId() {
        return loginId;
    }
    public void setLoginId(String loginId) {
        this.loginId = loginId;
    }
    public String getLoginPw() {
        return loginPw;
    }
    public void setLoginPw(String loginPw) {
        this.loginPw = loginPw;
    }
    public String getMemberName() {
        return memberName;
    }
    public void setMemberName(String memberName) {
        this.memberName = memberName;
    }
    public Date getBirth() {
        return birth;
    }
    public void setBirth(Date birth) {
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
    public String getProfileImageUrl() {
        return profileImageUrl;
    }
    public void setProfileImageUrl(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }
    public double getMannerTemperature() {
        return mannerTemperature;
    }
    public void setMannerTemperature(double mannerTemperature) {
        this.mannerTemperature = mannerTemperature;
    }
    public boolean isAgreeEmail() {
        return agreeEmail;
    }
    public void setAgreeEmail(boolean agreeEmail) {
        this.agreeEmail = agreeEmail;
    }
    public boolean isAgreeSms() {
        return agreeSms;
    }
    public void setAgreeSms(boolean agreeSms) {
        this.agreeSms = agreeSms;
    }
    public boolean isAgreeKakao() {
        return agreeKakao;
    }
    public void setAgreeKakao(boolean agreeKakao) {
        this.agreeKakao = agreeKakao;
    }
    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
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
    public String getCountryCode() {
        return countryCode;
    }
    public void setCountryCode(String countryCode) {
        this.countryCode = countryCode;
    }
    public MultipartFile getProfileImageFile() {
        return profileImageFile;
    }
    public void setProfileImageFile(MultipartFile profileImageFile) {
        this.profileImageFile = profileImageFile;
    }
    public String getCurrentLoginPw() {
        return currentLoginPw;
    }
    public void setCurrentLoginPw(String currentLoginPw) {
        this.currentLoginPw = currentLoginPw;
    }
    public String getNewLoginPw() {
        return newLoginPw;
    }
    public void setNewLoginPw(String newLoginPw) {
        this.newLoginPw = newLoginPw;
    }
    
    // [추가] loginFailCount 필드의 Getter/Setter
    public int getLoginFailCount() {
        return loginFailCount;
    }
    public void setLoginFailCount(int loginFailCount) {
        this.loginFailCount = loginFailCount;
    }

    public List<SocialAccountVO> getSocialAccounts() {
        return socialAccounts;
    }
    public void setSocialAccounts(List<SocialAccountVO> socialAccounts) {
        this.socialAccounts = socialAccounts;
    }
}
