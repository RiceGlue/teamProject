<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script src="https://www.google.com/recaptcha/api.js" async defer></script>
<script>
    // DOM(Document Object Model)이 완전히 로드된 후에, 중괄호 안의 코드를 실행합니다.
    $(function() {
        // id가 'profileImageFile'인 요소에 'change' 이벤트가 발생하면 실행될 함수를 연결합니다.
        $('#profileImageFile').on('change', function() {
            validateImage(this);
        });

        // --- 아이디 중복 확인 기능 추가 ---
        // 1. 중복 확인 버튼 클릭 이벤트
        $('#idCheckBtn').on('click', function() {
            const loginId = $('#loginId').val();
            const idCheckMessage = $('#idCheckMessage');

            if (!loginId) {
                idCheckMessage.html('<span style="color: red;">아이디를 입력해주세요.</span>');
                return;
            }

            $.ajax({
                url: '${contextPath}/member/check-id',
                type: 'POST',
                data: { loginId: loginId },
                success: function(response) {
                    // 응답 키를 isDuplicate로 변경하고, 논리를 반대로
                    if (!response.isDuplicate) { // 중복되지 않았다면
                        idCheckMessage.html('<span style="color: green;">사용 가능한 아이디입니다.</span>');
                        $('#submitBtn').prop('disabled', false); // 가입 버튼 활성화
                    } else { // 중복되었다면
                        idCheckMessage.html('<span style="color: red;">이미 사용 중인 아이디입니다.</span>');
                        $('#submitBtn').prop('disabled', true); // 가입 버튼 비활성화
                    }
                },
                error: function() {
                    idCheckMessage.html('<span style="color: red;">오류가 발생했습니다. 다시 시도해주세요.</span>');
                    $('#submitBtn').prop('disabled', true);
                }
            });
        });

        // 2. 아이디 입력란 수정 시, 상태 초기화
        $('#loginId').on('input', function() {
            $('#submitBtn').prop('disabled', true);
            $('#idCheckMessage').html('');
        });
    });

    // 이미지 유효성 검사 및 미리보기 함수
    function validateImage(input) {
        const file = input.files[0];
        if (!file) return;

        const maxSizeInBytes = 2 * 1024 * 1024; // 2MB
        if (file.size > maxSizeInBytes) {
            alert("프로필 사진은 2MB를 초과할 수 없습니다.");
            resetInput(input);
            return;
        }

        const maxResolution = 500; // 최대 가로/세로 500px
        const reader = new FileReader();
        reader.onload = function(e) {
            const image = new Image();
            image.src = e.target.result;
            image.onload = function() {
                if (this.width > maxResolution || this.height > maxResolution) {
                    alert("이미지 해상도는 " + maxResolution + "x" + maxResolution + " 픽셀을 초과할 수 없습니다.");
                    resetInput(input);
                    return;
                }
                document.getElementById('preview').src = e.target.result;
            };
        };
        reader.readAsDataURL(file);
    }

    // 이미지 입력 초기화 함수
    function resetInput(input) {
        input.value = '';
        document.getElementById('preview').src = '${contextPath}/images/default_profile.png';
    }

    // 폼 제출 유효성 검사 함수
    function validateJoinForm() {
        // 1. 아이디 중복 확인 여부 검사
        if ($('#submitBtn').is(':disabled')) {
            alert("아이디 중복 확인을 해주세요.");
            return false;
        }

        // 2. reCAPTCHA 검사
        const recaptchaResponse = grecaptcha.getResponse();
        if (recaptchaResponse.length === 0) {
            alert("reCAPTCHA를 확인해주세요.");
            return false;
        }

        // 3. 전화번호 유효성 검사 추가
        const countryCode = document.getElementById('countryCode').value;
        const phone = document.getElementById('phone').value;
        if (countryCode === '82') {
            const cleanPhone = phone.replace(/[^0-9]/g, '');
            // 0으로 시작하는 번호도 고려하여 검사
            if (cleanPhone.startsWith('0')) {
                if (cleanPhone.length < 10 || cleanPhone.length > 11) {
                    alert('올바른 휴대폰 번호 10자리 또는 11자리를 입력해주세요.');
                    document.getElementById('phone').focus();
                    return false;
                }
            } else {
                 if (cleanPhone.length < 9 || cleanPhone.length > 10) {
                    alert('올바른 휴대폰 번호 10자리 또는 11자리를 입력해주세요.');
                    document.getElementById('phone').focus();
                    return false;
                }
            }
        }
        // 모든 검사를 통과하면 폼 제출
        return true;
    }
</script>

