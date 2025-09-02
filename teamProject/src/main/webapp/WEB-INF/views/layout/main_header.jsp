<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<style>
    /* 얌테이블 커스텀 컬러 팔레트 */
    :root {
        --yum-dark-red: #7B2D26;
        --yum-beige: #D9C6A5;
        --yum-cream: #FDF6EC;
        --yum-dark-blue: #1C1C2A;
    }

    .yum-header {
        background-color: var(--yum-dark-blue);
        padding: 0.75rem 0;
        border-bottom: 1px solid rgba(217, 198, 165, 0.2);
    }
    .yum-header .navbar-brand {
        color: var(--yum-cream);
        font-weight: 700;
        font-size: 1.75rem;
    }
    .yum-header .nav-link {
        color: rgba(253, 246, 236, 0.8);
        font-weight: 500;
        transition: color 0.2s ease-in-out;
    }
    .yum-header .nav-link:hover {
        color: var(--yum-cream);
    }
    .yum-header .navbar-text {
        color: rgba(217, 198, 165, 0.9);
    }
    .profile-pic-sm {
        width: 32px;
        height: 32px;
        object-fit: cover;
        border: 2px solid var(--yum-beige);
    }
</style>

    <link rel="stylesheet" href="${contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="${contextPath}/js/common.js" defer></script>

<%-- 세션에 에러/성공 메시지가 있으면 alert로 표시하고, 바로 세션에서 제거합니다. --%>
<c:if test="${not empty sessionScope.errorMessage}">
    <script>
        window.addEventListener('load', () => alert("${sessionScope.errorMessage}"));
    </script>
    <c:remove var="errorMessage" scope="session" />
</c:if>
<c:if test="${not empty sessionScope.successMessage}">
    <script>
        window.addEventListener('load', () => alert("${sessionScope.successMessage}"));
    </script>
    <c:remove var="successMessage" scope="session" />
</c:if>

<header class="yum-header sticky-top">
    <nav class="navbar navbar-expand-lg" data-bs-theme="dark">
        <div class="container">
            <a class="navbar-brand" href="${contextPath}/">Yum Table</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav" aria-controls="mainNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="mainNav">
                <ul class="navbar-nav ms-auto align-items-center">
                    <%-- 로그아웃 상태일 때 --%>
                    <sec:authorize access="isAnonymous()">
                        <%-- ✨ --- [수정] 모바일 화면(lg 사이즈 미만)에서만 보이도록 d-lg-none 클래스 추가 --- ✨ --%>
                        <li class="nav-item d-lg-none"><a class="nav-link" href="${contextPath}/member/login">로그인</a></li>
                        <li class="nav-item d-lg-none"><a class="nav-link" href="${contextPath}/member/join?role=USER">회원가입</a></li>
                    </sec:authorize>

                    <%-- 로그인 상태일 때 --%>
                    <sec:authorize access="isAuthenticated()">
                        <sec:authentication property="principal" var="principal" />
                        <c:set var="isCustomUser" value="${principal['class'].name == 'com.spring.teamProject.vo.UserDetailsVO'}" />

                        <c:if test="${isCustomUser}">
                            <li class="nav-item">
                                <span class="navbar-text me-3 d-flex align-items-center">
                                    <c:choose>
                                        <c:when test="${not empty principal.memberVO.profileImageUrl}">
                                            <img src="${contextPath}${principal.memberVO.profileImageUrl}" class="rounded-circle profile-pic-sm me-2">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${contextPath}/images/default_profile.png" class="rounded-circle profile-pic-sm me-2">
                                        </c:otherwise>
                                    </c:choose>
                                    
                                    <c:if test="${empty principal.memberVO.loginPw and not empty principal.memberVO.socialAccounts}">
                                        <c:forEach var="account" items="${principal.memberVO.socialAccounts}">
                                            <c:if test="${account.provider == 'GOOGLE'}">
                                                <svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 48 48" style="display: block; margin-right: 8px;">
                                                    <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"></path>
                                                    <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"></path>
                                                    <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"></path>
                                                    <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"></path>
                                                    <path fill="none" d="M0 0h48v48H0z"></path>
                                                </svg>
                                            </c:if>
                                        </c:forEach>
                                    </c:if>
                                    
                                    <%-- ✨ --- [수정] 일반 회원 배지 표시 기능 복원 --- ✨ --%>
                                    <c:choose>
                                        <c:when test="${principal.memberVO.role == 'ADMIN'}"><span class="badge bg-danger">관리자</span></c:when>
                                        <c:when test="${principal.memberVO.role == 'OWNER'}"><span class="badge bg-success">가맹점</span></c:when>
                                        <c:otherwise><span class="badge" style="background-color: var(--yum-beige); color: var(--yum-dark-blue);">일반회원</span></c:otherwise>
                                    </c:choose>
                                    
                                    <span class="mx-2">${principal.memberVO.memberName}님</span>
                                </span>
                            </li>
                            <li class="nav-item"><a class="nav-link" href="${contextPath}/member/mypage">마이페이지</a></li>
                        </c:if>
                        
                        <c:if test="${!isCustomUser}">
                            <li class="nav-item">
                                <span class="navbar-text me-3">
                                    추가 정보 입력 후 가입이 완료됩니다.
                                </span>
                            </li>
                        </c:if>
                        
                        <li class="nav-item">
                            <form action="${contextPath}/member/logout" method="post" class="d-inline">
                                <button type="submit" class="btn btn-link nav-link">로그아웃</button>
                            </form>
                        </li>
                    </sec:authorize>
                </ul>
            </div>
        </div>
    </nav>
</header>
