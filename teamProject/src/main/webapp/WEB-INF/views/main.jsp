<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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

            <!-- 메인 배너 -->
            <section class="main-banner mb-5">
                <div id="mainBannerCarousel" class="carousel slide" data-bs-ride="carousel">
                    <div class="carousel-inner" style="border-radius: 1rem;">
                        <div class="carousel-item active"><img src="https://images.unsplash.com/photo-1552566626-52f8b828add9?q=80&w=1200&h=400&fit=crop" class="d-block w-100" alt="배너1"></div>
                        <div class="carousel-item"><img src="https://images.unsplash.com/photo-1414235077428-338989a2e8c0?q=80&w=1200&h=400&fit=crop" class="d-block w-100" alt="배너2"></div>
                    </div>
                </div>
            </section>
            
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
