<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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

    .yum-main-page {
        background-color: var(--yum-cream);
        color: var(--yum-dark-blue);
    }

    /* --- 검색창 --- */
    .search-bar {
        background-color: #fff;
        padding: 2rem;
        border-radius: 1rem;
        box-shadow: 0 10px 30px rgba(0,0,0,0.07);
    }
    .search-bar .form-control { padding: 1rem; }
    .search-bar .btn { background-color: var(--yum-dark-red); color: white; padding: 0 2rem; }

    /* --- 카테고리 아이콘 --- */
    .category-icons .nav-link { color: var(--yum-dark-blue); text-align: center; text-decoration: none; }
    .category-icons .icon-circle {
        width: 60px; height: 60px; background-color: #fff; border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        margin: 0 auto 0.5rem; font-size: 1.5rem; color: var(--yum-dark-red);
        transition: all 0.2s ease;
        border: 1px solid #eee;
    }
    .category-icons .nav-link:hover .icon-circle { background-color: var(--yum-dark-red); color: #fff; }

    /* --- 반응형 배너 스타일 --- */
    .banner-carousel {
        border-radius: 1rem;
        overflow: hidden;
    }
    
    .banner-carousel img {
        width: 100%;
        height: auto; /* 자동 높이로 변경 */
        max-height: 400px; /* PC 최대 높이 제한 */
        object-fit: contain; /* 전체 이미지를 보여주도록 변경 */
        background-color: var(--yum-cream); /* 여백 부분 배경색 */
    }
    
    /* 모바일에서 배너 높이 조정 */
    @media (max-width: 768px) {
        .banner-carousel img {
            max-height: 250px; /* 모바일 최대 높이를 더 작게 조정 */
        }
        
        .search-bar {
            padding: 1.5rem;
        }
        
        .category-icons .icon-circle {
            width: 50px;
            height: 50px;
            font-size: 1.2rem;
        }
    }

    /* --- 사이드바 (로그인 박스 등) --- */
    .sidebar-box {
        background-color: #fff;
        padding: 1.5rem;
        border-radius: 1rem;
        box-shadow: 0 5px 15px rgba(0,0,0,0.05);
    }
    .sidebar-title {
        color: var(--yum-dark-red);
        font-weight: 700;
        border-bottom: 2px solid var(--yum-beige);
        padding-bottom: 0.5rem;
        margin-bottom: 1rem;
    }
    .profile-pic-md {
        width: 60px;
        height: 60px;
        object-fit: cover;
        border: 3px solid var(--yum-beige);
    }

    /* --- 가게 카드 --- */
    .store-card {
        border: 1px solid #eee;
        border-radius: 1rem;
        transition: all 0.3s ease;
        background-color: #fff;
    }
    .store-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(0,0,0,0.1);
    }
    .store-card img {
        height: 180px;
        object-fit: cover;
        border-top-left-radius: 1rem;
        border-top-right-radius: 1rem;
    }
    .store-card .card-title { font-weight: 700; }
    .store-card .card-text { color: #5a6a7b; }
    .store-card .rating-text { color: var(--yum-beige); font-weight: bold; }

    /* 디버깅용 스타일 - 필요시 주석 해제하여 사용 */
    /*
    .debug-info {
        font-size: 0.85em;
        background: #f8f9fa;
        padding: 0.5rem;
        border-radius: 0.25rem;
        margin-bottom: 1rem;
    }
    */
</style>

<main class="container py-5 yum-main-page">
    <div class="row g-5">
        <!-- ======================================= -->
        <!-- 메인 콘텐츠 (왼쪽) -->
        <!-- ======================================= -->
        <div class="col-lg-8">
            <!-- 검색창 -->
            <section class="search-bar mb-5">
                <div class="input-group">
                    <input type="text" class="form-control" placeholder="지역, 가게, 메뉴로 특별한 순간을 찾아보세요">
                    <button class="btn" type="button"><i class="bi bi-search"></i></button>
                </div>
            </section>

            <!-- 카테고리 아이콘 -->
            <section class="category-icons mb-5">
                <ul class="nav justify-content-around">
                    <li class="nav-item"><a href="#" class="nav-link"><div class="icon-circle"><i class="bi bi-geo-alt-fill"></i></div><span>지역별</span></a></li>
                    <li class="nav-item"><a href="#" class="nav-link"><div class="icon-circle"><i class="bi bi-egg-fried"></i></div><span>음식별</span></a></li>
                    <li class="nav-item"><a href="#" class="nav-link"><div class="icon-circle"><i class="bi bi-star-fill"></i></div><span>인기 맛집</span></a></li>
                    <li class="nav-item"><a href="#" class="nav-link"><div class="icon-circle"><i class="bi bi-shop-window"></i></div><span>신규 오픈</span></a></li>
                </ul>
            </section>

            <!-- 
            ========================================
            배너 반응형 디버깅 정보 (개발용)
            ========================================
            필요시 아래 주석을 해제하여 디버깅 정보 표시
            - 배너 개수 및 이미지 경로 확인
            - 현재 화면 모드 (PC/모바일) 표시
            - Bootstrap 반응형 클래스 작동 상태 확인
            ========================================
            -->
            <!--
            <div class="alert alert-warning debug-info">
                <strong>?? 배너 디버깅 정보:</strong><br>
                배너 개수: ${fn:length(bannerList)}<br>
                <c:forEach var="banner" items="${bannerList}" varStatus="status">
                    배너${status.index + 1}: PC="${banner.imagePath}", 모바일="${banner.mobileImagePath}" (${not empty banner.mobileImagePath ? '있음' : '없음'})<br>
                </c:forEach>
                현재 화면 크기: <span id="screenSize"></span><br>
                Bootstrap 반응형 테스트: 
                <span class="d-none d-md-inline text-success fw-bold">? 데스크톱 모드 (md 이상)</span>
                <span class="d-md-none text-primary fw-bold">?? 모바일 모드 (md 미만)</span>
            </div>
            -->

            <!-- 메인 배너 - 반응형 개선 -->
            <section class="main-banner mb-5">
                <div id="mainBannerCarousel" class="carousel slide banner-carousel" data-bs-ride="carousel">
                    <div class="carousel-inner">
                        <c:choose>
                            <c:when test="${not empty bannerList}">
                                <c:forEach var="banner" items="${bannerList}" varStatus="status">
                                    <div class="carousel-item <c:if test='${status.first}'>active</c:if>">
                                        <%-- 
                                        배너별 디버깅 정보 (개발용)
                                        필요시 주석 해제하여 각 배너 상태 확인
                                        --%>
                                        <%--
                                        <div class="position-absolute top-0 start-0 bg-dark text-white p-2 small" style="z-index: 10; opacity: 0.8;">
                                            배너${status.index + 1}: ${not empty banner.mobileImagePath ? '모바일용 별도 이미지 있음' : 'PC용만 사용'}
                                        </div>
                                        --%>
                                        
                                        <%-- 연결 유형에 따라 다른 링크를 생성합니다. --%>
                                        <c:choose>
                                            <c:when test="${not empty banner.promotionId}">
                                                <a href="${contextPath}/promotion/detail?id=${banner.promotionId}">
                                            </c:when>
                                            <c:when test="${not empty banner.linkUrl}">
                                                <a href="${banner.linkUrl}" target="_blank">
                                            </c:when>
                                            <c:otherwise>
                                                <a> <%-- 링크가 없는 경우 --%>
                                            </c:otherwise>
                                        </c:choose>
                                            <%-- 모바일용 배너가 있는 경우 --%>
                                            <c:choose>
                                                <c:when test="${not empty banner.mobileImagePath}">
                                                    <%-- PC/태블릿: PC용 배너 --%>
                                                    <img src="${contextPath}/banner-images/${banner.imagePath}" 
                                                         class="d-block w-100 d-none d-md-block" 
                                                         alt="${banner.text}">
                                                         <%-- 디버깅용 테두리: style="border: 3px solid red;" --%>
                                                    <%-- 모바일: 모바일용 배너 --%>
                                                    <img src="${contextPath}/banner-images/${banner.mobileImagePath}" 
                                                         class="d-block w-100 d-md-none" 
                                                         alt="${banner.text}">
                                                         <%-- 디버깅용 테두리: style="border: 3px solid blue;" --%>
                                                </c:when>
                                                <c:otherwise>
                                                    <%-- 모바일용 배너가 없으면 PC용 배너를 모든 환경에서 사용 --%>
                                                    <img src="${contextPath}/banner-images/${banner.imagePath}" 
                                                         class="d-block w-100" 
                                                         alt="${banner.text}">
                                                         <%-- 디버깅용 테두리: style="border: 3px solid green;" --%>
                                                </c:otherwise>
                                            </c:choose>
                                        </a>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <%-- 표시할 배너가 없을 때 기본 이미지 --%>
                                <div class="carousel-item active">
                                    <img src="https://placehold.co/1200x400/FDF6EC/7B2D26?text=Yum+Table" 
                                         class="d-block w-100" 
                                         alt="기본 배너">
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    
                    <%-- 배너가 2개 이상일 때만 컨트롤러 표시 --%>
                    <c:if test="${fn:length(bannerList) > 1}">
                        <button class="carousel-control-prev" type="button" data-bs-target="#mainBannerCarousel" data-bs-slide="prev">
                            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">이전</span>
                        </button>
                        <button class="carousel-control-next" type="button" data-bs-target="#mainBannerCarousel" data-bs-slide="next">
                            <span class="carousel-control-next-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">다음</span>
                        </button>
                        
                        <%-- 인디케이터 --%>
                        <div class="carousel-indicators">
                            <c:forEach var="banner" items="${bannerList}" varStatus="status">
                                <button type="button" data-bs-target="#mainBannerCarousel" 
                                        data-bs-slide-to="${status.index}" 
                                        <c:if test="${status.first}">class="active"</c:if>
                                        aria-label="슬라이드 ${status.index + 1}"></button>
                            </c:forEach>
                        </div>
                    </c:if>
                </div>
            </section>
            
            <!-- 
            ========================================
            배너 상태 디버깅 정보 (개발용)
            ========================================
            필요시 아래 주석을 해제하여 현재 배너 표시 모드 확인
            ========================================
            -->
            <!--
            <div class="alert alert-info debug-info">
                <strong>현재 배너 상태:</strong>
                <div class="d-none d-md-block">??? <strong>PC/태블릿 모드</strong> - PC용 배너가 표시됩니다 (빨간 테두리) | object-fit: contain (전체 표시, 최대 400px)</div>
                <div class="d-md-none">?? <strong>모바일 모드</strong> - 모바일용 배너가 있으면 모바일용(파란 테두리), 없으면 PC용(초록 테두리)이 표시됩니다 | object-fit: contain (전체 표시, 최대 250px)</div>
            </div>
            -->
            
            <!-- 가게 목록 -->
            <section>
                <h4 class="mb-4 fw-bold">Yum's Pick!</h4>
                <div class="row row-cols-1 row-cols-md-2 g-4">
                    <div class="col"><div class="card store-card"><img src="https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=400&h=300&fit=crop" class="card-img-top"><div class="card-body p-3"><h5 class="card-title">고급 레스토랑 1</h5><p class="card-text small">서울 강남구 | 파인 다이닝</p><p class="card-text rating-text"><i class="bi bi-star-fill"></i> 4.8</p></div></div></div>
                    <div class="col"><div class="card store-card"><img src="https://images.unsplash.com/photo-1578474846511-04ba529f0b88?q=80&w=400&h=300&fit=crop" class="card-img-top"><div class="card-body p-3"><h5 class="card-title">캐주얼 다이닝 2</h5><p class="card-text small">서울 홍대 | 이탈리안</p><p class="card-text rating-text"><i class="bi bi-star-fill"></i> 4.7</p></div></div></div>
                </div>
            </section>
        </div>

        <!-- ======================================= -->
        <!-- 사이드바 (오른쪽) -->
        <!-- ======================================= -->
        <div class="col-lg-4 d-none d-lg-block">
            <div class="sidebar-box mb-4">
                <sec:authorize access="isAnonymous()">
                    <h5 class="sidebar-title">로그인</h5>
                    <p class="small text-muted">로그인하고 얌테이블의 모든 서비스를 이용해보세요.</p>
                    <div class="d-grid gap-2">
                        <a href="${contextPath}/member/login" class="btn" style="background-color: var(--yum-dark-red); color: white;">로그인 / 회원가입</a>
                    </div>
                </sec:authorize>

                <sec:authorize access="isAuthenticated()">
                    <sec:authentication property="principal" var="principal" />
                    <c:set var="isCustomUser" value="${principal['class'].name == 'com.spring.teamProject.vo.UserDetailsVO'}" />

                    <c:if test="${isCustomUser}">
                        <div class="d-flex align-items-center mb-3">
                            <c:choose>
                                <c:when test="${not empty principal.memberVO.profileImageUrl}">
                                    <img src="${contextPath}${principal.memberVO.profileImageUrl}" class="rounded-circle profile-pic-md">
                                </c:when>
                                <c:otherwise>
                                    <img src="${contextPath}/images/default_profile.png" class="rounded-circle profile-pic-md">
                                </c:otherwise>
                            </c:choose>
                            <div class="ms-3">
                                <h5 class="mb-0 fw-bold">${principal.memberVO.memberName} 님</h5>
                                <p class="mb-0 text-muted small">매너온도: ${principal.memberVO.mannerTemperature}°C</p>
                            </div>
                        </div>
                        <div class="d-grid">
                             <a href="${contextPath}/member/mypage" class="btn" style="background-color: var(--yum-beige);">마이페이지</a>
                        </div>
                    </c:if>
                </sec:authorize>
            </div>

            <div class="sidebar-box">
                <h5 class="sidebar-title">최근 방문 기록</h5>
                <p class="small text-muted">최근 방문한 가게 목록이 여기에 표시됩니다.</p>
            </div>
        </div>
    </div>
</main>

<!-- 
========================================
배너 반응형 디버깅 JavaScript (개발용)
========================================
필요시 아래 주석을 해제하여 콘솔에서 상세 디버깅 정보 확인
- 화면 크기 및 Bootstrap 버전 정보
- 현재 보이는 배너 이미지 분석
========================================
-->
<!--
<script>
    // 화면 크기 정보 업데이트
    function updateScreenInfo() {
        const screenSizeElement = document.getElementById('screenSize');
        if (screenSizeElement) {
            screenSizeElement.textContent = window.innerWidth + 'x' + window.innerHeight;
        }
        
        // 콘솔에 디버깅 정보 출력
        console.log('=== 배너 반응형 디버깅 정보 ===');
        console.log('화면 크기:', window.innerWidth + 'x' + window.innerHeight);
        console.log('Bootstrap md 브레이크포인트(768px) 기준:', window.innerWidth >= 768 ? '데스크톱 모드' : '모바일 모드');
        console.log('Bootstrap 버전:', typeof bootstrap !== 'undefined' ? 'Bootstrap 5.x 감지됨' : 'Bootstrap 미감지');
        
        // 현재 보이는 배너 이미지들 체크
        const visibleImages = document.querySelectorAll('.carousel-inner img:not([style*="display: none"])');
        console.log('현재 보이는 배너 이미지 수:', visibleImages.length);
        visibleImages.forEach((img, index) => {
            console.log(`배너 ${index + 1}:`, {
                src: img.src,
                classes: img.className,
                alt: img.alt,
                border: img.style.border
            });
        });
    }
    
    // 페이지 로드 시와 화면 크기 변경 시 정보 업데이트
    updateScreenInfo();
    window.addEventListener('resize', updateScreenInfo);
</script>
-->