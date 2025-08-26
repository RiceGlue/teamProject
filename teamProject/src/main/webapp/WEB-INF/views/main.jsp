<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<%-- 
    [개발자 참고]
    이 페이지는 HomeController의 @GetMapping("/main")과 연결됩니다.
    이 페이지가 제대로 동작하려면, HomeController에서 배너 목록(bannerList)을
    DB에서 조회하여 모델에 담아 전달해야 합니다.
--%>

<style>
    /* 얌테이블 커스텀 컬러 팔레트 */
    :root {
        --yum-dark-red: #7B2D26;
        --yum-beige: #D9C6A5;
        --yum-cream: #FDF6EC;
        --yum-dark-blue: #1C1C2A;
    }

    /* 페이지 전체 배경 및 텍스트 색상 */
    .yum-main-page {
        background-color: var(--yum-cream);
        color: var(--yum-dark-blue);
    }

    /* --- 배너 섹션 --- */
    .banner-section {
        background-color: #fff;
        padding: 2rem 0;
        border-bottom: 1px solid #eee;
    }
    .pc-banner .carousel-item img { height: 300px; object-fit: cover; border-radius: 0.75rem; }
    .mobile-banner .carousel-item img { height: 400px; object-fit: cover; border-radius: 0.75rem; }
    .carousel-caption {
        background: linear-gradient(to top, rgba(28, 28, 42, 0.7) 10%, rgba(28, 28, 42, 0) 90%);
        text-align: left;
        padding-left: 2rem;
        padding-bottom: 1.5rem;
        border-bottom-left-radius: 0.75rem;
        border-bottom-right-radius: 0.75rem;
    }
    
    /* --- 검색 섹션 --- */
    .search-section {
        padding: 4rem 0;
    }
    .search-section .form-control {
        border-right: 0;
        border-radius: 0.5rem 0 0 0.5rem;
        padding: 1.25rem 1rem;
    }
    .search-section .btn-search {
        background-color: var(--yum-dark-red);
        color: white;
        border-radius: 0 0.5rem 0.5rem 0;
        padding: 0 2rem;
    }
    
    /* --- 콘텐츠 섹션 --- */
    .content-section {
        padding: 3rem 0 5rem 0;
    }
    .section-title {
        color: var(--yum-dark-red);
        font-weight: 700;
        margin-bottom: 2.5rem;
        text-align: center;
    }
    .category-card {
        background-color: #fff;
        border: 1px solid var(--yum-beige);
        border-radius: 0.75rem;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
        text-decoration: none;
        color: var(--yum-dark-blue);
        font-weight: 500;
    }
    .category-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 20px rgba(0,0,0,0.08);
        border-color: var(--yum-dark-red);
    }
    
    .store-card {
        border: none;
        border-radius: 1rem;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
        background-color: #fff;
        overflow: hidden;
    }
    .store-card:hover {
        transform: translateY(-10px);
        box-shadow: 0 15px 35px rgba(28, 28, 42, 0.1);
    }
    .store-card img {
        height: 200px;
        object-fit: cover;
    }
    .store-card .card-title { font-weight: 700; }
    .store-card .card-text { color: #5a6a7b; }
    .store-card .rating-text { color: var(--yum-beige); font-weight: bold; }
</style>

<div class="yum-main-page">
    <div class="container-fluid banner-section">
        <div class="container">
            <!-- 배너 섹션 (반응형) -->
            <div class="row">
                <div class="col-12">
                    <!-- PC용 배너 (md 사이즈 이상에서 보임) -->
                    <div id="pcBannerCarousel" class="carousel slide d-none d-md-block pc-banner" data-bs-ride="carousel">
                        <div class="carousel-inner">
                            <c:forEach var="banner" items="${bannerList}" varStatus="status">
                                <div class="carousel-item <c:if test='${status.first}'>active</c:if>">
                                    <a href="#"><img src="${contextPath}/images/banners/${banner.imagePath}" class="d-block w-100" alt="${banner.text}">
                                        <div class="carousel-caption"><h5 class="fw-bold">${banner.text}</h5></div>
                                    </a>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                    <!-- 모바일용 배너 (md 사이즈 미만에서 보임) -->
                    <div id="mobileBannerCarousel" class="carousel slide d-block d-md-none mobile-banner" data-bs-ride="carousel">
                        <div class="carousel-inner">
                            <c:forEach var="banner" items="${bannerList}" varStatus="status">
                                <div class="carousel-item <c:if test='${status.first}'>active</c:if>">
                                    <a href="#">
                                        <c:set var="imageSrc" value="${not empty banner.mobileImagePath ? banner.mobileImagePath : banner.imagePath}" />
                                        <img src="${contextPath}/images/banners/${imageSrc}" class="d-block w-100" alt="${banner.text}">
                                        <div class="carousel-caption"><h5 class="fw-bold">${banner.text}</h5></div>
                                    </a>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="container">
        <!-- 검색 섹션 -->
        <section class="search-section">
            <div class="input-group">
                <input type="text" class="form-control" placeholder="지역, 가게 이름 또는 메뉴로 특별한 순간을 찾아보세요">
                <button class="btn btn-search" type="button"><i class="bi bi-search"></i></button>
            </div>
        </section>

        <!-- 지역 선택 섹션 -->
        <section class="content-section">
             <h2 class="section-title">지역별로 찾아보기</h2>
             <div class="row row-cols-2 row-cols-md-4 g-3">
                <div class="col"><a href="${contextPath}/store/storeList?option=region&keyword=서울" class="card category-card text-center p-4"><h5>서울</h5></a></div>
                <div class="col"><a href="${contextPath}/store/storeList?option=region&keyword=경기" class="card category-card text-center p-4"><h5>경기</h5></a></div>
                <div class="col"><a href="${contextPath}/store/storeList?option=region&keyword=대전" class="card category-card text-center p-4"><h5>대전</h5></a></div>
                <div class="col"><a href="${contextPath}/store/storeList?option=region&keyword=부산" class="card category-card text-center p-4"><h5>부산</h5></a></div>
             </div>
        </section>

        <!-- 인기 가게 목록 섹션 -->
        <section class="content-section pt-0">
            <h2 class="section-title">Yum's Pick! 지금 뜨는 인기 맛집</h2>
            <div class="row">
                <c:forEach var="i" begin="1" end="4">
                    <div class="col-md-6 col-lg-3 mb-4">
                        <a href="#" class="text-decoration-none">
                            <div class="card store-card h-100">
                                <img src="https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1974&auto=format&fit=crop" class="card-img-top" alt="가게 이미지 ${i}">
                                <div class="card-body p-4">
                                    <h5 class="card-title">고급 레스토랑 ${i}</h5>
                                    <p class="card-text small">서울 강남구 | 파인 다이닝</p>
                                    <p class="card-text rating-text"><i class="bi bi-star-fill"></i> 4.8 (215)</p>
                                </div>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </section>
    </div>
</div>
