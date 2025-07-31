package com.spring.teamProject.vo;

import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.multipart.MultipartFile;

public class MemberVO {
	
	private long memberId;
	private String loginId;
	private String loginPw;
	
	// 소셜 로그인 필드 추가
	private String socialProvider;
	private String socialId;

	private String memberName;
	
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private Date birth;
	private String sex;
	private String phone;
	private String email;
	private String role;
	
	// 프로필 이미지, 매너온도 필드 추가
	private String profileImageUrl;
	private double mannerTemperature;
	
    // (신규) 알림 수신 동의 필드 추가
    private boolean agreeEmail;
    private boolean agreeSms;
    private boolean agreeKakao;
	
	// DB의 DATETIME 타입은 java.util.Date로 매핑
	private Date createdAt;
	private Date updatedAt;
	
	//국가코드
	private String countryCode;
	
    // (신규) 프로필 이미지 파일 업로드를 위한 필드 (DB에는 저장되지 않음)
    private MultipartFile profileImageFile;
	
    // (신규) 폼 데이터 전송용 임시 필드
    private String currentLoginPw;
    private String newLoginPw;
    
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
}
