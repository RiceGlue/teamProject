<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container my-5" style="max-width: 600px;">
    <h2 class="text-center mb-4">프로필 수정</h2>
    
    <%-- 파일 업로드를 위해 enctype="multipart/form-data" 추가 --%>
    <form action="${contextPath}/member/edit-profile" method="post" enctype="multipart/form-data">
        
        <div class="text-center mb-4">
            <img src="https://via.placeholder.com/150" class="img-fluid rounded-circle mb-3" alt="프로필 이미지" id="preview">
            <div>
                <label for="profileImage" class="form-label">프로필 이미지 변경</label>
                <input class="form-control" type="file" id="profileImage" name="profileImageFile" onchange="previewImage(this);">
            </div>
        </div>

        <div class="mb-3">
            <label for="memberName" class="form-label">닉네임</label>
            <input type="text" class="form-control" id="memberName" name="memberName" value="현재닉네임" required>
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
        
        <div class="d-grid gap-2 mt-4">
            <button type="submit" class="btn btn-primary">수정 완료</button>
            <a href="${contextPath}/member/mypage" class="btn btn-secondary">취소</a>
        </div>
    </form>
    
    <div class="text-end mt-5">
        <button class="btn btn-link text-danger btn-sm" onclick="withdraw()">회원 탈퇴</button>
    </div>
</div>

<script>
    // 이미지 파일 선택 시 미리보기 기능
    function previewImage(input) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('preview').src = e.target.result;
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    // 회원 탈퇴 확인
    function withdraw() {
        if (confirm("정말로 탈퇴하시겠습니까? 모든 정보가 삭제되며 복구할 수 없습니다.")) {
            // form을 동적으로 생성하여 POST 방식으로 탈퇴 요청
            const form = document.createElement('form');
            form.method = 'post';
            form.action = '${contextPath}/member/withdraw';
            document.body.appendChild(form);
            form.submit();
        }
    }
</script>
