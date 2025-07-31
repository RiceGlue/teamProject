<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container my-5" style="max-width: 600px;">
    <h2 class="text-center mb-4">프로필 수정</h2>
    
    <form action="${contextPath}/member/edit-profile" method="post" enctype="multipart/form-data" onsubmit="return validatePassword();">
        
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
        
        <hr class="my-4">
        
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

        <%-- (수정) 알림 수신 동의 섹션을 비밀번호 변경 아래로 이동 --%>
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
        const newPassword = document.getElementById('newLoginPw').value;
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
        return true;
    }
</script>