<div class="container my-5" style="max-width: 600px;">
    <h2 class="text-center mb-4">일반 회원가입</h2>
    
    <form action="${contextPath}/member/join" method="post" enctype="multipart/form-data" onsubmit="return validateJoinForm();">
        <input type="hidden" name="role" value="USER">

        <div class="text-center mb-4">
            <img src="${contextPath}/images/default_profile.png" class="img-fluid rounded-circle mb-3" alt="프로필 이미지" id="preview" style="width: 150px; height: 150px; object-fit: cover;">
            <div>
                <label for="profileImageFile" class="form-label">프로필 이미지 (2MB / 500x500px 이하)</label>
                <input class="form-control" type="file" id="profileImageFile" name="profileImageFile" onchange="validateImage(this);" accept="image/*">
            </div>
        </div>
        
		<%-- 아이디 입력 (수정) --%>
        <div class="mb-3">
            <label for="loginId" class="form-label">아이디</label>
            <div class="input-group">
                <input type="text" class="form-control" id="loginId" name="loginId" required>
                <button class="btn btn-outline-secondary" type="button" id="idCheckBtn">중복 확인</button>
            </div>
            <div id="idCheckMessage" class="form-text mt-1"></div>
        </div>
        
        <div class="mb-3">
            <label for="loginPw" class="form-label">비밀번호</label>
            <input type="password" class="form-control" id="loginPw" name="loginPw" required>
        </div>
        <div class="mb-3">
            <label for="memberName" class="form-label">이름</label>
            <input type="text" class="form-control" id="memberName" name="memberName" value="${memberVO.memberName}" required>
        </div>
        <div class="mb-3">
            <label for="birth" class="form-label">생년월일</label>
            <input type="date" class="form-control" id="birth" name="birth" value="${memberVO.birth}" required>
        </div>
        <div class="mb-3">
            <label class="form-label">성별</label>
            <div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="sex" id="male" value="male" checked>
                    <label class="form-check-label" for="male">남성</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="radio" name="sex" id="female" value="female">
                    <label class="form-check-label" for="female">여성</label>
                </div>
            </div>
        </div>

		<!-- (수정) 전화번호 입력 부분 -->
        <div class="mb-3">
            <label for="phone" class="form-label">전화번호</label>
            <div class="input-group">
                <select class="form-select" id="countryCode" name="countryCode" style="max-width: 150px;">
                    <option value="82" selected>+82 (대한민국)</option>
                    <option value="1">+1 (United States)</option>
                    <option value="81">+81 (日本)</option>
                    <option value="86">+86 (中?)</option>
                    <option value="44">+44 (United Kingdom)</option>
                    <option value="49">+49 (Deutschland)</option>
                    <option value="33">+33 (France)</option>
                    <option value="1">+1 (Canada)</option>
                    <option value="61">+61 (Australia)</option>
                    <option value="7">+7 (Россия)</option>
                    <option value="34">+34 (Espana)</option>
                    <option value="39">+39 (Italia)</option>
                    <option value="84">+84 (Vi?t Nam)</option>
                    <option value="66">+66 (?????????)</option>
                    <option value="63">+63 (Pilipinas)</option>
                    <option value="886">+886 (台灣)</option>
                    <option value="852">+852 (Hong Kong)</option>
                    <option value="65">+65 (Singapore)</option>
                    <option value="60">+60 (Malaysia)</option>
                    <option value="62">+62 (Indonesia)</option>
                    <option value="91">+91 (India)</option>
                    <option value="55">+55 (Brasil)</option>
                    <option value="52">+52 (Mexico)</option>
                </select>
                <input type="tel" class="form-control" id="phone" name="phone" placeholder="'-' 없이 숫자만 입력" required>
            </div>
        </div>

        <div class="mb-3">
            <label for="email" class="form-label">이메일</label>
            <input type="email" class="form-control" id="email" name="email" placeholder="name@example.com" required>
        </div>

		<%-- 알림 수신 동의 UI 개선 --%>
        <div class="mb-3">
            <label class="form-label">알림 수신 동의 (선택)</label>
            <div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" name="agreeSms" value="true" id="agreeSms">
                    <label class="form-check-label" for="agreeSms">SMS</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" name="agreeEmail" value="true" id="agreeEmail">
                    <label class="form-check-label" for="agreeEmail">이메일</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" name="agreeKakao" value="true" id="agreeKakao">
                    <label class="form-check-label" for="agreeKakao">카카오톡</label>
                </div>
            </div>
            <div class="form-text">빈자리 알림 등 유용한 정보를 위 채널로 받겠습니다.</div>
        </div>
        
		<%-- (신규) reCAPTCHA 위젯 추가 --%>
        <div class="mb-3 d-flex justify-content-center">
            <div class="g-recaptcha" data-sitekey="${recaptchaSiteKey}"></div>
        </div>

        <%-- 가입하기 버튼 (수정) --%>
        <div class="d-grid">
            <button type="submit" id="submitBtn" class="btn btn-primary" disabled>가입하기</button>
        </div>
    </form>
</div>
