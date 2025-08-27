<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- Google Maps JavaScript API 로드 (API 키 필요) -->
<script async defer
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB1kAhEMiW_-y5zg2uFTUeAOTG_uVO_kts&libraries=places">
</script>

<!-- jQuery (AJAX 용) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    .carousel-item img { height: 500px; object-fit: cover; }
    .carousel-caption { background-color: rgba(0, 0, 0, 0.5); border-radius: 5px; padding: 10px; }
    .store-carousel { display: flex; overflow-x: auto; gap: 16px; scroll-snap-type: x mandatory; padding-bottom: 10px; }
	.store-carousel .card { min-width: 250px; flex: 0 0 auto; scroll-snap-align: start; }
	.store-carousel.limited { max-width: calc(250px * 3 + 32px); overflow-x: hidden; }
</style>

<script>
document.addEventListener("DOMContentLoaded", function () {
    // 1. 사용자 위치 가져오기
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(success, error);
    } else {
        document.getElementById("address").innerText = "위치 정보를 지원하지 않는 브라우저입니다.";
    }

    function success(position) {
        const lat = position.coords.latitude;
        const lng = position.coords.longitude;

        getAddressFromCoords(lat, lng);
    }

    function error() {
        document.getElementById("address").innerText = "위치 정보를 불러올 수 없습니다.";
    }

    // 2. 위도/경도로 주소 얻기
    function getAddressFromCoords(lat, lng) {
        const geocoder = new google.maps.Geocoder();
        const latlng = { lat: parseFloat(lat), lng: parseFloat(lng) };

        geocoder.geocode({ location: latlng }, function (results, status) {
            if (status === "OK") {
                if (results[0]) {
                    const fullAddress = results[0].formatted_address;
                    document.getElementById("address").innerText = fullAddress;

                    const dong = extractDongAddress(results[0].address_components);
                    if (dong) {
                        fetchNearbyStores(dong);
                    }
                }
            } else {
                document.getElementById("address").innerText = "주소를 가져올 수 없습니다.";
            }
        });
    }

    // 3. 주소 컴포넌트에서 동 주소 추출
    function extractDongAddress(components) {
        for (let i = 0; i < components.length; i++) {
            const types = components[i].types;
            if (types.includes("sublocality_level_1") || types.includes("locality") || types.includes("administrative_area_level_3")) {
                return components[i].long_name;
            }
        }
        return null;
    }

    // 4. AJAX로 동 주소 전달 → 매장 리스트 받아오기
    function fetchNearbyStores(dong) {
        $.ajax({
            url: "${contextPath}/store/searchStoreNearUser", // 컨트롤러 주소에 맞게 수정
            method: "GET",
            data: { location: dong },
            success: function (storeList) {
                if (storeList.length === 0) {
                    document.getElementById("nearbyStores").innerHTML = "<p>근처에 매장이 없습니다.</p>";
                    return;
                }

                initMap();
                displayStoresOnMap(storeList);
                displayStoreCards(storeList);
            },
            error: function () {
                document.getElementById("nearbyStores").innerHTML = "<p>매장 정보를 불러오는 데 실패했습니다.</p>";
            }
        });
    }

    // 5. 지도 초기화
    let map;
    function initMap() {
        map = new google.maps.Map(document.getElementById("map"), {
            zoom: 14,
            center: { lat: 37.5665, lng: 126.9780 }, // 서울 기본 위치
        });
    }

    // 6. 매장 주소 → 위도/경도 → 지도 마커 표시
    function displayStoresOnMap(storeList) {
        const geocoder = new google.maps.Geocoder();

        storeList.forEach(store => {
            geocoder.geocode({ address: store.address }, function (results, status) {
                if (status === "OK" && results[0]) {
                    const location = results[0].geometry.location;

                    new google.maps.Marker({
                        position: location,
                        map: map,
                        title: store.storeName
                    });

                    // 첫 마커 기준으로 지도 센터 변경
                    if (store === storeList[0]) {
                        map.setCenter(location);
                    }
                }
            });
        });
    }

    // 7. 매장 카드 UI로 표시
    function displayStoreCards(storeList) {
        const container = document.getElementById("nearbyStores");
        const loadMoreBtn = document.getElementById("loadMoreBtn");

        container.innerHTML = ""; // 초기화
        container.classList.add('limited'); // 처음엔 제한 모드

        storeList.forEach(store => {
            const card = document.createElement("div");
            card.className = "card my-3";
            card.innerHTML = `
                <div class="card-body">
                    <h5 class="card-title">${storeList.storeName}</h5>
                    <p class="card-text">📍 ${storeList.address}</p>
                    <p class="card-text">📞 ${storeList.localNumber}-${storeList.number1}-${storeList.number2}</p>
                    <p class="card-text">⭐ ${storeList.avgRating} / 5</p>
                </div>
            `;
            container.appendChild(card);
        });

        // 더보기 버튼 이벤트
        loadMoreBtn.onclick = function () {
            container.classList.remove('limited'); // 제한 해제
            container.style.overflowX = 'auto'; // 슬라이드 허용
            loadMoreBtn.style.display = 'none'; // 버튼 숨기기
        };
    }
});
</script>

