package com.spring.teamProject.service;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;
import javax.imageio.ImageIO;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.authentication.BadCredentialsException;
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
        // ? --- 여기가 핵심 수정 부분입니다 --- ?
        // 1. DB에 저장하기 전, 이메일이 이미 존재하는지 먼저 확인합니다.
        MemberVO existingMember = memberDAO.findByEmail(memberVO.getEmail());
        if (existingMember != null) {
            // 2. 이메일이 존재할 경우, 해당 계정이 비밀번호가 없는 '소셜 전용 계정'인지 확인합니다.
            if (!StringUtils.hasText(existingMember.getLoginPw())) {
                // 3. 소셜 전용 계정이라면, 더 명확한 오류 메시지를 담은 예외를 발생시킵니다.
                throw new IllegalArgumentException("이미 소셜 계정으로 가입된 이메일입니다. 해당 소셜 로그인을 이용해주세요.");
            }
        }
        
        // (기존 로직)
        validatePhoneNumber(memberVO);
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

    @Override
    public MemberVO login(MemberVO memberVO) {
        return memberDAO.login(memberVO);
    }

    @Override
    public boolean updateMember(MemberVO updatedInfoVO) {
        // DB에 저장하기 전, 전화번호 유효성을 먼저 검사합니다.
        validatePhoneNumber(updatedInfoVO);

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
                // 소셜 로그인 사용자가 비밀번호를 설정하려는 경우 (현재는 setPasswordForSocialUser에서 처리)
            } else {
                return false; // 현재 비밀번호 불일치
            }
        }
        
        // 3. 폼에서 넘어온 다른 정보들을 currentUser 객체에 덮어씁니다.
        currentUser.setMemberName(updatedInfoVO.getMemberName());
        
        // 기존 회원의 비밀번호가 있는 경우(일반 회원 또는 전환된 회원)에만 이메일 변경을 허용합니다.
        if (StringUtils.hasText(currentUser.getLoginPw())) {
            currentUser.setEmail(updatedInfoVO.getEmail());
        }
        
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
     * 역할(role)이 'OWNER'인 모든 회원 목록을 조회합니다.
     */
    @Override
    public List<MemberVO> findOwners() {
        return memberDAO.findOwners();
    }

    /**
     * 역할(role)이 'USER'인 모든 회원 목록을 조회합니다.
     */
    @Override
    public List<MemberVO> findUsers() {
        return memberDAO.findUsers();
    }

    // 소셜 전용 회원의 아이디/비밀번호 설정 (일반 계정 전환) 로직 구현
    @Override
    @Transactional
    public boolean setPasswordForSocialUser(long memberId, String loginId, String newPassword) {
        // 1. 아이디 중복 확인
        if (memberDAO.checkIdDuplicate(loginId) > 0) {
            throw new DuplicateKeyException("이미 사용 중인 아이디입니다.");
        }

        // 2. 비밀번호 암호화
        String encodedPassword = passwordEncoder.encode(newPassword);

        // 3. MemberVO 객체 생성 및 DB 업데이트
        MemberVO memberVO = new MemberVO();
        memberVO.setMemberId(memberId);
        memberVO.setLoginId(loginId);
        memberVO.setLoginPw(encodedPassword);
        
        return memberDAO.updateLoginCredentials(memberVO) == 1;
    }
    
    // 아이디와 비밀번호 확인 후 소셜 계정 연동 로직 구현
    @Override
    @Transactional
    public MemberVO verifyIdAndPasswordAndLinkAccount(String email, String loginId, String rawPassword, String provider, String socialId) {
        // 1. 이메일로 기존 회원 정보를 가져옵니다.
        MemberVO member = memberDAO.findByEmail(email);
        if (member == null) {
            throw new BadCredentialsException("사용자 정보를 찾을 수 없습니다.");
        }

        // 2. 입력된 아이디가 DB의 아이디와 일치하는지 확인합니다.
        if (!loginId.equals(member.getLoginId())) {
            throw new BadCredentialsException("아이디 또는 비밀번호가 일치하지 않습니다.");
        }

        // 3. 입력된 비밀번호와 DB의 암호화된 비밀번호를 비교합니다.
        if (passwordEncoder.matches(rawPassword, member.getLoginPw())) {
            // 4. 비밀번호가 일치하면, 새로운 소셜 계정 정보를 생성하고 DB에 저장합니다.
            SocialAccountVO newSocialAccount = new SocialAccountVO();
            newSocialAccount.setMemberId(member.getMemberId());
            newSocialAccount.setProvider(provider);
            newSocialAccount.setSocialId(socialId);
            socialAccountDAO.insertSocialAccount(newSocialAccount);
            
            // 5. 연동이 완료된 최신 회원 정보를 반환합니다.
            return memberDAO.findById(member.getMemberId());
        } else {
            // 6. 비밀번호가 일치하지 않으면 예외를 발생시킵니다.
            throw new BadCredentialsException("아이디 또는 비밀번호가 일치하지 않습니다.");
        }
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

    /**
     * [수정] 전화번호 유효성을 검사하는 헬퍼 메소드
     */
    private void validatePhoneNumber(MemberVO memberVO) {
        if ("82".equals(memberVO.getCountryCode()) && memberVO.getPhone() != null) {
            String phone = memberVO.getPhone().replaceAll("[^0-9]", "");
            
            // [수정] 맨 앞의 '0'을 제거하지 않고, 전체 길이를 기준으로 검사합니다.
            // 이렇게 하면 011, 016 등도 포함하는 10자리, 11자리 번호를 모두 허용하게 됩니다.
            if (phone.length() < 10 || phone.length() > 11) {
                throw new IllegalArgumentException("유효하지 않은 전화번호 형식입니다.");
            }
        }
        // TODO: 다른 국가 코드에 대한 유효성 검사 규칙 추가 가능
    }
}
