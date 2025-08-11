<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<%-- 모든 페이지의 맨 앞에서 contextPath를 한 번만 설정합니다. --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>밥풀</title>

    <%-- CSS는 link 태그로 직접 로드하는 것이 성능에 유리합니다. --%>
    <link rel="stylesheet" href="${contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="${contextPath}/js/common.js" defer></script>
</head>
<body>
    <div><a href="#">언어선택</a></div>

    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <a class="navbar-brand" href="${contextPath}/">메인로고위치</a>
        <ul class="navbar-nav ms-auto">

            <%-- 로그아웃 상태일 때 --%>
            <sec:authorize access="isAnonymous()">
                <li class="nav-item"><a class="nav-link" href="${contextPath}/member/login">로그인</a></li>
                <li class="nav-item"><a class="nav-link" href="${contextPath}/member/join?role=USER">회원가입</a></li>
            </sec:authorize>

            <%-- 로그인 상태일 때 --%>
            <sec:authorize access="isAuthenticated()">
                <%-- 1. 현재 인증(Authentication) 객체 자체를 'authentication'이라는 이름으로 사용합니다.
                       이것이 JSP에서 Security Taglib이 Principal 객체를 노출하는 기본 방식입니다. --%>
                <sec:authentication property="principal" var="principal" />

                <li class="nav-item">
                    <span class="navbar-text me-3 d-flex align-items-center">

                        <%-- ? 여기가 핵심 수정 부분입니다 ? --%>
                        <%-- [수정] 비밀번호가 없고(소셜 전용 계정), 연동된 소셜 계정이 있을 때만 아이콘을 표시합니다. --%>
                        <c:if test="${empty principal.memberVO.loginPw and not empty principal.memberVO.socialAccounts}">
                            <%-- 현재는 구글만 있지만, 나중을 위해 provider를 확인하는 로직을 유지합니다. --%>
                            <c:forEach var="account" items="${principal.memberVO.socialAccounts}">
                                <c:if test="${account.provider == 'GOOGLE'}">
                                    <svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 48 48" xmlns:xlink="http://www.w3.org/1999/xlink" style="display: block;">
                                        <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"></path>
                                        <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"></path>
                                        <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"></path>
                                        <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"></path>
                                        <path fill="none" d="M0 0h48v48H0z"></path>
                                    </svg>
                                </c:if>
                            </c:forEach>
                        </c:if>

                        &nbsp;${principal.memberVO.memberName}님 환영합니다.
                    </span>
                </li>

                <!-- ? --- 여기가 핵심 수정 부분입니다 --- ? -->
                <%-- 사용자의 역할(Role)을 가져와 변수에 저장합니다. --%>
                <sec:authentication property="principal.memberVO.role" var="userRole" />

                <li class="nav-item">
                    <c:choose>
                        <%-- Case 1: 관리자(ADMIN)일 경우 --%>
                        <c:when test="${userRole == 'ADMIN'}">
                            <a class="nav-link" href="${contextPath}/admin/dashboard">마이페이지</a>
                        </c:when>
                        <%-- Case 2: 가맹점주(OWNER)일 경우 (향후 개발) --%>
                        <c:when test="${userRole == 'OWNER'}">
                            <a class="nav-link" href="#">마이페이지</a>
                        </c:when>
                        <%-- Case 3: 그 외(USER)일 경우 --%>
                        <c:otherwise>
                            <a class="nav-link" href="${contextPath}/member/mypage">마이페이지</a>
                        </c:otherwise>
                    </c:choose>
                </li>

                <li class="nav-item">
                    <form action="${contextPath}/member/logout" method="post" class="d-inline">
                        <button type="submit" class="btn btn-link nav-link">로그아웃</button>
                    </form>
                </li>
            </sec:authorize>
        </ul>
    </nav>

    <div class="container mt-4">
