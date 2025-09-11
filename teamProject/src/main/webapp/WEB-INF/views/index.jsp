<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<!-- Google Maps JavaScript API 로드 -->
<script async defer
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB1kAhEMiW_-y5zg2uFTUeAOTG_uVO_kts&callback=initMap&libraries=places">
</script>

<!-- jQuery (AJAX 용) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    /* 얌테이블 커스텀 컬러 팔레트 */
    :root {
        --yum-dark-red: #7B2D26;
        --yum-beige: #D9C6A5;
        --yum-cream: #FDF6EC;
        --yum-dark-blue: #1C1C2A;
    }

    body {
        background-color: var(--yum-cream);
    }

    .yum-main-page {
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

    /* 검색창 포커스 시 테두리 스타일 추가 */
    .search-bar .input-group:focus-within {
        box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
        border-radius: 0.5rem; /* input-group 전체에 둥근 모서리를 적용하여 자연스럽게 만듭니다. */
        transition: box-shadow .15s ease-in-out;
    }
    .search-bar .form-control:focus {
        box-shadow: none; /* input 개별 포커스 효과는 제거합니다. */
        border-color: #ced4da; /* Bootstrap 기본 테두리 색상을 유지합니다. */
    }

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

    /* --- 가게/리뷰 카드 공통 스타일 --- */
    .store-carousel {
        display: flex;
        overflow-x: auto;
        gap: 16px;
        padding: 10px 0;
        scroll-snap-type: x mandatory;
        scrollbar-width: thin;
    }
    .store-carousel::-webkit-scrollbar {
        height: 8px;
    }
    .store-carousel::-webkit-scrollbar-thumb {
        background-color: var(--yum-beige);
        border-radius: 4px;
    }
    .card {
        min-width: 280px;
        flex: 0 0 auto;
        scroll-snap-align: start;
        border: 1px solid #eee;
        border-radius: 1rem;
        transition: all 0.3s ease;
        background-color: #fff;
        text-decoration: none;
        color: inherit;
        position: relative; /* 위시리스트 버튼의 기준점이 되도록 추가 */
    }

    /* [19차 수정] 모든 카드에 공통 호버 효과를 주기 위해 기존 .card:hover 스타일은 제거합니다. */

    .card-img-top {
        height: 180px;
        object-fit: cover;
        border-top-left-radius: 1rem;
        border-top-right-radius: 1rem;
    }
    .card-title { font-weight: 700; }
    .card-text { color: #5a6a7b; font-size: 0.9rem; }
    .rating-text { color: #ffc107; font-weight: bold; }

    /* 리뷰 카드 전용 스타일 */
    .review-card .card-body {
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }
    .review-card .review-content {
        font-style: italic;
        color: #333;
        border-left: 3px solid var(--yum-beige);
        padding-left: 0.75rem;
        margin: 0.5rem 0;
        font-size: 0.95rem;
    }
    .review-card .store-info {
        font-size: 0.85rem;
        font-weight: 500;
        color: #777;
        margin-top: auto; /* 카드 하단에 고정 */
    }

    .wishlist-btn{
        position: absolute;
        top: 10px;
        right: 10px;
        z-index: 10;
        background:none;
        border:none;
        cursor:pointer;
        font-size:24px;
        color:#ccc;
        transition:color 0.3s ease;
    }
    .wishlist-btn.active{color:#ff6347;}

    /* --- 드래그 슬라이더 공통 스타일 --- */
    .slider-container {
        cursor: grab;
        user-select: none;
        -webkit-user-select: none;
        overflow-x: scroll;
        position: relative;
        padding: 10px 0 1.5rem 0;
        scrollbar-width: none; /* Firefox */
    }
    .slider-container::-webkit-scrollbar {
        display: none; /* Safari and Chrome */
    }

    .slider-container.active {
        cursor: grabbing;
    }
    .slider-track {
        display: inline-flex;
        gap: 24px;
        padding-right: 1.5rem; /* 마지막 카드의 우측 여백 확보 */
    }
    /* a태그인 card 자체는 클릭 가능해야 하므로 pointer-events를 설정하지 않습니다. */
    /* card 내부의 다른 요소들(img, p 등)의 이벤트를 막아 드래그를 원활하게 합니다. */
    .slider-track .card * {
        pointer-events: none;
    }

    /* [수정] 슬라이더 내부의 위시리스트 버튼은 클릭이 가능하도록 예외 처리 */
    .slider-track .card .wishlist-btn,
    .slider-track .card .wishlist-btn * {
        pointer-events: auto;
    }

    /* --- [19차 수정] 슬라이더 내 모든 카드 (리뷰, 맛집)에 수직 그림자 효과 통일 --- */
    /* 기존 .review-card의 그림자 효과를 모든 .slider-track 안의 .card로 확장 적용합니다. */
    .slider-track .card {
        box-shadow: 0 4px 0px rgba(0, 0, 0, 0.1);
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .slider-track .card:hover {
        transform: translateY(-4px);
        /* [20차 수정] 마우스 오버 시 그림자 색상을 사이트 테마 색상(진한 갈색)으로 변경합니다. */
        box-shadow: 0 8px 0px rgba(123, 45, 38);
    }
</style>

<script>
const memberId = "${memberId}";
var contextPath = '${contextPath}';
var map; // 지도 객체를 전역 변수로 선언

    // Google Maps API 콜백 함수
    function initMap() {
        // 1. 페이지 로드 시 즉시 지도를 기본 위치(서울)로 생성합니다.
        map = new google.maps.Map(document.getElementById("map"), {
            zoom: 11,
            center: { lat: 37.5665, lng: 126.9780 }, // 기본 위치: 서울
        });

        // 2. 사용자 위치 정보 요청을 시작합니다.
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(success, error);
        } else {
            document.getElementById("address").innerText = "위치 정보를 지원하지 않는 브라우저입니다.";
        }
    }

    function success(position) {
        const lat = position.coords.latitude;
        const lng = position.coords.longitude;

        // 3. 사용자 위치를 가져오면, 기존 지도의 중심을 이동시킵니다.
        map.setCenter({ lat: lat, lng: lng });
        map.setZoom(14);

        getAddressFromCoords(lat, lng);
    }

    function error() {
        document.getElementById("address").innerText = "위치 정보를 불러올 수 없습니다. 기본 위치의 맛집을 표시합니다.";
    }

    // 4. 위도/경도로 주소 얻기
    function getAddressFromCoords(lat, lng) {
        const geocoder = new google.maps.Geocoder();
        const latlng = { lat: parseFloat(lat), lng: parseFloat(lng) };

        geocoder.geocode({ location: latlng }, function (results, status) {
            if (status === "OK" && results[0]) {
                const fullAddress = results[0].formatted_address;
                document.getElementById("address").innerText = fullAddress;
                const dong = extractDongAddress(results[0].address_components);
                if (dong) {
                    fetchNearbyStores(dong);
                }
            } else {
                document.getElementById("address").innerText = "주소를 가져올 수 없습니다.";
            }
        });
    }

    // 5. 주소 컴포넌트에서 동 주소 추출
    function extractDongAddress(components) {
        for (let i = 0; i < components.length; i++) {
            const types = components[i].types;
            if (types.includes("sublocality_level_1") || types.includes("locality") || types.includes("administrative_area_level_3")) {
                return components[i].long_name;
            }
        }
        return null;
    }

    // 6. AJAX로 동 주소 전달 → 매장 리스트 받아오기
    function fetchNearbyStores(dong) {
        console.log("AJAX 요청 시작. 동 주소:", dong);
        $.ajax({
            url: "${contextPath}/store/searchStoreNearUser",
            method: "GET",
            data: { location: dong },
            success: function (storeList) {
                console.log("AJAX 요청 성공! 받은 데이터:", storeList);
                if (storeList.length === 0) {
                    document.getElementById("nearbyStores").innerHTML = "<p>근처에 매장이 없습니다.</p>";
                    return;
                }
                displayStoresOnMap(storeList, map);
                displayStoreCards(storeList, dong);
            },
            error: function (xhr, status, error) {
                console.error("AJAX 요청 실패:", status, error);
                document.getElementById("nearbyStores").innerHTML = "<p>매장 정보를 불러오는 데 실패했습니다.</p>";
            }
        });
    }

    // 7. 매장 주소 → 위도/경도 → 지도 마커 표시
    function displayStoresOnMap(storeList, mapInstance) {
        const geocoder = new google.maps.Geocoder();
        // [42차 수정] 한 번에 너무 많은 주소 변환 요청을 보내면 API 제한에 걸릴 수 있으므로,
        // 각 요청 사이에 약간의 지연(delay)을 주어 안정적으로 처리합니다.
        storeList.forEach((store, index) => {
            setTimeout(() => {
                geocoder.geocode({ address: store.roadAddress }, function (results, status) {
                    if (status === "OK" && results[0]) {
                        const location = results[0].geometry.location;
                        new google.maps.Marker({
                            position: location,
                            map: mapInstance,
                            title: store.storeName
                        });
                    } else {
                        console.error(`'${store.roadAddress}' 주소 변환 실패: ${status}`);
                    }
                });
            }, index * 200); // 각 마커마다 0.2초의 지연을 줍니다.
        });
    }

    function displayStoreCards(storeList, dong) {
        console.log("UI카드 시작");
        const container = document.getElementById("nearbyStores");

        if (!container) {
            console.error("nearbyStores 컨테이너를 찾지 못했습니다.");
            return;
        }

        container.innerHTML = ""; // 초기화

        const limitedStoreList = storeList.slice(0, 10);

        limitedStoreList.forEach(store => {
            const card = document.createElement("a");
            card.className = "card";
            card.href = contextPath + '/store/storeDetail?storeId=' + store.storeId;

            const imageUrl = store.fileName 
                ? contextPath + '/images/store/' + store.fileName
                : 'https://placehold.co/280x180/FDF6EC/7B2D26?text=' + encodeURIComponent(store.storeName);

            card.innerHTML =
                '<img src="' + imageUrl + '" class="card-img-top" alt="' + store.storeName + '">' +
                '<div class="card-body p-3">' +
                    '<div class="d-flex justify-content-between align-items-start">' +
                        '<h5 class="card-title mb-1">' + store.storeName + '</h5>' +
                    '</div>' +
                    '<p class="card-text small rating-text"><i class="bi bi-star-fill"></i> ' + (store.avgRating || '평점없음') + ' (리뷰 ' + (store.countRating || 0) + ')</p>' +
                    '<p class="card-text small text-muted"><i class="bi bi-geo-alt me-1"></i>' + store.roadAddress + '</p>' +
                    '<p class="card-text small text-muted"><i class="bi bi-telephone me-1"></i>' + store.localNumber + '-' + store.number1 + '-' + store.number2 + '</p>' +
                    '<p class="card-text small text-muted text-truncate">' + store.description + '</p>' +
                '</div>' +
                '<button type="button" class="wishlist-btn" data-store-id="' + store.storeId + '">' +
                    '<i class="fa fa-bookmark"></i>' +
                '</button>';

            container.appendChild(card);

            if (memberId && memberId !== 'null' && memberId !== 'undefined') {
                const wishlistBtn = card.querySelector('.wishlist-btn');
                if (wishlistBtn) {
                    checkWishlistStatus(store.storeId, wishlistBtn);
                }
            }
        });
        
        if (storeList.length > 0) {
            const loadMoreCard = document.createElement("a");
            loadMoreCard.href = contextPath + "/store/storeList?option=userLocation&keyword=" + encodeURIComponent(dong);
            loadMoreCard.className = "card d-flex align-items-center justify-content-center text-decoration-none text-muted";
            loadMoreCard.style.minWidth = '280px';
            loadMoreCard.style.backgroundColor = '#f8f9fa';
            loadMoreCard.style.borderStyle = 'dashed';

            loadMoreCard.innerHTML =
                '<div class="text-center">' +
                    '<i class="bi bi-arrow-right-circle fs-1"></i>' +
                    '<p class="mt-2 mb-0 fw-bold">더보기</p>' +
                '</div>';
            
            container.appendChild(loadMoreCard);
        }

        initSlider('nearby-stores-slider');
    }

    /**
    * 드래그 슬라이더 로직을 초기화하는 함수 (클릭/드래그 구분 기능 개선)
    * @param {string} containerId - 슬라이더 컨테이너의 ID
    */
    function initSlider(containerId) {
        const sliderContainer = document.getElementById(containerId);
        if (!sliderContainer) return;

        let isDown = false;
        let startX;
        let scrollLeft;
        let velocity = 0;
        let animationFrame = null;
        
        let isDragging = false;
        const dragThreshold = 10; // 10px 이상 움직여야 드래그로 인식

        sliderContainer.addEventListener('dragstart', (e) => e.preventDefault());

        const endDrag = () => {
            if (!isDown) return;
            isDown = false;
            sliderContainer.classList.remove('active');
            if (velocity !== 0) {
                animationFrame = requestAnimationFrame(momentumScroll);
            }
        };

        const preventClick = (e) => {
            e.preventDefault();
            e.stopPropagation();
        };

        sliderContainer.addEventListener('mousedown', (e) => {
            isDown = true;
            isDragging = false;
            sliderContainer.classList.add('active');
            startX = e.pageX - sliderContainer.offsetLeft;
            scrollLeft = sliderContainer.scrollLeft;
            cancelAnimationFrame(animationFrame);
            velocity = 0;
        });

        sliderContainer.addEventListener('mousemove', (e) => {
            if (!isDown) return;
            
            const x = e.pageX - sliderContainer.offsetLeft;
            const walk = x - startX;

            if (Math.abs(walk) > dragThreshold) isDragging = true;
            if (!isDragging) return;

            e.preventDefault();
            
            const newScrollLeft = scrollLeft - walk;
            velocity = newScrollLeft - sliderContainer.scrollLeft;
            sliderContainer.scrollLeft = newScrollLeft;
        });
        
        sliderContainer.addEventListener('mouseup', (e) => {
            const wasDragging = isDragging;
            endDrag();
            if (wasDragging) {
                const targetLink = e.target.closest('a.card');
                if (targetLink) {
                    targetLink.addEventListener('click', preventClick, { once: true });
                }
            }
        });

        sliderContainer.addEventListener('mouseleave', endDrag);

        function momentumScroll() {
            if (Math.abs(velocity) < 0.5) {
                cancelAnimationFrame(animationFrame);
                return;
            }
            sliderContainer.scrollLeft += velocity;
            velocity *= 0.95;
            animationFrame = requestAnimationFrame(momentumScroll);
        }
    }


    $(document).ready(function () {
        // [수정] Enter 키 이벤트 핸들러 복원
        $('#keyword').on('keydown', function(e) {
            if (e.key === 'Enter') {
                goSearch();
            }
        });
        
        $.ajax({
            url: '/review/getBestReview',
            type: 'GET',
            success: function (data) {
                const reviewList = data.reviewList;
                const reviewImageList = data.reviewImageList;
                let html = '';
                const limitedReviewList = reviewList.slice(0, 10);

                function formatDate(dateString) {
                    if (dateString && dateString.includes('T')) return dateString.split('T')[0];
                    return dateString;
                }

                function createStarRating(rating) {
                    let starsHtml = '';
                    for (let i = 0; i < 5; i++) starsHtml += (i < rating) ? '★' : '☆';
                    return starsHtml;
                }

                function maskWriterId(writerId) {
                    if (!writerId) return '';
                    return writerId.slice(0, 2) + '*'.repeat(Math.max(0, writerId.length - 2));
                }

                for (let i = 0; i < limitedReviewList.length; i++) {
                    const review = limitedReviewList[i];
                    const image = reviewImageList.find(img => img.reviewId === review.reviewId);
                    const starRating = createStarRating(review.rating);
                    const maskedWriterId = maskWriterId(review.writerId);

                    html +=
                        '<a href="' + contextPath + '/store/storeDetail?storeId=' + review.storeId + '" class="card review-card">' +
                        (image && image.fileName
                            ? '<img src="' + contextPath + '/images/review/' + image.fileName + '" class="card-img-top" alt="' + review.reviewId + '">'
                            : '') +
                        '<div class="card-body p-3">' +
                            '<div>' +
                                '<p class="rating-text mb-1">' + starRating + '<small class="text-muted ms-2">' + maskedWriterId + '</small></p>' +
                                '<p class="review-content">' + review.content + '</p>' +
                            '</div>' +
                            '<p class="store-info mt-2 mb-0">' + review.storeName + ' | ' + review.roadAddress + '</p>' +
                        '</div>' +
                        '</a>';
                }

                $('#reviewContainer').html(html);
                initSlider('review-slider');
            },
            error: function (err) {
                console.error("데이터 가져오기 실패:", err);
                $('#reviewContainer').html('<p>리뷰를 불러오는 데 실패했습니다.</p>');
            }
        });

        // [55차 수정] 위시리스트 초기화 로직을 다시 추가합니다.
        if (memberId && memberId.trim() !== '' && memberId !== 'null' && memberId !== 'undefined') {
            $('.wishlist-btn').each(function() {
                const storeId = $(this).data('store-id');
                if(storeId) checkWishlistStatus(storeId, this);
            });
        }
    });

function checkWishlistStatus(storeId, btnElement) {
    if (!memberId || memberId === 'null' || memberId === 'undefined') return;
    $.ajax({
        url: `${contextPath}/wishlist/isWishlisted`,
        type: 'GET',
        data: { memberId, storeId },
        success: (response) => $(btnElement).toggleClass('active', response === true),
        error: (error) => console.error('Error checking wishlist status:', error)
    });
}

// 위시리스트 버튼 클릭 처리
$(document).on('click', '.wishlist-btn', function (e) {
    // [수정] 이벤트 전파를 막아 카드 전체의 링크 이동을 방지합니다.
    e.preventDefault(); 
    e.stopPropagation(); 
    const storeId = $(this).data('store-id');
    toggleWishlist(storeId, this);
});

// [수정] 위시리스트 토글 함수에 확인창(confirm) 로직 추가
function toggleWishlist(storeId, btnElement) {
    if (!memberId || memberId == null || memberId.trim() === '') {
        alert('로그인 후 이용해주세요.');
        return;
    }

    const isWishlisted = $(btnElement).hasClass('active');
    const url = isWishlisted ? `${contextPath}/wishlist/remove` : `${contextPath}/wishlist/add`;
    const type = isWishlisted ? 'DELETE' : 'POST';
    const confirmMsg = isWishlisted ? "위시리스트에서 삭제하시겠습니까?" : "위시리스트에 추가하시겠습니까?";
    const successMsg = isWishlisted ? "위시리스트에서 삭제되었습니다." : "위시리스트에 추가되었습니다.";

    if (confirm(confirmMsg)) {
        $.ajax({
            url: url,
            type: type,
            data: { memberId, storeId },
            success: function(response) {
                alert(successMsg);
                $(btnElement).toggleClass('active');
            },
            error: function(xhr) {
                alert(xhr.responseText || "오류가 발생했습니다.");
            }
        });
    }
}
</script>

<main class="container py-5 yum-main-page">
    <div class="row g-5">
        <!-- ======================================= -->
        <!-- 메인 콘텐츠 (왼쪽) -->
        <!-- ======================================= -->
        <div class="col-lg-8">
            <!-- 검색창 -->
            <section class="search-bar mb-5">
                <div class="input-group">
                    <input type="text" class="form-control" id="keyword" placeholder="지역, 가게, 메뉴로 특별한 순간을 찾아보세요">
                    <!-- 'goSearch()'가 없으므로 onclick 이벤트 제거 -->
                    <button class="btn" type="button"><i class="bi bi-search"></i></button>
                </div>
            </section>

            <!-- 카테고리 아이콘 -->
            <section class="category-icons mb-5">
                <ul class="nav justify-content-around">
                    <!-- [수정] &keyword= 제거 -->
                    <li class="nav-item"><a href="${contextPath}/store/storeList?option=region" class="nav-link"><div class="icon-circle"><i class="bi bi-geo-alt-fill"></i></div><span>지역별</span></a></li>
                    <li class="nav-item"><a href="${contextPath}/store/storeList?option=type" class="nav-link"><div class="icon-circle"><i class="bi bi-egg-fried"></i></div><span>음식별</span></a></li>
                    <li class="nav-item"><a href="${contextPath}/store/userLikeStores" class="nav-link"><div class="icon-circle"><i class="bi bi-star-fill"></i></div><span>인기 맛집</span></a></li>
                    <li class="nav-item"><a href="${contextPath}/store/findNewStores" class="nav-link"><div class="icon-circle"><i class="bi bi-shop-window"></i></div><span>신규 오픈</span></a></li>
                </ul>
            </section>

            <!-- 메인 배너 -->
            <section class="main-banner mb-5">
                <div id="mainBannerCarousel" class="carousel slide banner-carousel" data-bs-ride="carousel">
                    <div class="carousel-inner">
                        <c:choose>
                            <c:when test="${not empty bannerList}">
                                <c:forEach var="banner" items="${bannerList}" varStatus="status">
                                    <div class="carousel-item <c:if test='${status.first}'>active</c:if>">
                                        <c:choose>
                                            <c:when test="${not empty banner.promotionId}"><a href="${contextPath}/promotion/detail?id=${banner.promotionId}"></c:when>
                                            <c:when test="${not empty banner.linkUrl}"><a href="${banner.linkUrl}" target="_blank"></c:when>
                                            <c:otherwise><a></c:otherwise>
                                        </c:choose>
                                            <c:choose>
                                                <c:when test="${not empty banner.mobileImagePath}">
                                                    <img src="${contextPath}/banner-images/${banner.imagePath}"
                                                         class="d-block w-100 d-none d-md-block"
                                                         alt="${banner.text}">
                                                    <img src="${contextPath}/banner-images/${banner.mobileImagePath}"
                                                         class="d-block w-100 d-md-none"
                                                         alt="${banner.text}">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="${contextPath}/banner-images/${banner.imagePath}"
                                                         class="d-block w-100"
                                                         alt="${banner.text}">
                                                </c:otherwise>
                                            </c:choose>
                                        </a>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="carousel-item active">
                                    <img src="https://placehold.co/1200x400/FDF6EC/7B2D26?text=Yum+Table"
                                         class="d-block w-100"
                                         alt="기본 배너">
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <c:if test="${fn:length(bannerList) > 1}">
                        <button class="carousel-control-prev" type="button" data-bs-target="#mainBannerCarousel" data-bs-slide="prev">
                            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">이전</span>
                        </button>
                        <button class="carousel-control-next" type="button" data-bs-target="#mainBannerCarousel" data-bs-slide="next">
                            <span class="carousel-control-next-icon" aria-hidden="true"></span>
                            <span class="visually-hidden">다음</span>
                        </button>

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

            <!-- 최신 인기 리뷰 섹션 -->
            <section class="mb-5">
                <h4 class="mb-3 fw-bold">최신 인기 리뷰</h4>
                <div id="review-slider" class="slider-container">
                    <div id="reviewContainer" class="slider-track">
                        <%-- AJAX를 통해 이 곳에 리뷰 카드가 채워집니다. --%>
                        <p class="text-muted">인기 리뷰를 불러오는 중입니다...</p>
                    </div>
                </div>
            </section>

            <!-- 내 지역 맛집 섹션 -->
            <section>
                <h4 class="mb-3 fw-bold">내 지역 맛집</h4>
                <p><span id="address">사용자의 위치 정보를 불러오는 중...</span></p>
                <div id="map" style="height: 300px; border-radius: 1rem;" class="mb-3"></div>
                <!-- [수정] HTML 구조 변경 -->
                <div id="nearby-stores-slider" class="slider-container">
                    <div id="nearbyStores" class="slider-track">
                        <%-- AJAX를 통해 이 곳에 가게 카드가 채워집니다. --%>
                    </div>
                </div>
            </section>
        </div>

        <!-- ======================================= -->
        <!-- 사이드바 (오른쪽) -->
        <!-- ======================================= -->
        <div class="col-lg-4 d-none d-lg-block">
            <div class="sidebar-box mb-4">
                <%-- [33차 수정] isAnonymous와 isAuthenticated를 별개의 블록으로 분리 --%>

                <%-- 로그아웃 상태일 때 --%>
                <sec:authorize access="isAnonymous()">
                    <h5 class="sidebar-title">로그인</h5>
                    <p class="small text-muted">로그인하고 얌테이블의 모든 서비스를 이용해보세요.</p>
                    <div class="d-grid gap-2">
                        <a href="${contextPath}/member/login" class="btn" style="background-color: var(--yum-dark-red); color: white;">로그인 / 회원가입</a>
                    </div>
                </sec:authorize>

                <%-- 로그인 상태일 때 (GUEST 제외) --%>
                <c:if test="${not empty memberInfo}">
                    <div class="d-flex align-items-center mb-3">
                        <c:choose>
                            <c:when test="${not empty memberInfo.profileImageUrl}">
                                <img src="${contextPath}${memberInfo.profileImageUrl}" class="rounded-circle profile-pic-md">
                            </c:when>
                            <c:otherwise>
                                <img src="${contextPath}/images/default_profile.png" class="rounded-circle profile-pic-md">
                            </c:otherwise>
                        </c:choose>
                        <div class="ms-3">
                            <h5 class="mb-0 fw-bold">${memberInfo.memberName} 님</h5>
                            <p class="mb-0 text-muted small">매너온도: ${memberInfo.mannerTemperature}°C</p>
                        </div>
                    </div>
                </c:if>

                <%-- GUEST 상태일 때 --%>
                <sec:authorize access="hasRole('GUEST')">
                     <h5 class="sidebar-title">회원가입</h5>
                     <p class="small text-muted">추가 정보를 입력하고 모든 서비스를 이용해보세요.</p>
                     <div class="d-grid">
                         <a href="${contextPath}/member/join_social" class="btn" style="background-color: var(--yum-beige);">추가 정보 입력</a>
                     </div>
                </sec:authorize>
            </div>

            <div class="sidebar-box">
                <h5 class="sidebar-title">최근 방문 기록</h5>
                <p class="small text-muted">최근 방문한 가게 목록이 여기에 표시됩니다.</p>
            </div>
        </div>
    </div>
</main>

