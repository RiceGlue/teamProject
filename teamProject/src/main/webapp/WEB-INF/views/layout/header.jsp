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
                <li class="nav-item"><a class="nav-link" href="${contextPath}/member/join-select">회원가입</a></li>
            </sec:authorize>

            <%-- 로그인 상태일 때 --%>
            <sec:authorize access="isAuthenticated()">
                <li class="nav-item">
                    <span class="navbar-text me-3 d-flex align-items-center">
                        <%-- (신규) principal.attributes.socialProvider 값을 확인하여 로고를 표시합니다. --%>

                        <%-- (디버깅용) attributes 맵 전체를 출력해봅니다. --%>
                        <div style="border: 1px solid blue; padding: 2px; margin-right: 5px; font-size: 10px;">
                            All Attributes: ${principal.attributes}
                            
                        </div>
                        
                        <c:if test="${principal.attributes['socialProvider'] == 'GOOGLE'}">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-google me-2" viewBox="0 0 16 16">
                                <path d="M15.545 6.558a9.42 9.42 0 0 1 .139 1.626c0 2.434-.87 4.492-2.384 5.885h.002C11.978 15.292 10.158 16 8 16A8 8 0 1 1 8 0a7.689 7.689 0 0 1 5.352 2.082l-2.284 2.284A4.347 4.347 0 0 0 8 3.166c-2.087 0-3.86 1.408-4.492 3.25C2.806 7.655 2.5 8.5 2.5 9.5s.306 1.845.808 2.584C3.96 13.592 5.813 15 8 15c1.45 0 2.72-.482 3.697-1.266a4.772 4.772 0 0 0 1.562-3.428H8.19V9.045h7.355z"/>
                            </svg>
                        </c:if>
                        
                        <sec:authentication property="principal.attributes['name']"/>님 환영합니다.
                    </span>
                </li>
                <li class="nav-item"><a class="nav-link" href="${contextPath}/member/mypage">마이페이지</a></li>
                <li class="nav-item">
                    <form action="${contextPath}/member/logout" method="post" class="d-inline">
                        <button type="submit" class="btn btn-link nav-link">로그아웃</button>
                    </form>
                </li>
            </sec:authorize>
        </ul>
    </nav>

    <div class="container mt-4">