package com.spring.teamProject.vo;

import java.util.Date;

public class SocialAccountVO {

    private long socialAccountId;
    private long memberId;
    private String provider;
    private String socialId;
    private Date createdAt;

    // Getters and Setters
    public long getSocialAccountId() {
        return socialAccountId;
    }
    public void setSocialAccountId(long socialAccountId) {
        this.socialAccountId = socialAccountId;
    }
    public long getMemberId() {
        return memberId;
    }
    public void setMemberId(long memberId) {
        this.memberId = memberId;
    }
    public String getProvider() {
        return provider;
    }
    public void setProvider(String provider) {
        this.provider = provider;
    }
    public String getSocialId() {
        return socialId;
    }
    public void setSocialId(String socialId) {
        this.socialId = socialId;
    }
    public Date getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
}
