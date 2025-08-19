<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

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
            
            <%-- 컨트롤러에서 보낸 로그인 유도 메시지가 있으면 표시합니다. --%>
            <c:if test="${not empty loginRedirectMessage}">
                <div class="alert alert-info" role="alert">
                    ${loginRedirectMessage}
                </div>
            </c:if>

            <%-- ? --- 여기가 핵심 수정 부분입니다 --- ? --%>
            <%-- 일반 에러 메시지(소셜 계정 중복 등)를 표시하는 영역을 추가합니다. --%>
            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                    ${error}
                </div>
            </c:if>

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

        <%-- 소셜 로그인 탭 --%>
        <div class="tab-pane fade" id="social-login" role="tabpanel" aria-labelledby="social-login-tab">
            <div class="d-grid mt-4">
                <a href="${contextPath}/oauth2/authorization/google" class="btn btn-outline-dark w-100 d-flex align-items-center justify-content-center py-2">
                    <svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 48 48" xmlns:xlink="http://www.w3.org/1999/xlink" style="display: block;">
                        <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"></path>
                        <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"></path>
                        <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"></path>
                        <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"></path>
                        <path fill="none" d="M0 0h48v48H0z"></path>
                    </svg>
                    &nbsp;구글로 로그인하기
                </a>
                <%-- TODO: 카카오 등 다른 소셜 로그인 버튼 추가 위치 --%>
            </div>
        </div>
    </div>

    <div class="text-center mt-4">
        <a href="${contextPath}/member/join?role=USER">회원가입</a> | <a href="${contextPath}/member/find-account">아이디/비밀번호 찾기</a>
    </div>
</div>
