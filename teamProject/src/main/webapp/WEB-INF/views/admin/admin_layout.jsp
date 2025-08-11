<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 페이지</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <style>
        body { display: flex; }
        .sidebar { width: 250px; height: 100vh; position: fixed; top: 0; left: 0; background-color: #343a40; padding-top: 20px; }
        .sidebar a { padding: 10px 15px; text-decoration: none; font-size: 18px; color: #adb5bd; display: block; }
        .sidebar a:hover { color: #fff; background-color: #495057; }
        .content { margin-left: 250px; padding: 20px; width: 100%; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h4 class="text-white text-center mb-4">관리 시스템</h4>
        <a href="${contextPath}/admin/dashboard">대시보드</a>
        <a href="#">가맹점주 관리</a>
        <a href="#">회계 관리</a>
        <hr class="text-white">
        <a href="${contextPath}/" target="_blank">메인 페이지로</a>
        <a href="javascript:document.getElementById('logout-form').submit();">로그아웃</a>
        <form id="logout-form" action="${contextPath}/member/logout" method="post" style="display: none;"></form>
    </div>

    <div class="content">
        <%-- 이 부분에 각 페이지의 실제 내용이 들어옵니다. --%>
        <jsp:include page="${body}" />
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
