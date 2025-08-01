<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container my-5" style="max-width: 600px;">
    <h2 class="text-center mb-4">추가 정보 입력</h2>
    <p class="text-center text-muted mb-4">정확한 서비스 이용을 위해 추가 정보를 입력해주세요.</p>
    
    <form action="${contextPath}/member/join_social" method="post" enctype="multipart/form-data">
        
        <div class="text-center mb-4">
            <%-- (수정) 기본 이미지 경로를 로컬 경로로 변경 --%>
            <img src="${contextPath}/images/default_profile.png" class="img-fluid rounded-circle mb-3" alt="프로필 이미지" id="preview" style="width: 150px; height: 150px; object-fit: cover;">
            <div>
                <label for="profileImageFile" class="form-label">프로필 이미지 (2MB / 500x500px 이하)</label>
                <input class="form-control" type="file" id="profileImageFile" name="profileImageFile" onchange="validateImage(this);" accept="image/*">
            </div>
        </div>
        <div class="mb-3">
            <label for="email" class="form-label">이메일</label>
            <input type="email" class="form-control" id="email" name="email" value="${socialUserInfo.email}" readonly>
        </div>
        <div class="mb-3">
            <label for="memberName" class="form-label">이름</label>
            <input type="text" class="form-control" id="memberName" name="memberName" value="${socialUserInfo.name}" required>
        </div>
        <div class="mb-3">
            <label for="birth" class="form-label">생년월일</label>
            <input type="date" class="form-control" id="birth" name="birth" required>
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
        
        <div class="mb-3">
            <label for="phone" class="form-label">전화번호</label>
            <div class="input-group">
                <select class="form-select" name="countryCode" style="max-width: 150px;">
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

        <%-- (수정) 알림 수신 동의 UI 개선 --%>
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
        
        <div class="d-grid">
            <button type="submit" class="btn btn-primary">가입하기</button>
        </div>
    </form>
</div>

<script src="https://www.google.com/recaptcha/api.js" async defer></script>
<script>
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

    function resetInput(input) {
        input.value = '';
        document.getElementById('preview').src = '${contextPath}/images/default_profile.png';
    }
</script>