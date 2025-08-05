package com.spring.teamProject.service;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.UUID;
import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.spring.teamProject.dao.MemberDAO;
import com.spring.teamProject.vo.MemberVO;

/**
 * MemberService 인터페이스를 구현한 클래스.
 * 회원의 비즈니스 로직(회원가입, 로그인, 정보 수정 등)을 실제로 처리합니다.
 */
@Service("memberService")
public class MemberServiceImpl implements MemberService {
    
    // MemberDAO Bean을 자동으로 주입받아 사용합니다.
    @Autowired
    private MemberDAO memberDAO;
    
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
    public void join(MemberVO memberVO) {
        saveProfileImage(memberVO);
        processPhoneNumber(memberVO);
        
        // 사용자가 입력한 비밀번호를 암호화합니다.
        String encodedPassword = passwordEncoder.encode(memberVO.getLoginPw());
        memberVO.setLoginPw(encodedPassword);
        
        memberDAO.insertMember(memberVO);
    }
    
    /**
     * 소셜 로그인 후 추가 정보를 받아 최종 회원가입 처리를 담당합니다.
     * 프로필 이미지 저장, 전화번호 포맷팅 후 DB에 저장합니다. (비밀번호 암호화 과정 없음)
     * @param memberVO 추가 정보 폼에서 넘어온 사용자 정보
     */
    @Override
    public void joinSocial(MemberVO memberVO) {
        saveProfileImage(memberVO);
        processPhoneNumber(memberVO);
        
        memberDAO.insertSocialMember(memberVO);
    }
    
    /**
     * (사용되지 않음) 스프링 시큐리티를 사용하므로, 이 메소드는 직접 호출되지 않습니다.
     */
    @Override
    public MemberVO login(MemberVO memberVO) {
        return memberDAO.login(memberVO);
    }

    /**
     * 회원 정보 수정을 처리합니다.
     * 비밀번호 변경 요청이 있을 경우, 현재 비밀번호를 검증한 후 새 비밀번호를 암호화하여 업데이트합니다.
     * @param memberVO 수정할 정보가 담긴 객체
     * @return 수정 성공 시 true, 실패(현재 비밀번호 불일치 등) 시 false
     */
    @Override
    public boolean updateMember(MemberVO memberVO) {
        // 새 비밀번호 필드에 값이 있는지 확인
        String newPassword = memberVO.getNewLoginPw();
        if (newPassword != null && !newPassword.isEmpty()) {
            // DB에서 현재 사용자의 정보를 가져옵니다.
            MemberVO currentUser = memberDAO.findById(memberVO.getMemberId());
            // 입력된 현재 비밀번호와 DB의 암호화된 비밀번호를 비교합니다.
            if (currentUser != null && passwordEncoder.matches(memberVO.getCurrentLoginPw(), currentUser.getLoginPw())) {
                // 새 비밀번호를 암호화하여 VO에 설정합니다.
                String encodedNewPassword = passwordEncoder.encode(newPassword);
                memberVO.setLoginPw(encodedNewPassword);
            } else {
                return false; // 현재 비밀번호가 일치하지 않으면 실패
            }
        }
        
        // 프로필 이미지가 새로 업로드되었으면 저장합니다.
        saveProfileImage(memberVO);
        
        // DAO를 통해 DB에 최종 업데이트하고, 성공 여부(1이면 true)를 반환합니다.
        return memberDAO.updateMember(memberVO) == 1;
    }
    
    /**
     * 회원 탈퇴를 처리합니다.
     * @param memberId 탈퇴할 회원의 ID
     * @return 탈퇴 성공 시 true, 실패 시 false
     */
    @Override
    public boolean deleteMember(long memberId) {
        return memberDAO.deleteMember(memberId) == 1;
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

    /**
     * 아이디 중복 여부를 확인합니다.
     * @param loginId 확인할 아이디
     * @return 중복된 아이디의 개수 (0 또는 1)
     */
    @Override
    public int checkIdDuplicate(String loginId) {
        return memberDAO.checkIdDuplicate(loginId);
    }

    // --- private 헬퍼 메소드 ---

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