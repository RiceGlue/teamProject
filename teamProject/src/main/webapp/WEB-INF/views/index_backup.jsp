<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">


<!-- Google Maps JavaScript API 로드 -->
<script async defer
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB1kAhEMiW_-y5zg2uFTUeAOTG_uVO_kts&callback=initMap&libraries=places">
</script>

<!-- jQuery (AJAX 용) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    .carousel-item img { height: 500px; object-fit: cover; }
    .carousel-caption { background-color: rgba(0, 0, 0, 0.5); border-radius: 5px; padding: 10px; }
    .store-carousel { display: flex; overflow-x: auto; gap: 16px; padding-bottom: 10px; scroll-snap-type: x mandatory; }
	.store-carousel .card { min-width: 250px; flex: 0 0 auto; scroll-snap-align: start; }
	.store-carousel.limited { max-width: calc(250px * 3 + 32px); overflow-x: hidden; }
	.wishlist-btn{background:none;border:none;cursor:pointer;font-size:24px;color:#ccc;transition:color 0.3s ease;}
	.wishlist-btn.active{color:#ff6347;}  
</style>

<script>
const memberId = "${memberId}";
var contextPath = '${contextPath}';

	function goSearch() {
		const keyword = document.getElementById('keyword').value;
		if (!keyword.trim()) {
			alert("검색어를 입력해주세요.");
			return;
		}
		window.location.href = contextPath + "/store/storeList?option=search&keyword=" + encodeURIComponent(keyword);
	}

    function initMap() {
        // 1. 사용자 위치 가져오기
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(success, error);
        } else {
            document.getElementById("address").innerText = "위치 정보를 지원하지 않는 브라우저입니다.";
        }
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
                
                // initMap은 API 로드 시에만 호출되므로, 여기서는 지도 객체만 생성합니다.
                const map = new google.maps.Map(document.getElementById("map"), {
                    zoom: 14,
                    center: { lat: 37.5665, lng: 126.9780 },
                });

                displayStoresOnMap(storeList, map);
                displayStoreCards(storeList, dong);
            },
            error: function (xhr, status, error) {
                console.error("AJAX 요청 실패:", status, error);
                document.getElementById("nearbyStores").innerHTML = "<p>매장 정보를 불러오는 데 실패했습니다.</p>";
            }
        });
    }

    // 6. 매장 주소 → 위도/경도 → 지도 마커 표시
    function displayStoresOnMap(storeList, map) {
        const geocoder = new google.maps.Geocoder();

        storeList.forEach(store => {
            geocoder.geocode({ address: store.roadAddress }, function (results, status) {
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

$(document).ready(function () {
	// [복원] 페이지 로드 시 로그인한 사용자의 위시리스트 상태를 모든 버튼에 반영합니다.
    if (memberId && memberId.trim() !== '' && memberId !== 'null' && memberId !== 'undefined') {
        $('.wishlist-btn').each(function() {
            const storeId = $(this).data('store-id');
            if(storeId) { // data-store-id가 있는 버튼만 실행
               checkWishlistStatus(storeId, this);
            }
        });
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
								<img src="${contextPath}/banner-images/${banner.getImagePath()}"
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
    <div id="reviewContainer" style="display: flex; overflow-x: auto; gap: 15px; padding: 10px;"></div>
</div>

<div class="container my-4">
    <div class="col-12">
        <h2>내 지역 맛집</h2>
        <p><span id="address">사용자의 위치 정보를 불러오는 중...</span></p>
        
        <div id="map" style="height: 300px;"></div>
        
        <div id="nearbyStores" class="store-carousel"></div> 
        
        <button id="loadMoreBtn" class="btn btn-primary mt-2" style="display:none;">더보기</button>
    </div>
</div>

<!-- [복원] 개발 테스트용 HTML 주석 -->
<!-- <div class="review-item" style="height: 250px; width:200px; border:1px solid #ddd; padding:10px; margin-bottom:10px;"> -->
<!-- 	<div class="writer" style="display: flex; justify-content: space-between;"> -->
<!--     <p>작성자</p> -->
<!--     <p>작성 날짜</p> -->
<!-- </div> -->
<!-- 	<div calss="review-image"> -->
<!-- 		<image src="https://cdn.pixabay.com/photo/2015/10/09/01/01/steak-978666_1280.jpg" style="width:100%;" > -->
<!-- 		<p>★★★★★ -->
<!-- 		<p>리뷰 내용 -->
<!-- 	</div> -->
	
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




<!-- <div class="container my-4"> -->
<!--     <h2>매장 관리자 (점주) TEST 링크</h2> -->
<!--     <div class="row g-3"> -->
<!--         <div class="col"> -->
<!--             <div class="card text-center"> -->
<!--                 <div class="card-body"> -->
<%--                     <h5 class="card-title"><a href="${contextPath}/waiting/owner/settings?storeId=1">사용자(점주) 웨이팅 설정 관리</h5> --%>
<!--                 </div> -->
<!--             </div> -->
<!--         </div> -->
<!--          <div class="col"> -->
<!--             <div class="card text-center"> -->
<!--                 <div class="card-body"> -->
<!--                     <h5 class="card-title"><a href="/reservation/owner/manageList?storeId=1">사용자(점주) 예약 관리</a></h5> -->
<!--                 </div> -->
<!--             </div> -->
<!--         </div> -->
<!--     </div> -->
<!-- </div> -->

