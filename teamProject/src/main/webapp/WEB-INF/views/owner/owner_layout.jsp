<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>얌테이블 점주센터</title>
    <!-- Bootstrap CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons CDN -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f4f7fc;
        }
        .sidebar {
            width: 280px;
            height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            background-color: #2c3e50;
            padding-top: 1rem;
            z-index: 1000;
            overflow-y: auto;
        }
        .sidebar-brand {
            padding: 1rem 1.5rem;
            text-align: center;
            font-size: 1.5rem;
            font-weight: 700;
            color: #fff;
            text-decoration: none;
            display: block;
        }
        .sidebar .nav-item .nav-link {
            padding: 0.9rem 1.5rem;
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            display: block;
            transition: all 0.2s ease-in-out;
            border-left: 4px solid transparent;
        }
        .sidebar .nav-item .nav-link:hover, .sidebar .nav-item .nav-link.active {
            color: #fff;
            background-color: #34495e;
            border-left: 4px solid #3498db;
        }
        .sidebar .nav-item .nav-link[data-bs-toggle="collapse"] { position: relative; }
        .sidebar .nav-item .nav-link[data-bs-toggle="collapse"]::after {
            content: '\203A'; /* 깨지지 않는 CSS 코드로 변경 */
            position: absolute;
            right: 1.5rem;
            font-size: 1.5rem;
            font-weight: bold;
            transition: transform 0.3s ease;
        }
        .sidebar .nav-item .nav-link[data-bs-toggle="collapse"]:not(.collapsed)::after { transform: rotate(90deg); }
        .sidebar .collapse .nav-link {
            padding-left: 2.5rem;
            background-color: rgba(0,0,0,0.15);
            font-size: 0.95rem;
        }
        .sidebar .collapse .collapse .nav-link {
             padding-left: 3.5rem;
             background-color: rgba(0,0,0,0.3);
             font-size: 0.9rem;
        }
        .sidebar-divider {
            margin: 1rem 1.5rem;
            border-top: 1px solid rgba(255, 255, 255, 0.15);
        }
        .content-wrapper {
            margin-left: 280px;
            padding: 2rem;
        }
    </style>
</head>
<body>
    <!-- === 좌측 사이드바 메뉴 === -->
    <div class="sidebar">
        <a class="sidebar-brand" href="${contextPath}/owner/dashboard">얌테이블 점주센터</a>
        <hr class="sidebar-divider">
        
        <div class="nav-item">
            <a class="nav-link active" href="${contextPath}/owner/dashboard"> <i class="bi bi-house-door-fill me-2"></i> 대시보드 홈 </a>
        </div>

        <%-- ? --- 여기가 핵심 수정 부분입니다 --- ? --%>
        <div class="nav-item">
            <a class="nav-link collapsed" href="#" data-bs-toggle="collapse" data-bs-target="#collapseStore">
                <i class="bi bi-shop me-2"></i> 매장
            </a>
            <div id="collapseStore" class="collapse">
                <a class="nav-link collapsed" href="#" data-bs-toggle="collapse" data-bs-target="#collapseStoreSubMenu">
                    - 매장 관리
                </a>
                <div id="collapseStoreSubMenu" class="collapse">
                    <a class="nav-link" href="#">> 메뉴 관리</a>
                    <a class="nav-link" href="#">> 웨이팅 설정/현황</a>
                    <a class="nav-link" href="#">> 예약 설정/현황</a>
                </div>
            </div>
        </div>

        <div class="nav-item">
            <a class="nav-link collapsed" href="#" data-bs-toggle="collapse" data-bs-target="#collapseFinance">
                <i class="bi bi-cash-coin me-2"></i> 정산
            </a>
            <div id="collapseFinance" class="collapse">
                <a class="nav-link" href="#">- 정산 내역</a>
                <a class="nav-link" href="#">- 수익/수수료 분석</a>
            </div>
        </div>

        <div class="nav-item">
            <a class="nav-link" href="#"> <i class="bi bi-chat-left-text-fill me-2"></i> 리뷰 관리 </a>
        </div>

        <div class="nav-item">
            <a class="nav-link collapsed" href="#" data-bs-toggle="collapse" data-bs-target="#collapseMyInfo">
                <i class="bi bi-person-circle me-2"></i> 내 정보
            </a>
            <div id="collapseMyInfo" class="collapse">
                <a class="nav-link" href="${contextPath}/owner/edit-profile">- 회원정보 수정</a>
                <a class="nav-link" href="#">- 회원탈퇴</a>
            </div>
        </div>
        
        <hr class="sidebar-divider">
        
        <div class="nav-item">
            <a class="nav-link" href="${contextPath}/" target="_blank"><i class="bi bi-box-arrow-up-right me-2"></i>메인 페이지로</a>
        </div>
        <div class="nav-item">
            <a class="nav-link" href="javascript:document.getElementById('logout-form').submit();"><i class="bi bi-box-arrow-right me-2"></i>로그아웃</a>
            <form id="logout-form" action="${contextPath}/member/logout" method="post" style="display: none;"></form>
        </div>

    </div>

    <!-- === 우측 메인 콘텐츠 === -->
    <div class="content-wrapper">
        <jsp:include page="/WEB-INF/views/${body}" />
    </div>

    <!-- Bootstrap JS Bundle CDN -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
