<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container my-5" style="max-width: 600px;">
    <h2 class="text-center mb-4">회원가입</h2>
    <form action="${contextPath}/member/join" method="post">
        <div class="mb-3">
            <label for="loginId" class="form-label">아이디</label>
            <input type="text" class="form-control" id="loginId" name="loginId" required>
        </div>
        <div class="mb-3">
            <label for="loginPw" class="form-label">비밀번호</label>
            <input type="password" class="form-control" id="loginPw" name="loginPw" required>
        </div>
        <div class="mb-3">
            <label for="memberName" class="form-label">이름</label>
            <input type="text" class="form-control" id="memberName" name="memberName" required>
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
            <input type="tel" class="form-control" id="phone" name="phone" placeholder="010-1234-5678" required>
        </div>
        <div class="mb-3">
            <label for="email" class="form-label">이메일</label>
            <input type="email" class="form-control" id="email" name="email" placeholder="name@example.com" required>
        </div>
        <div class="d-grid">
            <button type="submit" class="btn btn-primary">가입하기</button>
        </div>
    </form>
</div>
