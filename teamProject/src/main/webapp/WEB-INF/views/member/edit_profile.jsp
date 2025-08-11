<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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
        // 파일 선택 취소 시, 현재 프로필 이미지나 기본 이미지로 되돌립니다.
        const currentImage = '${(not empty memberInfo.profileImageUrl) ? contextPath.concat(memberInfo.profileImageUrl) : contextPath.concat("/images/default_profile.png")}';
        document.getElementById('preview').src = currentImage;
    }

    function validatePassword() {
        // 이 함수는 form 태그의 onsubmit 이벤트에 의해 호출되므로,
        // DOM 요소들이 모두 로드된 이후에 실행되어 id로 요소를 찾는데 문제가 없습니다.
        const newPasswordInput = document.getElementById('newLoginPw');
        if (newPasswordInput) {
            const newPassword = newPasswordInput.value;
            const confirmPassword = document.getElementById('newLoginPwConfirm').value;
            if (newPassword || confirmPassword) {
                if (newPassword !== confirmPassword) {
                    alert("새 비밀번호가 일치하지 않습니다.");
                    return false;
                }
                const currentPassword = document.getElementById('currentLoginPw').value;
                if (!currentPassword) {
                    alert("비밀번호를 변경하려면 현재 비밀번호를 입력해야 합니다.");
                    return false;
                }
            }
        }
        return true;
    }
</script>

