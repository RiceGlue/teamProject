<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container my-5" style="max-width: 500px;">
    
    <%-- 1. 탭 메뉴 (Nav tabs) --%>
    <ul class="nav nav-tabs nav-fill mb-4" id="loginTab" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="normal-login-tab" data-bs-toggle="tab" data-bs-target="#normal-login" type="button" role="tab" aria-controls="normal-login" aria-selected="true">로그인</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="social-login-tab" data-bs-toggle="tab" data-bs-target="#social-login" type="button" role="tab" aria-controls="social-login" aria-selected="false">소셜 로그인</button>
        </li>
    </ul>

    <%-- 2. 탭 콘텐츠 (Tab panes) --%>
    <div class="tab-content" id="loginTabContent">
        
        <%-- 일반 로그인 탭 --%>
        <div class="tab-pane fade show active" id="normal-login" role="tabpanel" aria-labelledby="normal-login-tab">
            <c:if test="${param.error}">
                <div class="alert alert-danger" role="alert">
                    아이디 또는 비밀번호가 일치하지 않습니다.
                </div>
            </c:if>
            
            <c:if test="${not empty msg}">
                <div class="alert alert-success" role="alert">
                    ${msg}
                </div>
            </c:if>

            <form action="${contextPath}/member/login" method="post">
                <div class="mb-3">
                    <label for="username" class="form-label">아이디</label>
                    <input type="text" class="form-control" id="username" name="username" required>
                </div>
                <div class="mb-3">
                    <label for="password" class="form-label">비밀번호</label>
                    <input type="password" class="form-control" id="password" name="password" required>
                </div>
                <div class="d-grid">
                    <button type="submit" class="btn btn-primary">로그인</button>
                </div>
            </form>
        </div>

        <%-- 소셜 로그인 탭 (수정됨) --%>
        <div class="tab-pane fade" id="social-login" role="tabpanel" aria-labelledby="social-login-tab">
            <div class="d-grid mt-4">
                <a href="${contextPath}/oauth2/authorization/google" class="btn btn-outline-dark w-100 d-flex align-items-center justify-content-center py-2">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="currentColor" class="bi bi-google me-2" viewBox="0 0 16 16">
                        <path d="M15.545 6.558a9.42 9.42 0 0 1 .139 1.626c0 2.434-.87 4.492-2.384 5.885h.002C11.978 15.292 10.158 16 8 16A8 8 0 1 1 8 0a7.689 7.689 0 0 1 5.352 2.082l-2.284 2.284A4.347 4.347 0 0 0 8 3.166c-2.087 0-3.86 1.408-4.492 3.25C2.806 7.655 2.5 8.5 2.5 9.5s.306 1.845.808 2.584C3.96 13.592 5.813 15 8 15c1.45 0 2.72-.482 3.697-1.266a4.772 4.772 0 0 0 1.562-3.428H8.19V9.045h7.355z"/>
                    </svg>
                    구글로 로그인하기
                </a>
                <%-- TODO: 카카오 등 다른 소셜 로그인 버튼 추가 위치 --%>
            </div>
        </div>
    </div>

    <div class="text-center mt-4">
        <a href="${contextPath}/member/join-select">회원가입</a> | <a href="#">아이디/비밀번호 찾기</a>
    </div>
</div>