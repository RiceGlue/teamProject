<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>탭잇</title>

    <!-- 공통 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <!-- 예: Bootstrap (CDN 사용 시) -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <!-- 예: jQuery (필요한 경우) -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <!-- 공통 JS -->
    <script src="${pageContext.request.contextPath}/js/common.js"></script>
</head>
<body>
	<div><a href="#">언어선택</a></div>
	
    <!-- 공통 네비게이션 -->
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/">메인로고위치</a>
        <ul class="navbar-nav ms-auto">
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/about">login</a></li>
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/contact">profile</a></li>
        </ul>
    </nav>

    <div class="container mt-4">

