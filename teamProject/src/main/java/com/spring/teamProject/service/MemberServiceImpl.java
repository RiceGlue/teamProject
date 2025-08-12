package com.spring.teamProject.service;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;
import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import com.spring.teamProject.dao.MemberDAO;
import com.spring.teamProject.dao.SocialAccountDAO;
import com.spring.teamProject.vo.MemberVO;
import com.spring.teamProject.vo.SocialAccountVO;

/**
 * MemberService 인터페이스를 구현한 클래스.
 * 회원의 비즈니스 로직(회원가입, 로그인, 정보 수정 등)을 실제로 처리합니다.
 */
@Service("memberService")
public class MemberServiceImpl implements MemberService {
    
    // MemberDAO Bean을 자동으로 주입받아 사용합니다.
    @Autowired
    private MemberDAO memberDAO;

    @Autowired
    private SocialAccountDAO socialAccountDAO;
    
    // SecurityConfig에 Bean으로 등록된 PasswordEncoder를 자동으로 주입받아 사용합니다.
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    // application.properties에 설정된 파일 업로드 경로를 주입받습니다.
    @Value("${file.upload-dir}")
    private String uploadDir;
    
    /**
     * 일반 회원가입 처리를 담당합니다.
     * 프로필 이미지 저장, 전화번호 포맷팅, 비밀번호 암호화 후 DB에 저장합니다.
     * @param memberVO 회원가입 폼에서 넘어온 사용자 정보
     */
    @Override
    @Transactional
    public void join(MemberVO memberVO) {
        saveProfileImage(memberVO);
        processPhoneNumber(memberVO);
        
        if (StringUtils.hasText(memberVO.getLoginPw())) {
            String encodedPassword = passwordEncoder.encode(memberVO.getLoginPw());
            memberVO.setLoginPw(encodedPassword);
        }
        
        memberDAO.insertMember(memberVO);
        
        if (memberVO.getSocialAccounts() != null && !memberVO.getSocialAccounts().isEmpty()) {
            for (SocialAccountVO socialAccount : memberVO.getSocialAccounts()) {
                socialAccount.setMemberId(memberVO.getMemberId());
                socialAccountDAO.insertSocialAccount(socialAccount);
            }
        }
    }
    
    /**
     * (사용되지 않음) 스프링 시큐리티를 사용하므로, 이 메소드는 직접 호출되지 않습니다.
     */
    @Override
    public MemberVO login(MemberVO memberVO) {
        return memberDAO.login(memberVO);
    }

    /**
     * (수정) 회원 정보 수정 로직을 안전하게 변경합니다.
     * 1. DB에서 현재 사용자 정보를 불러옵니다.
     * 2. 폼에서 제출된 새로운 값들만 기존 정보 위에 덮어씁니다.
     * 3. 이렇게 하면 폼에 없던 정보나 수정되지 않은 정보가 유실되지 않습니다.
     * @param updatedInfoVO 수정할 정보가 담긴 객체
     * @return 수정 성공 시 true, 실패 시 false
     */
    @Override
    public boolean updateMember(MemberVO updatedInfoVO) {
        // 1. DB에서 현재 사용자의 온전한 정보를 가져옵니다.
        MemberVO currentUser = memberDAO.findById(updatedInfoVO.getMemberId());
        if (currentUser == null) {
            return false; // 사용자가 없으면 실패
        }

        // 2. 비밀번호 변경 로직: 새 비밀번호가 입력되었을 때만 실행
        String newPassword = updatedInfoVO.getNewLoginPw();
        if (StringUtils.hasText(newPassword)) {
            // 소셜 로그인 사용자는 비밀번호가 없으므로 이 로직을 건너뜁니다.
            if (currentUser.getLoginPw() != null && passwordEncoder.matches(updatedInfoVO.getCurrentLoginPw(), currentUser.getLoginPw())) {
                String encodedNewPassword = passwordEncoder.encode(newPassword);
                currentUser.setLoginPw(encodedNewPassword);
            } else if (currentUser.getLoginPw() == null) {
                // 소셜 로그인 사용자가 비밀번호를 설정하려는 경우 (향후 기능)
                // 현재는 아무 작업도 하지 않음
            }
            else {
                return false; // 현재 비밀번호가 일치하지 않으면 실패
            }
        }
        
        // 3. 폼에서 넘어온 다른 정보들을 currentUser 객체에 덮어씁니다.
        currentUser.setMemberName(updatedInfoVO.getMemberName());
        currentUser.setEmail(updatedInfoVO.getEmail());
        currentUser.setCountryCode(updatedInfoVO.getCountryCode());
        currentUser.setPhone(updatedInfoVO.getPhone());
        
        // 3-1. 전화번호 포맷팅 (하이픈 제거 등)
        processPhoneNumber(currentUser);
        
        currentUser.setAgreeEmail(updatedInfoVO.isAgreeEmail());
        currentUser.setAgreeSms(updatedInfoVO.isAgreeSms());
        currentUser.setAgreeKakao(updatedInfoVO.isAgreeKakao());
        
        // 4. 프로필 이미지가 새로 업로드되었으면 저장하고 URL을 설정합니다.
        currentUser.setProfileImageFile(updatedInfoVO.getProfileImageFile());
        saveProfileImage(currentUser);
        
        // 5. 최종적으로 모든 정보가 업데이트된 currentUser 객체를 DB에 전달합니다.
        return memberDAO.updateMember(currentUser) == 1;
    }
    
