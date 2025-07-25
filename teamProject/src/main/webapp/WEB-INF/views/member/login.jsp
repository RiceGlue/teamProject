<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container my-5" style="max-width: 500px;">
    <h2 class="text-center mb-4">로그인</h2>
    
    <!-- (수정) 로그인 실패 메시지 표시 -->
    <c:if test="${param.error}">
        <div class="alert alert-danger" role="alert">
            아이디 또는 비밀번호가 일치하지 않습니다.
        </div>
    </c:if>
    
    <!-- (수정) 회원가입 성공 메시지 표시 -->
    <c:if test="${not empty msg}">
        <div class="alert alert-success" role="alert">
            ${msg}
        </div>
    </c:if>

    <form action="${contextPath}/member/login" method="post">
        <div class="mb-3">
            <label for="username" class="form-label">아이디</label>
            <!-- (수정) name 속성을 'username'으로 변경 (스프링 시큐리티 기본값) -->
            <input type="text" class="form-control" id="username" name="username" required>
        </div>
        <div class="mb-3">
            <label for="password" class="form-label">비밀번호</label>
            <!-- (수정) name 속성을 'password'으로 변경 (스프링 시큐리티 기본값) -->
            <input type="password" class="form-control" id="password" name="password" required>
        </div>
        <div class="d-grid">
            <button type="submit" class="btn btn-primary">로그인</button>
        </div>
    </form>
    
    <div class="text-center mt-3">
        <a href="${contextPath}/member/join-select">회원가입</a> | <a href="#">아이디/비밀번호 찾기</a>
    </div>
</div>