<div class="container my-5" style="max-width: 600px;">
    <h2 class="text-center mb-4">프로필 수정</h2>

    <%-- 성공 또는 에러 메시지를 표시하는 영역 --%>
    <c:if test="${not empty error}">
        <div class="alert alert-danger" role="alert">${error}</div>
    </c:if>
    <c:if test="${not empty msg}">
        <div class="alert alert-success" role="alert">${msg}</div>
    </c:if>
    
    <form action="${contextPath}/member/edit-profile" method="post" enctype="multipart/form-data" onsubmit="return validatePassword();">
        
        <%-- 프로필 이미지, 이름, 연락처, 이메일 등 공통 정보 수정 필드 --%>
        <div class="text-center mb-4">
            <c:choose>
                <c:when test="${not empty memberInfo.profileImageUrl}">
                    <img src="${contextPath}${memberInfo.profileImageUrl}" class="img-fluid rounded-circle mb-3" alt="프로필 이미지" id="preview" style="width: 150px; height: 150px; object-fit: cover;">
                </c:when>
                <c:otherwise>
                    <img src="${contextPath}/images/default_profile.png" class="img-fluid rounded-circle mb-3" alt="기본 프로필 이미지" id="preview" style="width: 150px; height: 150px; object-fit: cover;">
                </c:otherwise>
            </c:choose>
            <div>
                <label for="profileImageFile" class="form-label">프로필 이미지 변경 (2MB / 500x500px 이하)</label>
                <input class="form-control" type="file" id="profileImageFile" name="profileImageFile" onchange="validateImage(this);" accept="image/*">
            </div>
        </div>

        <div class="mb-3">
            <label for="memberName" class="form-label">이름</label>
            <input type="text" class="form-control" id="memberName" name="memberName" value="${memberInfo.memberName}" required>
        </div>

        <!-- 전화번호, 이메일 수정 필드 추가 -->
        <div class="mb-3">
            <label for="phone" class="form-label">연락처</label>
            <div class="input-group">
                <select class="form-select" name="countryCode" style="max-width: 150px;">
                    <option value="82" ${memberInfo.countryCode == '82' ? 'selected' : ''}>+82 (대한민국)</option>
                    <option value="1"  ${memberInfo.countryCode == '1' ? 'selected' : ''}>+1 (United States)</option>
                    <option value="81" ${memberInfo.countryCode == '81' ? 'selected' : ''}>+81 (日本)</option>
                    <option value="86" ${memberInfo.countryCode == '86' ? 'selected' : ''}>+86 (中國)</option>
                    <option value="44" ${memberInfo.countryCode == '44' ? 'selected' : ''}>+44 (United Kingdom)</option>
                    <option value="49" ${memberInfo.countryCode == '49' ? 'selected' : ''}>+49 (Deutschland)</option>
                    <option value="33" ${memberInfo.countryCode == '33' ? 'selected' : ''}>+33 (France)</option>
                    <option value="1" ${memberInfo.countryCode == '1' ? 'selected' : ''}>+1 (Canada)</option>
                    <option value="61" ${memberInfo.countryCode == '61' ? 'selected' : ''}>+61 (Australia)</option>
                    <option value="7" ${memberInfo.countryCode == '7' ? 'selected' : ''}>+7 (Россия)</option>
                    <option value="34" ${memberInfo.countryCode == '34' ? 'selected' : ''}>+34 (Espana)</option>
                    <option value="39" ${memberInfo.countryCode == '39' ? 'selected' : ''}>+39 (Italia)</option>
                    <option value="84" ${memberInfo.countryCode == '84' ? 'selected' : ''}>+84 (Vi?t Nam)</option>
                    <option value="66" ${memberInfo.countryCode == '66' ? 'selected' : ''}>+66 (?????????)</option>
                    <option value="63" ${memberInfo.countryCode == '63' ? 'selected' : ''}>+63 (Pilipinas)</option>
                    <option value="886" ${memberInfo.countryCode == '886' ? 'selected' : ''}>+886 (台灣)</option>
                    <option value="852" ${memberInfo.countryCode == '852' ? 'selected' : ''}>+852 (Hong Kong)</option>
                    <option value="65" ${memberInfo.countryCode == '65' ? 'selected' : ''}>+65 (Singapore)</option>
                    <option value="60" ${memberInfo.countryCode == '60' ? 'selected' : ''}>+60 (Malaysia)</option>
                    <option value="62" ${memberInfo.countryCode == '62' ? 'selected' : ''}>+62 (Indonesia)</option>
                    <option value="91" ${memberInfo.countryCode == '91' ? 'selected' : ''}>+91 (India)</option>
                    <option value="55" ${memberInfo.countryCode == '55' ? 'selected' : ''}>+55 (Brasil)</option>
                    <option value="52" ${memberInfo.countryCode == '52' ? 'selected' : ''}>+52 (Mexico)</option>
                </select>
                <input type="tel" class="form-control" id="phone" name="phone" value="${memberInfo.phone}" placeholder="'-' 없이 숫자만 입력" required>
            </div>
        </div>

        <div class="mb-3">
            <label for="email" class="form-label">이메일</label>
            <input type="email" class="form-control" id="email" name="email" value="${memberInfo.email}" placeholder="name@example.com" required>
        </div>
        
        
        <!-- --- 1. 비밀번호 섹션 분기 처리 --- -->
        <hr class="my-4">
        
        <c:if test="${not empty memberInfo.loginPw}">
            <h5 class="mb-3">비밀번호 변경</h5>
            <p class="text-muted small mb-3">비밀번호를 변경하지 않으려면 아래 항목을 비워두세요.</p>
            <div class="mb-3">
                <label for="currentLoginPw" class="form-label">현재 비밀번호</label>
                <input type="password" class="form-control" id="currentLoginPw" name="currentLoginPw">
            </div>
            <div class="mb-3">
                <label for="newLoginPw" class="form-label">새 비밀번호</label>
                <input type="password" class="form-control" id="newLoginPw" name="newLoginPw">
            </div>
            <div class="mb-3">
                <label for="newLoginPwConfirm" class="form-label">새 비밀번호 확인</label>
                <input type="password" class="form-control" id="newLoginPwConfirm" name="newLoginPwConfirm">
            </div>
        </c:if>

        <%-- Case B: 소셜 로그인으로만 가입하여 비밀번호가 없는 계정 --%>
        <c:if test="${empty memberInfo.loginPw}">
            <h5 class="mb-3">비밀번호 설정</h5>
            <p class="text-muted small mb-3">비밀번호를 설정하면 이메일과 비밀번호로도 로그인할 수 있습니다.</p>
			<%-- TODO: 비밀번호 설정 폼 (새 비밀번호, 새 비밀번호 확인) 추가 위치 --%>
            <div class="d-grid">
                <button type="button" class="btn btn-outline-primary" onclick="alert('비밀번호 설정 기능은 개발 예정입니다.');">비밀번호 설정하기</button>
            </div>
        </c:if>
        
        <!-- ? --- [위치 이동 및 URL 수정] 소셜 계정 연동 섹션 --- ? -->
        <hr class="my-4">
        <h5 class="mb-3">소셜 계정 연동</h5>
        
        <%-- Google 연동 상태 확인 --%>
        <c:set var="googleLinked" value="${false}" />
        <c:forEach var="account" items="${memberInfo.socialAccounts}">
            <c:if test="${account.provider == 'GOOGLE'}"><c:set var="googleLinked" value="${true}" /></c:if>
        </c:forEach>

        <div class="card p-3">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"></path><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"></path><path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"></path><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"></path><path fill="none" d="M0 0h48v48H0z"></path></svg>
                    <span class="ms-2 fw-bold">Google</span>
                </div>
                <div>
                    <c:choose>
                        <c:when test="${googleLinked}">
                            <span class="badge bg-success me-2">연동됨</span>
                            <c:if test="${not empty memberInfo.loginPw}">
                                <form action="${contextPath}/member/unlink-social" method="post" style="display: inline;" onsubmit="return confirm('정말로 Google 계정 연동을 해제하시겠습니까?');">
                                    <input type="hidden" name="provider" value="GOOGLE">
                                    <button type="submit" class="btn btn-sm btn-outline-danger">연동 해제</button>
                                </form>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <c:if test="${not empty memberInfo.loginPw}">
                                <%-- [수정] 계정 연동 준비 URL로 변경 --%>
                                <a href="${contextPath}/member/prepare-link/google" class="btn btn-sm btn-outline-secondary">연동하기</a>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <hr class="my-4">
        
        <div class="mb-3">
            <label class="form-label">알림 수신 설정</label>
            <div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" name="agreeSms" value="true" id="agreeSms" ${memberInfo.agreeSms ? 'checked' : ''}>
                    <label class="form-check-label" for="agreeSms">SMS</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" name="agreeEmail" value="true" id="agreeEmail" ${memberInfo.agreeEmail ? 'checked' : ''}>
                    <label class="form-check-label" for="agreeEmail">이메일</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" name="agreeKakao" value="true" id="agreeKakao" ${memberInfo.agreeKakao ? 'checked' : ''}>
                    <label class="form-check-label" for="agreeKakao">카카오톡</label>
                </div>
            </div>
            <div class="form-text">빈자리 알림 등 유용한 정보를 위 채널로 받겠습니다.</div>
        </div>

        <div class="d-grid gap-2 mt-4">
            <button type="submit" class="btn btn-primary">수정 완료</button>
            <a href="${contextPath}/member/mypage" class="btn btn-secondary">취소</a>
        </div>
    </form>
    
    <div class="text-end mt-5">
        <form action="${contextPath}/member/withdraw" method="post" onsubmit="return confirm('정말로 탈퇴하시겠습니까? 모든 정보가 삭제되며 복구할 수 없습니다.');">
            <button type="submit" class="btn btn-link text-danger btn-sm">회원 탈퇴</button>
        </form>
    </div>
</div>
