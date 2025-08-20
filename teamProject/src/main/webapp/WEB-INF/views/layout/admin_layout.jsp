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
    
    <!-- ✨ --- 임시 대시보드 CSS --- ✨ -->
    <style>
        body {
            background-color: #f8f9fc; /* 전체 배경색 */
        }
        .sidebar {
            width: 250px;
            height: 100vh; /* 화면 전체 높이 */
            position: fixed; /* 화면 스크롤과 상관없이 고정 */
            top: 0;
            left: 0;
            background-color: #2c3e50; /* 사이드바 배경색 */
            padding-top: 20px;
            z-index: 100;
        }
        .sidebar .sidebar-brand {
            padding: 1.5rem 1rem;
            text-align: center;
            font-size: 1.5rem;
            font-weight: bold;
            color: #fff;
            text-decoration: none;
        }
        .sidebar .nav-item .nav-link {
            padding: 1rem;
            color: rgba(255, 255, 255, 0.8);
            text-decoration: none;
            display: block;
            transition: all 0.3s;
        }
        .sidebar .nav-item .nav-link:hover {
            color: #fff;
            background-color: #34495e;
        }
        .sidebar .sidebar-divider {
            margin: 1rem 1rem;
            border-top: 1px solid rgba(255, 255, 255, 0.15);
        }
        .content-wrapper {
            margin-left: 250px; /* 사이드바 너비만큼 왼쪽 여백 */
            padding: 2rem;
            width: calc(100% - 250px); /* 전체 너비에서 사이드바 너비 빼기 */
        }
    </style>
    
    <!-- ✨ --- [위치 이동] 스크립트 파일을 head로 이동 --- ✨ -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" defer></script>
</head>
<body>
    <!-- === 좌측 사이드바 메뉴 === -->
    <div class="sidebar">
        <a class="sidebar-brand" href="${contextPath}/admin/dashboard">얌테이블 Admin</a>
        
        <hr class="sidebar-divider">
        
        <div class="nav-item">
            <a class="nav-link" href="${contextPath}/admin/dashboard">대시보드</a>
        </div>
        
        <hr class="sidebar-divider">
        
        <div class="nav-item">
            <a class="nav-link" href="#">회원 관리</a>
        </div>
        <div class="nav-item">
            <a class="nav-link" href="#">가맹점 관리</a>
        </div>
        
        <hr class="sidebar-divider">
        
        <div class="nav-item">
            <a class="nav-link" href="${contextPath}/" target="_blank">메인 페이지로</a>
        </div>
        <div class="nav-item">
            <a class="nav-link" href="javascript:document.getElementById('logout-form').submit();">로그아웃</a>
            <form id="logout-form" action="${contextPath}/member/logout" method="post" style="display: none;"></form>
        </div>
    </div>

    <!-- === 우측 메인 콘텐츠 === -->
    <div class="content-wrapper">
        <%-- 이 부분에 각 페이지의 실제 내용이 들어옵니다. --%>
        <jsp:include page="${body}" />
    </div>

</body>
</html>
