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
    }
    .card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(0,0,0,0.1);
    }
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

    .wishlist-btn{background:none;border:none;cursor:pointer;font-size:24px;color:#ccc;transition:color 0.3s ease;}
    .wishlist-btn.active{color:#ff6347;}  
</style>

<script>
const memberId = "${memberId}";
var contextPath = '${contextPath}';
var map; // 지도 객체를 전역 변수로 선언

	function goSearch() {
		const keyword = document.getElementById('keyword').value;
		if (!keyword.trim()) {
			alert("검색어를 입력해주세요.");
			return;
		}
		window.location.href = contextPath + "/store/storeList?option=search&keyword=" + encodeURIComponent(keyword);
	}

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
                
                // [수정] 새로운 지도 객체를 생성하는 대신, 전역 map 객체를 사용합니다.
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
	
	    const limitedStoreList = storeList.slice(0, 3);
	
	    limitedStoreList.forEach(store => {
	        const card = document.createElement("div");
	        card.className = "card my-3";
	
	        card.innerHTML = 
	            '<div class="card-body">' +
	                '<h5 class="card-title">' +
	                    '<a href="' + contextPath + '/store/storeDetail?storeId=' + store.storeId + '">' + store.storeName + '</a>' +
	                    '<button class="wishlist-btn" data-store-id="' + store.storeId + '" aria-label="위시리스트 추가/제거">' +
	                        '<i class="fa fa-bookmark"></i>' +
	                    '</button>' +
	                '</h5>' +	
	                '<p class="card-text">&#128205; ' + store.roadAddress + '</p>' +
	                '<p class="card-text">&#128222; ' + store.localNumber + '-' + store.number1 + '-' + store.number2 + '</p>' +
	                '<p class="card-text">&#11088; ' + store.avgRating + ' / 5</p>' +
	            '</div>';
	
	        container.appendChild(card);
	
	        if (memberId && memberId !== 'null' && memberId !== 'undefined') {
	            const wishlistBtn = card.querySelector('.wishlist-btn');
	            if (wishlistBtn) {
	                checkWishlistStatus(store.storeId, wishlistBtn);
	            }
	        }
	    });
	
	    const buttonWrapper = document.createElement("div");
	    buttonWrapper.className = "d-grid mt-2";
	
	    const loadMoreBtn = document.createElement("button");
	    loadMoreBtn.id = "loadMoreBtn";
	    loadMoreBtn.className = "btn btn-light";
	    loadMoreBtn.textContent = "더보기";
	    loadMoreBtn.onclick = function () {
	        window.location.href = contextPath + "/store/storeList?option=userLocation&keyword=" + encodeURIComponent(dong);
	    };
	
	    buttonWrapper.appendChild(loadMoreBtn);
	    container.appendChild(buttonWrapper);
	}

	$(document).ready(function () {
	    $.ajax({
	        url: '/review/getBestReview',
	        type: 'GET',
	        success: function (data) {
	            const reviewList = data.reviewList;
	            const reviewImageList = data.reviewImageList;

	            let html = '';

	            const limitedReviewList = reviewList.slice(0, 10);

	            function formatDate(dateString) {
	                if (dateString && dateString.includes('T')) {
	                    return dateString.split('T')[0];
	                }
	                return dateString;
	            }

	            function createStarRating(rating) {
	                const maxRating = 5;
	                let starsHtml = '';
	                for (let i = 0; i < rating; i++) {
	                    starsHtml += '★';
	                }
	                for (let i = 0; i < (maxRating - rating); i++) {
	                    starsHtml += '☆';
	                }
	                return starsHtml;
	            }

	            function maskWriterId(writerId) {
	                if (!writerId) return '';
	                const visible = writerId.slice(0, 2);
	                const maskedLength = writerId.length - 2;
	                const masked = '*'.repeat(maskedLength > 0 ? maskedLength : 0);
	                return visible + masked;
	            }

	            for (let i = 0; i < limitedReviewList.length; i++) {
	                const review = limitedReviewList[i];
	                const image = reviewImageList.find(img => img.reviewId === review.reviewId);

	                const formattedDate = formatDate(review.createdAt);
	                const starRating = createStarRating(review.rating);
	                const maskedWriterId = maskWriterId(review.writerId);

	                html +=
	                    '<div class="review-item" style="flex: 0 0 calc(33.333% - 10px); border:1px solid #ddd; padding:10px; margin-bottom:10px; position: relative; overflow: hidden;">' +
	                        '<div class="writer" style="display: flex; justify-content: space-between; margin:10px 0;">' +
	                            '<h6>' + maskedWriterId + '</h6>' +
	                            '<h6>' + formattedDate + '</h6>' +
	                        '</div>' +

	                        '<div class="review-image" style="position: relative; height: 170px;">' +
	                            (image && image.fileName
	                                ? '<img src="' + contextPath + '/images/review/' + image.fileName + '" style="width:100%; height:100%; object-fit: cover;" alt="리뷰 이미지">'
	                                : '') +
	                            '<div class="review-content" style="position: absolute; bottom: 0; left: 0; right: 0; padding: 10px; color: black; background-color: rgb(193 193 193 / 50%);">' +
	                                '<p>' + starRating + ' / 좋아요: ' + review.likes + '</p>' +
	                                '<p>' + review.content + '</p>' +
	                            '</div>' +
	                        '</div>' +

	                        '<div class="review-store" style="margin-bottom: 10px; padding-top:5px;">' +
	                            '<h6>' + review.storeName + ' | ' + review.storeType + '</h6>' +
	                            '<h6>&#128222; ' + review.localNumber + ' - ' + review.number1 + ' - ' + review.number2 + '</h6>' +
	                            '<h6>&#128205; ' + review.roadAddress + '</h6>' +
	                        '</div>' +
	                    '</div>';
	            }

	            $('#reviewContainer').html(html);
	        },
	        error: function (err) {
	            console.error("데이터 가져오기 실패:", err);
	            $('#reviewContainer').html('<p>리뷰를 불러오는 데 실패했습니다.</p>');
	        }
	    });
	});

function checkWishlistStatus(storeId, btnElement) {
	if (!memberId || memberId === 'null' || memberId === 'undefined') return;

	$.ajax({
		url: `${contextPath}/wishlist/isWishlisted`,
		type: 'GET',
		data: {
			memberId: memberId,
			storeId: storeId
		},
		success: function(response) {
			if (response === true) {
				$(btnElement).addClass('active');
			} else {
				$(btnElement).removeClass('active');
			}
		},
		error: function(error) {
			console.error('Error checking wishlist status:', error);
		}
	});
}

// 위시리스트 버튼 클릭 처리
$(document).on('click', '.wishlist-btn', function () {
    const storeId = $(this).data('store-id');
    toggleWishlist(storeId, this);
});

function toggleWishlist(storeId, btnElement) {
    if (!memberId || memberId == null || memberId.trim() === '') {
        alert('로그인 후 이용해주세요.');
        return;
    }

    const isWishlisted = $(btnElement).hasClass('active');

    if (isWishlisted) {
        if (confirm("위시리스트에 이미 추가되었습니다. 삭제하시겠습니까?")) {
            $.ajax({
                url: `${contextPath}/wishlist/remove`,
                type: 'DELETE',
                data: { memberId, storeId },
                success: function(response) {
                    alert(response);
                    $(btnElement).removeClass('active');
                },
                error: function(xhr) {
                    alert(xhr.responseText || "오류가 발생했습니다.");
                }
            });
        }
    } else {
        $.ajax({
            url: `${contextPath}/wishlist/add`,
            type: 'POST',
            data: { memberId, storeId },
            success: function(response) {
                alert(response);
                $(btnElement).addClass('active');
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
                    <button class="btn" type="button" onclick="goSearch()"><i class="bi bi-search"></i></button>
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
                <div id="mainBannerCarousel" class="carousel slide banner-carousel" data-bs-ride="carousel">
                    <div class="carousel-inner">
                        <c:choose>
                            <c:when test="${not empty bannerList}">
                                <c:forEach var="banner" items="${bannerList}" varStatus="status">
                                    <div class="carousel-item <c:if test='${status.first}'>active</c:if>">
                                        <c:choose>
                                            <c:when test="${not empty banner.promotionId}">
                                                <a href="${contextPath}/promotion/detail?id=${banner.promotionId}">
                                            </c:when>
                                            <c:when test="${not empty banner.linkUrl}">
                                                <a href="${banner.linkUrl}" target="_blank">
                                            </c:when>
                                            <c:otherwise>
                                                <a>
                                            </c:otherwise>
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
                <div id="reviewContainer" class="store-carousel">
                    <%-- AJAX를 통해 이 곳에 리뷰 카드가 채워집니다. --%>
                    <p class="text-muted">인기 리뷰를 불러오는 중입니다...</p>
                </div>
            </section>

            <!-- 내 지역 맛집 섹션 -->
			<section>
			    <h4 class="mb-3 fw-bold">내 지역 맛집</h4>
			    <p><span id="address">사용자의 위치 정보를 불러오는 중...</span></p>
			    <div id="map" style="height: 300px; border-radius: 1rem;" class="mb-3"></div>
			    <div id="nearbyStores" class="store-carousel">
			        <%-- AJAX를 통해 이 곳에 가게 카드가 채워집니다. --%>
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

                <%-- 로그인 상태일 때 --%>
                <sec:authorize access="isAuthenticated()">
                    <sec:authentication property="principal" var="principal" />
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
                </sec:authorize>
            </div>

            <div class="sidebar-box">
                <h5 class="sidebar-title">최근 방문 기록</h5>
                <p class="small text-muted">최근 방문한 가게 목록이 여기에 표시됩니다.</p>
            </div>
        </div>
    </div>
</main>

<!-- [복원] 개발 테스트용 HTML 주석 -->
<!-- <div class="review-item" style="height: 250px; width:200px; border:1px solid #ddd; padding:10px; margin-bottom:10px;"> -->
<!--     <div class="writer" style="display: flex; justify-content: space-between;"> -->
<!--      <p>작성자</p> -->
<!--      <p>작성 날짜</p> -->
<!-- </div> -->
<!--     <div calss="review-image"> -->
<!--         <image src="https://cdn.pixabay.com/photo/2015/10/09/01/01/steak-978666_1280.jpg" style="width:100%;" > -->
<!--         <p>★★★★★ -->
<!--         <p>리뷰 내용 -->
<!--     </div> --> 
<!-- </div> -->

<!-- <div class="review-item" style="padding: 0px; flex: 0 0 calc(33.333% - 10px); height: 300px; border:1px solid #ddd; margin-bottom:10px; position: relative; overflow: hidden;"> -->
<!--     <div class="writer" style="display: flex; justify-content: space-between; margin:10px;"> -->
<!--         <h6>작성자ID</h6> -->
<!--         <h6>2025-08-27</h6> -->
<!--     </div> -->
    
<!--     <div class="review-image" style="position: relative; height: 170px;"> -->
<!--         <img src="https://cdn.pixabay.com/photo/2015/10/09/01/01/steak-978666_1280.jpg" style="width:100%; height:100%; object-fit: cover;" alt="리뷰 이미지"> -->
<!--         <div class="review-content" style="position: absolute; bottom: 0; left: 0; right: 0; padding: 10px; color: white; background-color: rgba(0, 0, 0, 0.5);"> -->
<!--             <p>★★★★☆ / 좋아요: 15</p> -->
<!--             <p>리뷰 내용 예시입니다.</p> -->
<!--         </div> -->
<!--     </div> -->
<!--     <div class="review-store" style="padding: 10px; z-index: 10;"> -->
<!--         <h6>예시가게 | 음식점</h6> -->
<!--         <h6>??042-000-0000</h6> -->
<!--         <h6>??대전시 대덕구 어쩌구저쩌구</h6> -->
<!--     </div> -->
<!-- </div> -->

