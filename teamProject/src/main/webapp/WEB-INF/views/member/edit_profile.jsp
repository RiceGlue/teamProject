<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container my-5" style="max-width: 600px;">
    <h2 class="text-center mb-4">프로필 수정</h2>
    
    <form action="${contextPath}/member/edit-profile" method="post" enctype="multipart/form-data" onsubmit="return validatePassword();">
        
        <div class="text-center mb-4">
            <%-- (수정 1) 프로필 이미지가 없으면 기본 이미지를, 있으면 해당 이미지를 보여줍니다. --%>
            <c:choose>
                <c:when test="${not empty memberInfo.profileImageUrl}">
                    <img src="${contextPath}${memberInfo.profileImageUrl}" class="img-fluid rounded-circle mb-3" alt="프로필 이미지" id="preview" style="width: 150px; height: 150px; object-fit: cover;">
                </c:when>
                <c:otherwise>
                    <img src="${contextPath}/images/default_profile.png" class="img-fluid rounded-circle mb-3" alt="기본 프로필 이미지" id="preview" style="width: 150px; height: 150px; object-fit: cover;">
                </c:otherwise>
            </c:choose>
            <div>
                <label for="profileImageFile" class="form-label">프로필 이미지 변경 (2MB 이하)</label>
                <input class="form-control" type="file" id="profileImageFile" name="profileImageFile" onchange="checkFileSize(this);" accept="image/*">
            </div>
        </div>

        <div class="mb-3">
            <%-- (수정 2) '닉네임'을 '이름'으로 변경하고, value에 실제 사용자 이름을 표시합니다. --%>
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
    function previewImage(input) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('preview').src = e.target.result;
            };
            reader.readAsDataURL(input.files[0]);
        }
    }
    function checkFileSize(input) {
        const maxSizeInBytes = 2 * 1024 * 1024; // 2MB
        const file = input.files[0];
        if (file && file.size > maxSizeInBytes) {
            alert("프로필 사진은 2MB를 초과할 수 없습니다.");
            input.value = '';
            const currentImage = '${(not empty memberInfo.profileImageUrl) ? contextPath.concat(memberInfo.profileImageUrl) : contextPath.concat("/images/default_profile.png")}';
            document.getElementById('preview').src = currentImage;
            return;
        }
        previewImage(input);
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
