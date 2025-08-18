<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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

    // 폼 제출 시 호출될 메인 유효성 검사 함수
    function validateForm() {
        // 전화번호 유효성 검사
        const countryCode = document.getElementById('countryCode').value;
        const phone = document.getElementById('phone').value;
        if (countryCode === '82') {
            const cleanPhone = phone.replace(/[^0-9]/g, '');
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

        // 비밀번호 유효성 검사
        return validatePassword();
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

    // ? --- [신규] 계정 전환 폼 유효성 검사 및 아이디 중복 확인 --- ?
    function validateConversionForm() {
        if ($('#conversionSubmitBtn').is(':disabled')) {
            alert("새 아이디 중복 확인을 해주세요.");
            return false;
        }
        const newPassword = $('#conversionNewLoginPw').val();
        const confirmPassword = $('#conversionNewLoginPwConfirm').val();
        if (newPassword !== confirmPassword) {
            alert("새 비밀번호가 일치하지 않습니다.");
            return false;
        }
        return true;
    }

    $(function() {
        $('#conversionIdCheckBtn').on('click', function() {
            const loginId = $('#conversionLoginId').val();
            const idCheckMessage = $('#conversionIdCheckMessage');

            if (!loginId) {
                idCheckMessage.html('<span style="color: red;">아이디를 입력해주세요.</span>');
                return;
            }

            $.ajax({
                url: '${contextPath}/member/check-id', // MemberController의 중복 확인 API 사용
                type: 'POST',
                data: { loginId: loginId },
                success: function(response) {
                    if (!response.isDuplicate) {
                        idCheckMessage.html('<span style="color: green;">사용 가능한 아이디입니다.</span>');
                        $('#conversionSubmitBtn').prop('disabled', false);
                    } else {
                        idCheckMessage.html('<span style="color: red;">이미 사용 중인 아이디입니다.</span>');
                        $('#conversionSubmitBtn').prop('disabled', true);
                    }
                },
                error: function() {
                    idCheckMessage.html('<span style="color: red;">오류가 발생했습니다.</span>');
                    $('#conversionSubmitBtn').prop('disabled', true);
                }
            });
        });

        $('#conversionLoginId').on('input', function() {
            $('#conversionSubmitBtn').prop('disabled', true);
            $('#conversionIdCheckMessage').html('');
        });
    });
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

    <!-- === 프로필 정보 수정 폼 시작 === -->
    <form action="${contextPath}/member/edit-profile" method="post" enctype="multipart/form-data" onsubmit="return validateForm();">
        
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
        <div class="mb-3">
            <label for="phone" class="form-label">연락처</label>
            <div class="input-group">
                <select class="form-select" id="countryCode" name="countryCode" style="max-width: 150px;">
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
                <c:set var="displayPhone" value="${memberInfo.phone}" />
                <c:if test="${memberInfo.countryCode == '82' and not fn:startsWith(memberInfo.phone, '0')}">
                    <c:set var="displayPhone" value="0${memberInfo.phone}" />
                </c:if>
                <input type="tel" class="form-control" id="phone" name="phone" value="${displayPhone}" placeholder="'-' 없이 숫자만 입력" required>
            </div>
        </div>
        <div class="mb-3">
            <label for="email" class="form-label">이메일</label>
            <input type="email" class="form-control" id="email" name="email" value="${memberInfo.email}" placeholder="name@example.com" required>
        </div>
        
        
        <!-- --- 비밀번호 섹션 분기 처리 --- -->
        <hr class="my-4">
        
        <%-- 비밀번호 변경 섹션 (일반 계정 사용자에게만 보임) --%>
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
        
        <hr class="my-4">
        
        <%-- 알림 수신 설정 섹션 --%>
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
    <!-- === 프로필 정보 수정 폼 종료 === -->
    

    <%-- ? --- [신규] 소셜 전용 회원을 위한 일반 계정 전환 폼 --- ? --%>
    <c:if test="${empty memberInfo.loginPw}">
        <hr class="my-4">
        <h5 class="mb-3">일반 계정으로 전환</h5>
        <p class="text-muted small mb-3">아이디와 비밀번호를 설정하면 일반 계정으로 전환되어, 소셜 로그인과 함께 아이디/비밀번호로도 로그인할 수 있습니다.</p>
        
        <%-- ? --- 여기가 핵심 수정 부분입니다 --- ? --%>
        <form action="${contextPath}/member/set-password" method="post" onsubmit="return validateConversionForm();">
            <div class="mb-3">
                <label for="conversionLoginId" class="form-label">새 아이디</label>
                <div class="input-group">
                    <input type="text" class="form-control" id="conversionLoginId" name="loginId" required>
                    <button class="btn btn-outline-secondary" type="button" id="conversionIdCheckBtn">중복 확인</button>
                </div>
                <div id="conversionIdCheckMessage" class="form-text mt-1"></div>
            </div>
            <div class="mb-3">
                <label for="conversionNewLoginPw" class="form-label">새 비밀번호</label>
                <input type="password" class="form-control" id="conversionNewLoginPw" name="newLoginPw" required>
            </div>
            <div class="mb-3">
                <label for="conversionNewLoginPwConfirm" class="form-label">새 비밀번호 확인</label>
                <input type="password" class="form-control" id="conversionNewLoginPwConfirm" required>
            </div>
            <div class="d-grid">
                <button type="submit" id="conversionSubmitBtn" class="btn btn-success" disabled>계정 전환하기</button>
            </div>
        </form>
    </c:if>

    <!-- --- 소셜 계정 연동 섹션 --- -->
    <hr class="my-4">
    <h5 class="mb-3">소셜 계정 연동</h5>
    
    <c:set var="googleLinked" value="${false}" />
    <c:forEach var="account" items="${memberInfo.socialAccounts}">
        <c:if test="${account.provider == 'GOOGLE'}">
            <c:set var="googleLinked" value="${true}" />
        </c:if>
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
                            <!-- === 연동 해제 폼 시작 (독립된 폼) === -->
                            <form action="${contextPath}/member/unlink-social" method="post" style="display: inline;" onsubmit="return confirm('정말로 Google 계정 연동을 해제하시겠습니까?');">
                                <input type="hidden" name="provider" value="GOOGLE">
                                <button type="submit" class="btn btn-sm btn-outline-danger">연동 해제</button>
                            </form>
                            <!-- === 연동 해제 폼 종료 === -->
                        </c:if>
                    </c:when>
                    <c:otherwise>
                        <c:if test="${not empty memberInfo.loginPw}">
                            <a href="${contextPath}/member/prepare-link/google" class="btn btn-sm btn-outline-secondary">연동하기</a>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
    
    <div class="text-end mt-5">
        <!-- === 회원 탈퇴 폼 시작 (독립된 폼) === -->
        <form action="${contextPath}/member/withdraw" method="post" onsubmit="return confirm('정말로 탈퇴하시겠습니까? 모든 정보가 삭제되며 복구할 수 없습니다.');">
            <button type="submit" class="btn btn-link text-danger btn-sm">회원 탈퇴</button>
        </form>
        <!-- === 회원 탈퇴 폼 종료 === -->
    </div>
</div>
