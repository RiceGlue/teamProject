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
    <link rel="stylesheet" href="${contextPath}/css/reset.css">
    <link rel="stylesheet" href="${contextPath}/css/common.css">
    <link rel="stylesheet" href="${contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body>
	<div><a href="#">언어선택</a></div>
	
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <a class="navbar-brand" href="${contextPath}/">메인로고위치</a>
        <ul class="navbar-nav ms-auto">
            
            <%-- 로그아웃 상태일 때 --%>
            <sec:authorize access="isAnonymous()">
                <li class="nav-item"><a class="nav-link" href="${contextPath}/member/login">로그인</a></li>
                <li class="nav-item"><a class="nav-link" href="${contextPath}/member/join-select">회원가입</a></li>
            </sec:authorize>

            <%-- 로그인 상태일 때 --%>
            <sec:authorize access="isAuthenticated()">
                <li class="nav-item">
                    <span class="navbar-text me-3">
                        <%-- (최종 수정) 이제 principal.attributes['name'] 으로 통일하여 사용자 이름을 가져옵니다. --%>
                        <sec:authentication property="principal.attributes['name']"/>님 환영합니다.
                    </span>
                </li>
                <li class="nav-item"><a class="nav-link" href="#">마이페이지</a></li>
                <li class="nav-item">
                    <form action="${contextPath}/member/logout" method="post" class="d-inline">
                        <button type="submit" class="btn btn-link nav-link">로그아웃</button>
                    </form>
                </li>
            </sec:authorize>
        </ul>
    </nav>

    <div class="container mt-4">
