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
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" defer></script>
    
    <style>
        body {
            background-color: #f8f9fc;
        }
        .sidebar {
            width: 250px;
            height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            background-color: #2c3e50;
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
        /* --- ✨ 아코디언 메뉴 스타일 추가 --- */
        .sidebar .nav-item .nav-link[data-bs-toggle="collapse"]::after {
            content: ' ▼';
            float: right;
            font-size: 0.8em;
            transition: transform 0.3s;
        }
        .sidebar .nav-item .nav-link[data-bs-toggle="collapse"].collapsed::after {
            transform: rotate(-90deg);
        }
        .sidebar .collapse .nav-link {
            padding-left: 2rem;
            background-color: #233140;
            font-size: 0.9rem;
        }
        .sidebar .sidebar-divider {
            margin: 1rem 1rem;
            border-top: 1px solid rgba(255, 255, 255, 0.15);
        }
        .content-wrapper {
            margin-left: 250px;
            padding: 2rem;
            width: calc(100% - 250px);
        }
    </style>
</head>
<body>
    <!-- === 좌측 사이드바 메뉴 === -->
    <div class="sidebar">
        <a class="sidebar-brand" href="${contextPath}/admin/dashboard">밥풀 Admin</a>
        
        <hr class="sidebar-divider">
        
        <div class="nav-item">
            <a class="nav-link" href="${contextPath}/admin/dashboard">대시보드</a>
        </div>
        
        <hr class="sidebar-divider">

        <!-- ✨ --- [수정] 회원 관리 아코디언 메뉴 --- ✨ -->
        <div class="nav-item">
            <a class="nav-link collapsed" href="#" data-bs-toggle="collapse" data-bs-target="#collapseMembers" aria-expanded="false" aria-controls="collapseMembers">
                회원
            </a>
            <div id="collapseMembers" class="collapse">
                <a class="nav-link" href="${contextPath}/admin/users">- 일반 회원 관리</a>
                <a class="nav-link" href="${contextPath}/admin/owners">- 가맹점 회원 관리</a>
                <a class="nav-link" href="#">- 벌점 시스템 관리</a>
                <a class="nav-link" href="#">- 블랙리스트 관리</a>
            </div>
        </div>

        <!-- ✨ --- [신규] 가맹점 관리 아코디언 메뉴 --- ✨ -->
        <div class="nav-item">
            <a class="nav-link collapsed" href="#" data-bs-toggle="collapse" data-bs-target="#collapseStores" aria-expanded="false" aria-controls="collapseStores">
                가맹점
            </a>
            <div id="collapseStores" class="collapse">
                <a class="nav-link" href="#">- 가맹점 관리</a>
            </div>
        </div>

        <!-- ✨ --- [신규] 회계 관리 아코디언 메뉴 --- ✨ -->
        <div class="nav-item">
            <a class="nav-link collapsed" href="#" data-bs-toggle="collapse" data-bs-target="#collapseAccounting" aria-expanded="false" aria-controls="collapseAccounting">
                회계 관리
            </a>
            <div id="collapseAccounting" class="collapse">
                <a class="nav-link" href="#">- 가맹점 수수료 관리</a>
            </div>
        </div>

        <!-- ✨ --- [신규] 게시판 관리 아코디언 메뉴 --- ✨ -->
        <div class="nav-item">
            <a class="nav-link collapsed" href="#" data-bs-toggle="collapse" data-bs-target="#collapseBoards" aria-expanded="false" aria-controls="collapseBoards">
                게시판 관리
            </a>
            <div id="collapseBoards" class="collapse">
                <a class="nav-link" href="#">- 공지사항 관리</a>
                <a class="nav-link" href="#">- 고객문의 관리</a>
                <a class="nav-link" href="#">- 리뷰 관리</a>
            </div>
        </div>

        <!-- ✨ --- [신규] 광고 관리 아코디언 메뉴 --- ✨ -->
        <div class="nav-item">
            <a class="nav-link collapsed" href="#" data-bs-toggle="collapse" data-bs-target="#collapseAds" aria-expanded="false" aria-controls="collapseAds">
                광고
            </a>
            <div id="collapseAds" class="collapse">
                <a class="nav-link" href="#">- 배너 관리</a>
            </div>
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
        <jsp:include page="/WEB-INF/views/${body}" />
    </div>
</body>
</html>