<div class="row">
	<div class="container my-4">
	    <div class="col-12">
	        <div id="bannerCarousel" class="carousel slide" data-bs-ride="carousel">
	            <div class="carousel-inner">
	                <c:forEach var="banner" items="${bannerList}" varStatus="status">
	                    <div class="carousel-item <c:if test="${status.first}">active</c:if>">
	                        <a href="${contextPath}/promotion/detail?id=${banner.promotionId}">
	                            <img src="${contextPath}/images/banners/${banner.getImagePath()}"
	                                 class="d-block w-100 img-fluid" alt="${banner.text}">
								<div class="carousel-caption d-none d-md-block">
                                    <h5 class="text-white">${banner.text}</h5>
                                </div>
	                        </a>
	                    </div>
	                </c:forEach>
	            </div>

	            <button class="carousel-control-prev" type="button" data-bs-target="#bannerCarousel" data-bs-slide="prev">
	                <span class="carousel-control-prev-icon" aria-hidden="true"></span>
	                <span class="visually-hidden">Previous</span>
	            </button>
	            <button class="carousel-control-next" type="button" data-bs-target="#bannerCarousel" data-bs-slide="next">
	                <span class="carousel-control-next-icon" aria-hidden="true"></span>
	                <span class="visually-hidden">Next</span>
	            </button>

	            <div class="carousel-indicators">
	                <c:forEach varStatus="status" items="${bannerList}">
	                    <button type="button" data-bs-target="#bannerCarousel" data-bs-slide-to="${status.index}"
	                            class="<c:if test="${status.first}">active</c:if>" aria-current="true"
	                            aria-label="Slide ${status.index + 1}"></button>
	                </c:forEach>
	            </div>
	        </div>
	    </div>
	</div>

	<div class="container my-4">
		<div class="col-12">
			<div class="search-container">
				<input type="text" class="search-input" placeholder="검색어를 입력하세요..." id="keyword">
				<button type="button" class="search-button" onclick="goSearch()">
				   	<img src="https://cdn-icons-png.flaticon.com/512/54/54481.png" alt="검색">
				</button>
			</div>
		</div>
	</div>
	<div class="container my-4">
	    <h2>지역 선택</h2>
	    <div class="row row-cols-2 row-cols-md-4 g-3">
	        <div class="col">
	        	<div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/store/storeList?option=region&keyword=서울">서울</a></h5>

	                </div>
	            </div>
	        	<div class="card text-center">
	        		<h5 class="card-title"><a href="${contextPath}/franchise/addStoreInfoForm?ownerId=10">매장 정보 입력</a></h5>
					<h5 class="card-title"><a href="${contextPath}/franchise/modifyStoreInfoForm?storeId=1">매장 정보 수정</a></h5>
					<h5 class="card-title"><a href="${contextPath}/franchise/addMenuForm?storeId=1&ownerId=1">메뉴 입력</a></h5>
					<h5 class="card-title"><a href="${contextPath}/franchise/modifyMenuForm?storeId=1">메뉴 수정</a></h5>
	        	</div>
	        	<div class="card text-center">
	        		<h5 class="card-title"><a href="${contextPath}/review/reviewForm?memberId=3&storeId=1&reservationId=114">리뷰 작성</a></h5>
	        		<h5 class="card-title"><a href="${contextPath}/review/modifyReviewForm?memberId=3&reviewId=60">리뷰 수정</a></h5>
	        	</div>

	        </div>
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/store/storeList?option=region&keyword=경기">경기</a></h5>
	                </div>
	            </div>
	        </div>
			<div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/store/storeList?option=region&keyword=대전">대전</a></h5>
	                </div>
	            </div>
	        </div>
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/store/storeList?option=region&keyword=부산">부산</a></h5>
	                </div>
	            </div>
	        </div>
	    </div>
	</div>

	<div class="container my-4">
	    <h2>빠른 링크</h2>
	    <div class="row row-cols-1 row-cols-md-3 g-3">
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <a href="#" class="stretched-link">요즘뜨는</a>
	                </div>
	            </div>
	        </div>
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <a href="#" class="stretched-link">음식별</a>
	                </div>
	            </div>
	        </div>
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <a href="#" class="stretched-link">테마별</a>
	                </div>
            </div>
        </div>
    </div>
</div>
<div class="container my-4">
    <div class="col-12">
        <h2>최신인기리뷰</h2>
    </div>
</div>

<div class="row">
    <div class="container my-4">
        <div class="col-12">
            <h2>내 지역 맛집</h2>
            <p><span id="address">사용자의 위치 정보를 불러오는 중...</span></p>

            <!-- 지도를 렌더링할 영역 -->
            <div id="map" style="height: 300px;"></div>

            <div id="storeWrapper" style="position: relative;">
			    <div id="nearbyStores" class="store-carousel"></div>
			    <button id="loadMoreBtn" class="btn btn-primary mt-2">더보기</button>
			</div>
        </div>
    </div>
</div>
   
<div class="container my-4">
    <h2>매장 관리자 (점주) TEST 링크</h2>
    <div class="row g-3">
        <div class="col">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="card-title"><a href="${contextPath}/waiting/owner/settings?storeId=1">사용자(점주) 웨이팅 설정 관리</h5>
                </div>
            </div>
        </div>
         <div class="col">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="card-title"><a href="/reservation/owner/manageList?storeId=1">사용자(점주) 예약 관리</a></h5>
                </div>
            </div>
        </div>
    </div>
</div>

</div>