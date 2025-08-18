<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="container my-5" style="max-width: 500px;">
    <h2 class="text-center mb-4">계정 연동 확인</h2>

    <div class="alert alert-info" role="alert">
        이미 <strong>${socialLinkInfo.email}</strong> (으)로 가입된 계정이 있습니다.
        <br>
        소셜 계정을 연결하려면, 기존 계정의 아이디와 비밀번호를 입력해주세요.
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger" role="alert">
            ${error}
        </div>
    </c:if>

    <form action="${contextPath}/member/link-account/confirm" method="post">
        <%-- ✨ --- 여기가 핵심 수정 부분입니다 --- ✨ --%>
        <div class="mb-3">
            <label for="loginId" class="form-label">기존 계정 아이디</label>
            <input type="text" class="form-control" id="loginId" name="loginId" required>
        </div>
        <div class="mb-3">
            <label for="password" class="form-label">기존 계정 비밀번호</label>
            <input type="password" class="form-control" id="password" name="password" required>
        </div>
        <div class="d-grid">
            <button type="submit" class="btn btn-primary">계정 연동하기</button>
        </div>
    </form>
    
    <div class="text-center mt-3">
        <a href="#">아이디/비밀번호를 잊으셨나요?</a>
    </div>
</div>
