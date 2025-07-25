<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container my-5" style="max-width: 500px;">
    <h2 class="text-center mb-4">로그인</h2>
    <form action="${contextPath}/member/login" method="post">
        <div class="mb-3">
            <label for="loginId" class="form-label">아이디</label>
            <input type="text" class="form-control" id="loginId" name="loginId" required>
        </div>
        <div class="mb-3">
            <label for="loginPw" class="form-label">비밀번호</label>
            <input type="password" class="form-control" id="loginPw" name="loginPw" required>
        </div>
        <div class="d-grid">
            <button type="submit" class="btn btn-primary">로그인</button>
        </div>
    </form>
    
    <div class="text-center mt-3">
        <a href="${contextPath}/member/join_select">회원가입</a> | <a href="#">아이디/비밀번호 찾기</a>
    </div>
    
    <!-- 로그인 실패 또는 회원가입 성공 메시지 표시 -->
    <c:if test="${not empty msg}">
        <div class="alert alert-info mt-3" role="alert">
            ${msg}
        </div>
    </c:if>
</div>
