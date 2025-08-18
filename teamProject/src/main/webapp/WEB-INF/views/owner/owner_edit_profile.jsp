<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<script>
    // 이미지 및 폼 유효성 검사 스크립트 (기존 member/edit_profile.jsp와 동일)
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
        const currentImage = '${(not empty memberInfo.profileImageUrl) ? contextPath.concat(memberInfo.profileImageUrl) : contextPath.concat("/images/default_profile.png")}';
        document.getElementById('preview').src = currentImage;
    }

    function validateForm() {
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
        return validatePassword();
    }

    function validatePassword() {
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
    <h2 class="text-center mb-4">점주 정보 수정</h2>

    <c:if test="${not empty error}"><div class="alert alert-danger" role="alert">${error}</div></c:if>
    <c:if test="${not empty msg}"><div class="alert alert-success" role="alert">${msg}</div></c:if>

    <form action="${contextPath}/owner/edit-profile" method="post" enctype="multipart/form-data" onsubmit="return validateForm();">
        
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
                    <%-- 다른 국가 코드 옵션들 --%>
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
        
        <hr class="my-4">
        
        <h5 class="mb-3">비밀번호 변경</h5>
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
        
        <div class="d-grid gap-2 mt-4">
            <button type="submit" class="btn btn-primary">수정 완료</button>
            <a href="${contextPath}/owner/dashboard" class="btn btn-secondary">취소</a>
        </div>
    </form>
</div>
