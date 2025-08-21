<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    .hidden { display: none; }
</style>

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
            <!-- Step 1: 이름/이메일 입력 -->
            <div id="findIdStep1">
                <p class="text-muted text-center mb-4">가입 시 등록한 이름과 이메일 주소를 입력해주세요.</p>
                <form id="sendCodeForm">
                    <div class="mb-3">
                        <label for="find-id-name" class="form-label">이름</label>
                        <input type="text" class="form-control" id="find-id-name" name="memberName" required>
                    </div>
                    <div class="mb-3">
                        <label for="find-id-email" class="form-label">이메일</label>
                        <div class="input-group">
                            <input type="email" class="form-control" id="find-id-email" name="email" placeholder="가입 시 등록한 이메일" required>
                            <button class="btn btn-outline-secondary" type="submit" id="send-code-btn">인증번호 받기</button>
                        </div>
                    </div>
                </form>
            </div>
            
            <!-- Step 2: 인증번호 입력 -->
            <div id="findIdStep2" class="hidden">
                <p class="text-center mb-4" id="verification-message"></p>
                <form id="verifyCodeForm">
                    <div class="mb-3">
                        <label for="verification-code" class="form-label">인증번호 6자리</label>
                        <input type="text" class="form-control" id="verification-code" name="code" required>
                        <div id="timer" class="form-text text-danger mt-1"></div>
                    </div>
                    <div class="d-grid">
                        <button type="submit" class="btn btn-success">아이디 확인</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- 비밀번호 찾기 탭 (변경 없음) -->
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
      <div class="modal-body" id="resultModalBody"></div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
        <a href="${contextPath}/member/login" class="btn btn-primary">로그인하기</a>
      </div>
    </div>
  </div>
</div>

<script>
    const sendCodeForm = document.getElementById('sendCodeForm');
    const verifyCodeForm = document.getElementById('verifyCodeForm');
    const findIdStep1 = document.getElementById('findIdStep1');
    const findIdStep2 = document.getElementById('findIdStep2');
    const sendCodeBtn = document.getElementById('send-code-btn');
    const timerDisplay = document.getElementById('timer');
    let timerInterval;

    // 인증번호 받기
    sendCodeForm.addEventListener('submit', function(e) {
        e.preventDefault();
        const name = document.getElementById('find-id-name').value;
        const email = document.getElementById('find-id-email').value;

        sendCodeBtn.disabled = true;
        sendCodeBtn.textContent = '발송 중...';

        $.ajax({
            url: '${contextPath}/member/find-id/send-code',
            type: 'POST',
            data: { memberName: name, email: email, method: 'email' },
            success: function(response) {
                if(response.success) {
                    findIdStep1.classList.add('hidden');
                    document.getElementById('verification-message').textContent = response.message;
                    findIdStep2.classList.remove('hidden');
                    startTimer(180, timerDisplay);
                } else {
                    alert(response.message);
                }
            },
            error: function() {
                alert('오류가 발생했습니다.');
            },
            complete: function() {
                sendCodeBtn.disabled = false;
                sendCodeBtn.textContent = '재전송';
            }
        });
    });

    // 인증번호 확인
    verifyCodeForm.addEventListener('submit', function(e) {
        e.preventDefault();
        const code = document.getElementById('verification-code').value;
        const resultModalBody = document.getElementById('resultModalBody');
        const resultModal = new bootstrap.Modal(document.getElementById('resultModal'));

        $.ajax({
            url: '${contextPath}/member/find-id/verify-code',
            type: 'POST',
            data: { code: code },
            success: function(response) {
                if(response.success) {
                    clearInterval(timerInterval);
                    resultModalBody.innerHTML = '회원님의 아이디는 <strong>' + response.loginId + '</strong> 입니다.';
                    resultModal.show();
                } else {
                    alert(response.message);
                }
            },
            error: function() {
                alert('오류가 발생했습니다.');
            }
        });
    });

    function startTimer(duration, display) {
        let timer = duration, minutes, seconds;
        clearInterval(timerInterval);
        timerInterval = setInterval(function () {
            minutes = parseInt(timer / 60, 10);
            seconds = parseInt(timer % 60, 10);
            minutes = minutes < 10 ? "0" + minutes : minutes;
            seconds = seconds < 10 ? "0" + seconds : seconds;
            display.textContent = "남은 시간 " + minutes + ":" + seconds;
            if (--timer < 0) {
                clearInterval(timerInterval);
                display.textContent = "인증 시간이 만료되었습니다. '재전송' 버튼을 눌러주세요.";
            }
        }, 1000);
    }
</script>
