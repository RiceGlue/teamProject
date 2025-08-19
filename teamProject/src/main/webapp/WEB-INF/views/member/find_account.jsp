<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="container my-5" style="max-width: 500px;">
    
    <ul class="nav nav-tabs nav-fill mb-4" id="findAccountTab" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="find-id-tab" data-bs-toggle="tab" data-bs-target="#find-id" type="button" role="tab" aria-controls="find-id" aria-selected="true">아이디 찾기</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="find-pw-tab" data-bs-toggle="tab" data-bs-target="#find-pw" type="button" role="tab" aria-controls="find-pw" aria-selected="false">비밀번호 찾기</button>
        </li>
    </ul>

    <div class="tab-content" id="findAccountTabContent">
        
        <!-- 아이디 찾기 탭 -->
        <div class="tab-pane fade show active" id="find-id" role="tabpanel" aria-labelledby="find-id-tab">
            <p class="text-muted text-center mb-4">가입 시 등록한 이름과 휴대폰 번호를 입력해주세요.</p>
            <form id="findIdForm">
                <div class="mb-3">
                    <label for="find-id-name" class="form-label">이름</label>
                    <input type="text" class="form-control" id="find-id-name" name="memberName" required>
                </div>
                <div class="mb-3">
                    <label for="find-id-phone" class="form-label">휴대폰 번호</label>
                    <input type="tel" class="form-control" id="find-id-phone" name="phone" placeholder="'-' 없이 숫자만 입력" required>
                </div>
                <div class="d-grid">
                    <button type="submit" class="btn btn-primary">아이디 찾기</button>
                </div>
            </form>
        </div>

        <!-- 비밀번호 찾기 탭 -->
        <div class="tab-pane fade" id="find-pw" role="tabpanel" aria-labelledby="find-pw-tab">
            <p class="text-muted text-center mb-4">가입 시 등록한 아이디와 이메일 주소를 입력해주세요.</p>
            <form action="${contextPath}/member/reset-password" method="post">
                <div class="mb-3">
                    <label for="find-pw-id" class="form-label">아이디</label>
                    <input type="text" class="form-control" id="find-pw-id" name="loginId" required>
                </div>
                <div class="mb-3">
                    <label for="find-pw-email" class="form-label">이메일</label>
                    <input type="email" class="form-control" id="find-pw-email" name="email" required>
                </div>
                <div class="d-grid">
                    <button type="submit" class="btn btn-primary">임시 비밀번호 발급</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- 결과 표시용 Modal -->
<div class="modal fade" id="resultModal" tabindex="-1" aria-labelledby="resultModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="resultModalLabel">아이디 찾기 결과</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body" id="resultModalBody">
        <!-- AJAX 결과가 여기에 표시됩니다. -->
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
        <a href="${contextPath}/member/login" class="btn btn-primary">로그인하기</a>
      </div>
    </div>
  </div>
</div>

<script>
    // ? --- 여기가 핵심 수정 부분입니다 --- ?
    // 아이디 찾기 폼 제출 시 AJAX 처리
    document.getElementById('findIdForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        const name = document.getElementById('find-id-name').value;
        const phone = document.getElementById('find-id-phone').value;
        const resultModalBody = document.getElementById('resultModalBody');
        const resultModal = new bootstrap.Modal(document.getElementById('resultModal'));

        $.ajax({
            url: '${contextPath}/member/find-id',
            type: 'POST',
            data: { memberName: name, phone: phone },
            success: function(response) {
                if(response.success) {
                    resultModalBody.innerHTML = '회원님의 아이디는 <strong>' + response.loginId + '</strong> 입니다.';
                } else {
                    resultModalBody.textContent = '일치하는 회원 정보를 찾을 수 없습니다.';
                }
                resultModal.show();
            },
            error: function() {
                resultModalBody.textContent = '오류가 발생했습니다. 다시 시도해주세요.';
                resultModal.show();
            }
        });
    });
</script>
