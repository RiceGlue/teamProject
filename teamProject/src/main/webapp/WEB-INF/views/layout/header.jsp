<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- (신규) 스프링 시큐리티 태그 라이브러리 추가 --%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>밥풀</title>

    <!-- 공통 CSS -->
    <link rel="stylesheet" href="${contextPath}/css/reset.css">
    <link rel="stylesheet" href="${contextPath}/css/common.css">
    <link rel="stylesheet" href="${contextPath}/css/style.css">
    
    <!-- Bootstrap (CDN) -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    
    <!-- jQuery (CDN) -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>
	<div><a href="#">언어선택</a></div>
	
    <!-- 공통 네비게이션 -->
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <a class="navbar-brand" href="${contextPath}/">메인로고위치</a>
        <ul class="navbar-nav ms-auto">
            <%-- sec:authorize 태그를 사용하여 로그인 상태에 따라 다른 메뉴를 보여줍니다. --%>
            
            <%-- 1. 로그아웃 상태일 때 (isAnonymous()) --%>
            <sec:authorize access="isAnonymous()">
                <li class="nav-item"><a class="nav-link" href="${contextPath}/member/login">로그인</a></li>
                <li class="nav-item"><a class="nav-link" href="${contextPath}/member/join-select">회원가입</a></li>
            </sec:authorize>

            <%-- 2. 로그인 상태일 때 (isAuthenticated()) --%>
            <sec:authorize access="isAuthenticated()">
                <li class="nav-item">
                    <%-- sec:authentication으로 로그인한 사용자 이름(loginId)을 가져옵니다. --%>
                    <span class="navbar-text me-3">
                        <sec:authentication property="principal.username"/>님 환영합니다.
                    </span>
                </li>
                <li class="nav-item"><a class="nav-link" href="#">마이페이지</a></li>
                <li class="nav-item">
                    <%-- 로그아웃은 POST 방식으로 요청해야 안전합니다. --%>
                    <form action="${contextPath}/member/logout" method="post" class="d-inline">
                        <button type="submit" class="btn btn-link nav-link">로그아웃</button>
                    </form>
                </li>
            </sec:authorize>
        </ul>
    </nav>

    <div class="container mt-4">