    /**
     * 회원 탈퇴를 처리합니다.
     * @param memberId 탈퇴할 회원의 ID
     * @return 탈퇴 성공 시 true, 실패 시 false
     */
    @Override
    public boolean deactivateMember(long memberId) {
        return memberDAO.deactivateMember(memberId) == 1;
    }

    @Override
    public List<MemberVO> findOwners() {
        return memberDAO.findOwners();
    }

    /**
     * [신규] 역할(role)이 'USER'인 모든 회원 목록을 조회합니다.
     */
    @Override
    public List<MemberVO> findUsers() {
        return memberDAO.findUsers();
    }

    /**
     * 이메일 주소로 회원 정보를 조회합니다. (주로 소셜 로그인 시 사용)
     * @param email 조회할 이메일
     * @return 조회된 MemberVO 객체, 없으면 null
     */
    @Override
    public MemberVO findByEmail(String email) {
        return memberDAO.findByEmail(email);
    }

    // findById 메소드 구현
    @Override
    public MemberVO findById(long memberId) {
        return memberDAO.findById(memberId);
    }

    /**
     * 아이디 중복 여부를 확인합니다.
     * @param loginId 확인할 아이디
     * @return 중복된 아이디의 개수 (0 또는 1)
     */
    @Override
    public int checkIdDuplicate(String loginId) {
        return memberDAO.checkIdDuplicate(loginId);
    }

    /**
     * 소셜 계정 연동 해제 로직 구현
     */
    @Override
    @Transactional
    public boolean unlinkSocialAccount(long memberId, String provider) {
        MemberVO member = memberDAO.findById(memberId);

        // 안전장치: 비밀번호가 없고, 연동된 소셜 계정이 1개뿐이면 해제 불가
        if (!StringUtils.hasText(member.getLoginPw()) && member.getSocialAccounts() != null && member.getSocialAccounts().size() <= 1) {
            return false; // 마지막 로그인 수단이므로 실패 처리
        }

        socialAccountDAO.deleteSocialAccount(memberId, provider);
        return true;
    }

    /**
     * 프로필 이미지 파일을 서버에 저장하고, 접근 가능한 URL을 MemberVO에 설정합니다.
     * @param memberVO 이미지 파일이 포함된 MemberVO 객체
     */
    private void saveProfileImage(MemberVO memberVO) {
        MultipartFile file = memberVO.getProfileImageFile();
        if (file != null && !file.isEmpty()) {
            
            // 1. 서버 측 파일 크기 검사
            long maxSizeInBytes = 2 * 1024 * 1024; // 2MB
            if (file.getSize() > maxSizeInBytes) {
                throw new RuntimeException("프로필 사진은 2MB를 초과할 수 없습니다.");
            }

            try {
                // 2. 서버 측 해상도 검사
                BufferedImage image = ImageIO.read(file.getInputStream());
                if (image == null) {
                    // 이미지 파일이 아닌 경우
                    throw new RuntimeException("올바른 이미지 파일이 아닙니다.");
                }
                int width = image.getWidth();
                int height = image.getHeight();
                int maxResolution = 500; // 최대 해상도 500px

                if (width > maxResolution || height > maxResolution) {
                    throw new RuntimeException("프로필 사진의 해상도는 500x500 픽셀을 초과할 수 없습니다.");
                }

                // 3. 파일 저장 로직
                String originalFilename = file.getOriginalFilename();
                String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
                String savedFilename = UUID.randomUUID().toString() + extension;

                File dest = new File(uploadDir + savedFilename);
                // ImageIO.read()로 inputStream을 한 번 사용했으므로, 파일을 다시 저장해야 합니다.
                file.transferTo(dest);

                memberVO.setProfileImageUrl("/profile-images/" + savedFilename);

            } catch (IOException e) {
                e.printStackTrace();
                throw new RuntimeException("프로필 사진 저장에 실패했습니다.", e);
            }
        }
    }
    
    /**
     * 전화번호에서 불필요한 문자를 제거하고, 한국 번호의 경우 앞자리 '0'을 제거합니다.
     * @param memberVO 전화번호와 국가 코드가 포함된 MemberVO 객체
     */
    private void processPhoneNumber(MemberVO memberVO) {
        if (memberVO.getPhone() != null && memberVO.getCountryCode() != null) {
            String cleanPhoneNumber = memberVO.getPhone().replaceAll("[^0-9]", "");
            if ("82".equals(memberVO.getCountryCode()) && cleanPhoneNumber.startsWith("0")) {
                cleanPhoneNumber = cleanPhoneNumber.substring(1);
            }
            memberVO.setPhone(cleanPhoneNumber);
        }
    }
}
