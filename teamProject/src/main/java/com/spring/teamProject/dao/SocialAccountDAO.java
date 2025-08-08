package com.spring.teamProject.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.teamProject.vo.SocialAccountVO;

import java.util.List;

@Mapper
public interface SocialAccountDAO {

    /**
     * provider와 socialId로 소셜 계정 정보를 조회합니다. (로그인 시 사용)
     * @param provider 소셜 서비스 제공자 (예: GOOGLE)
     * @param socialId 해당 소셜 서비스의 고유 ID
     * @return SocialAccountVO
     */
    SocialAccountVO findByProviderAndSocialId(@Param("provider") String provider, @Param("socialId") String socialId);

    /**
     * 특정 회원의 모든 소셜 연동 계정 목록을 조회합니다.
     * @param memberId 회원 ID
     * @return List<SocialAccountVO>
     */
    List<SocialAccountVO> findByMemberId(long memberId);

    /**
     * 새로운 소셜 계정 연동 정보를 저장합니다.
     * @param socialAccountVO 연동할 소셜 계정 정보
     */
    void insertSocialAccount(SocialAccountVO socialAccountVO);
}
