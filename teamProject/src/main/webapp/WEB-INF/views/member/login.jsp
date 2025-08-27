<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* 얌테이블 커스텀 컬러 팔레트 */
    :root {
        --yum-dark-red: #7B2D26;
        --yum-beige: #D9C6A5;
        --yum-cream: #FDF6EC;
        --yum-dark-blue: #1C1C2A;
    }

    .login-container {
        display: flex;
        align-items: center;
        justify-content: center;
        min-height: 80vh;
        background-color: var(--yum-cream);
    }
    .login-box {
        background-color: #fff;
        padding: 2.5rem;
        border-radius: 1rem;
        box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        width: 100%;
        max-width: 450px;
    }
    .login-box .nav-tabs {
        border-bottom: 2px solid #eee;
    }
    .login-box .nav-tabs .nav-link {
        border: none;
        color: #999;
        font-weight: 500;
        padding-bottom: 1rem;
    }
    .login-box .nav-tabs .nav-link.active {
        color: var(--yum-dark-red);
        border-bottom: 2px solid var(--yum-dark-red);
        background-color: transparent;
    }
    .login-box .form-control {
        padding: 0.9rem 1rem;
        border-radius: 0.5rem;
        background-color: #f8f9fa;
    }
    .login-box .btn-primary {
        background-color: var(--yum-dark-red);
        border-color: var(--yum-dark-red);
        padding: 0.9rem;
        font-weight: 700;
    }
    .login-box .btn-social {
        padding: 0.9rem;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 500;
    }
    .login-box .btn-kakao {
        background-color: #FEE500;
        color: #000000;
        border-color: #FEE500;
    }
    .login-links {
        font-size: 0.9rem;
    }
    .login-links a {
        color: #555;
        text-decoration: none;
    }
    .login-links a:hover {
        text-decoration: underline;
    }
</style>

<div class="login-container">
    <div class="login-box">
        <h2 class="text-center mb-4" style="color: var(--yum-dark-red); font-weight: 700;">Yum Table</h2>
        
        <ul class="nav nav-tabs nav-fill mb-4" id="loginTab" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="normal-login-tab" data-bs-toggle="tab" data-bs-target="#normal-login" type="button">일반 로그인</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="social-login-tab" data-bs-toggle="tab" data-bs-target="#social-login" type="button">소셜 로그인</button>
            </li>
        </ul>

        <div class="tab-content" id="loginTabContent">
            <div class="tab-pane fade show active" id="normal-login" role="tabpanel">
                
                <%-- ? --- 여기가 핵심 수정 부분입니다 --- ? --%>
                <c:if test="${not empty loginRedirectMessage}"><div class="alert alert-info small p-2">${loginRedirectMessage}</div></c:if>
                <c:if test="${not empty error}"><div class="alert alert-danger small p-2">${error}</div></c:if>
                <c:if test="${param.error}"><div class="alert alert-danger small p-2">아이디 또는 비밀번호가 일치하지 않습니다.</div></c:if>
                <c:if test="${not empty msg}"><div class="alert alert-success small p-2">${msg}</div></c:if>

                <form action="${contextPath}/member/login" method="post">
                    <div class="mb-3">
                        <input type="text" class="form-control" id="username" name="username" placeholder="아이디" required>
                    </div>
                    <div class="mb-3">
                        <input type="password" class="form-control" id="password" name="password" placeholder="비밀번호" required>
                    </div>
                    <div class="d-grid">
                        <button type="submit" class="btn btn-primary">로그인</button>
                    </div>
                </form>
            </div>

            <div class="tab-pane fade" id="social-login" role="tabpanel">
                <div class="text-center py-3">
                    <p class="text-muted small">SNS 계정으로 간편하게 로그인하세요.</p>
                    <div class="d-grid gap-2 mt-3">
                        <a href="${contextPath}/oauth2/authorization/google" class="btn btn-outline-dark btn-social">
                            <svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 48 48" class="me-2"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"></path><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"></path><path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"></path><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"></path><path fill="none" d="M0 0h48v48H0z"></path></svg>
                            Google로 로그인
                        </a>
                        <button type="button" class="btn btn-social btn-kakao" disabled>
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 38 38" class="me-2"><path fill="#3C1E1E" d="M19 3c-8.84 0-16 5.82-16 13 0 4.93 3.58 9.22 8.5 11.42L9 34.5l5.5-3.5c1.5.33 3.08.5 4.5.5 8.84 0 16-5.82 16-13S27.84 3 19 3z"/></svg>
                            Kakao로 로그인 (준비중)
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div class="text-center mt-4 login-links">
            <a href="${contextPath}/member/join?role=USER">회원가입</a> | <a href="${contextPath}/member/find-account">아이디/비밀번호 찾기</a>
        </div>
    </div>
</div>
