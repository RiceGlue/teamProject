<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">

<style>
    h2 { margin-bottom: 20px; }
	.store-card { border-bottom:1px solid #ccc; display:flex; padding:12px; margin-bottom:16px; margin: 0 auto 0; font-family:'Segoe UI', sans-serif; align-items:center; }
	.store-image { position:relative; width:120px; height:120px; border-radius:6px; overflow:hidden; flex-shrink:0; }
	.store-image img { width:100%; height:100%; object-fit:cover; }
	.badge-rank { position:absolute; top:6px; left:6px; background:#ff4b4b; color:#fff; font-size:14px; padding:2px 6px; border-radius:4px; font-weight:bold; }
	.badge-wait { position:absolute; bottom:6px; left:6px; background:#00b386; color:#fff; font-size:12px; padding:2px 6px; border-radius:4px; }
	.store-info { margin-left:16px; flex:1; }
	.store-info h4 { margin:0 0 6px; font-size:18px; }
	.store-info p { margin:4px 0; font-size:14px; color:#444; }
	.rating { color:#ffa500; font-weight:bold; }
	.meta-info { font-size:13px; color:#777; }
	.meta-info i { margin-right:4px; }

	#map{ width: 100%; height:300px; margin: 0px auto 20px; position: relative; overflow: hidden; border-radius: 5px;}

	.wishlist-btn{background:none;border:none;cursor:pointer;font-size:24px;color:#ccc;transition:color 0.3s ease;}
	.wishlist-btn.active{color:#ff6347;}

	.region-buttons { display: flex; flex-wrap: wrap; justify-content: center; gap: 10px; max-width: calc((11.11% * 9) + (10px * 8)); margin: 0 auto; height: auto; max-height: none; }
	.region-form { flex: 0 0 calc(11.11% - 10px); max-width: calc(11.11% - 10px); box-sizing: border-box; }
	.region-form .btn { width: 100%; white-space: nowrap; }
	.region-btn.active { background-color: #0d6efd;color: white;border-color: #0d6efd;}

	.storeList {width:60%; margin: 0 auto; margin-top:20px; }
	
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
</style>

<script>
    const regionStores = [
        <c:forEach var="store" items="${regionlist}" varStatus="status">
            {
                storeId: '${store.storeId}',
                storeName: '${store.storeName}',
                roadAddress: '${store.roadAddress}',
                fileName: '${store.fileName}',
                avgRating: '${store.avgRating}',
                countRating: '${store.countRating}',
                storeType: '${store.storeType}',
                description: '${store.description}'
            }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    const userLocationStores = [
        <c:forEach var="store" items="${userLocationlist}" varStatus="status">
            {
                storeId: '${store.storeId}',
                storeName: '${store.storeName}',
                roadAddress: '${store.roadAddress}',
                fileName: '${store.fileName}',
                avgRating: '${store.avgRating}',
                countRating: '${store.countRating}',
                storeType: '${store.storeType}',
                description: '${store.description}'
            }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    const searchStores = [
        <c:forEach var="store" items="${storeList}" varStatus="status">
            {
                storeId: '${store.storeId}',
                storeName: '${store.storeName}',
                roadAddress: '${store.roadAddress}',
                fileName: '${store.fileName}',
                avgRating: '${store.avgRating}',
                countRating: '${store.countRating}',
                storeType: '${store.storeType}',
                description: '${store.description}'
            }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];
    
    const newOpenStores = [
        <c:forEach var="store" items="${storeList}" varStatus="status">
            {
                storeId: '${store.storeId}',
                storeName: '${store.storeName}',
                roadAddress: '${store.roadAddress}',
                fileName: '${store.fileName}',
                avgRating: '${store.avgRating}',
                countRating: '${store.countRating}',
                storeType: '${store.storeType}',
                description: '${store.description}'
            }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];
    
    const likeStores = [
        <c:forEach var="store" items="${storeList}" varStatus="status">
            {
                storeId: '${store.storeId}',
                storeName: '${store.storeName}',
                roadAddress: '${store.roadAddress}',
                fileName: '${store.fileName}',
                avgRating: '${store.avgRating}',
                countRating: '${store.countRating}',
                storeType: '${store.storeType}',
                description: '${store.description}'
            }<c:if test="${!status.last}">,</c:if>
        </c:forEach>
    ];

    const memberId = "${memberId != null ? memberId : ''}";
    const contextPath = '${contextPath}';
    const option = "${option}";

    let maps = {};
    let markers = [];

    function initMap() {
        map = new google.maps.Map(document.getElementById("map"), {
            zoom: 11,
            center: { lat: 37.5665, lng: 126.9780 },
        });

        maps["map"]=map;
    }

    function geocodeAddress(geocoder, address) {
        return new Promise((resolve, reject) => {
            geocoder.geocode({ address: address }, (results, status) => {
                if (status === "OK" && results[0]) {
                    resolve(results[0].geometry.location);
                } else {
                    reject(`Geocode failed for ${address}: ${status}`);
                }
            });
        });
    }

    async function showMarkersOnMap(mapId, storeList) {
        const map = maps[mapId] || window.map;
        if (!map) {
            console.warn(`지도 ${mapId}가 초기화되지 않았습니다.`);
            return;
        }

        markers.forEach(m => m.setMap(null));
        markers = [];

        const geocoder = new google.maps.Geocoder();
        let isFirstMarker = true;

        for (const store of storeList) {
            const address = store.roadAddress || store.address;
            if (!address) continue;

            try {
                const pos = await geocodeAddress(geocoder, address);
                const marker = new google.maps.Marker({
                    map: map,
                    position: pos,
                    title: store.storeName || store.name
                });

                markers.push(marker);

                if (isFirstMarker) {
                    map.setCenter(pos);
                    map.setZoom(14);
                    isFirstMarker = false;
                }
            } catch (error) {
                console.error(error);
            }
        }
    }

    function getAddressFromCoords(lat, lng) {
        const geocoder = new google.maps.Geocoder();
        const latlng = { lat: lat, lng: lng };
        geocoder.geocode({ location: latlng }, function (results, status) {
            if (status === "OK" && results[0]) {
                const fullAddress = results[0].formatted_address;
                const addressElem = document.getElementById("userAddress");
                if (addressElem) {
                    addressElem.innerText = fullAddress;
                }
            } else {
                alert("주소를 가져올 수 없습니다.");
            }
        });
    }

    function checkWishlistStatus(storeId, btnElement) {
        if (!memberId || memberId.trim() === '') return;

        $.ajax({
            url: `${contextPath}/wishlist/isWishlisted`,
            type: 'GET',
            data: { memberId, storeId },
            success: function(response) {
                if (response === true) {
                    $(btnElement).addClass('active');
                } else {
                    $(btnElement).removeClass('active');
                }
            },
            error: function(error) {
                console.error('위시리스트 상태 확인 중 오류:', error);
            }
        });
    }

    function toggleWishlist(storeId, btnElement) {
        if (!memberId || memberId.trim() === '') {
            if (confirm('로그인 후 이용해주세요. 로그인 페이지로 이동하시겠습니까?')) {
                window.location.href = contextPath + '/member/login';
            }
            return;
        }

        const isWishlisted = $(btnElement).hasClass('active');
        const url = isWishlisted ? `${contextPath}/wishlist/remove` : `${contextPath}/wishlist/add`;
        const type = isWishlisted ? 'DELETE' : 'POST';
        const confirmMsg = isWishlisted ? "위시리스트에서 삭제하시겠습니까?" : "위시리스트에 추가하시겠습니까?";
        const successMsg = isWishlisted ? "위시리스트에서 삭제되었습니다." : "위시리스트에 추가되었습니다.";
        const newClass = isWishlisted ? 'removeClass' : 'addClass';

        if (confirm(confirmMsg)) {
            $.ajax({
                url: url,
                type: type,
                data: { memberId, storeId },
                success: function(response) {
                    alert(successMsg);
                    $(btnElement)[newClass]('active');
                },
                error: function(xhr) {
                    alert(xhr.responseText || "오류가 발생했습니다.");
                }
            });
        }
    }

    function renderStoreList(storeList) {
        const container = document.getElementById('store-list-container');
        if (!container) return;

        container.innerHTML = '';

        if (!storeList || storeList.length === 0) {
            container.innerHTML = '<h3>검색 결과 없음</h3>';
            return;
        }

        storeList.forEach(store => {
            const card = document.createElement('div');
            card.className = 'store-card';
            card.innerHTML = "" +
            "<div class=\"store-image\">" +
                "<a href=\"" + contextPath + "/store/storeDetail?storeId=" + store.storeId + "\">" +
                    "<img src=\"" + contextPath + "/images/store/" + (store.fileName || 'default.jpg') + "\" alt=\"" + store.storeName + "\">" +
                "</a>" +
            "</div>" +
            "<div class=\"store-info\">" +
                "<div style=\"display: flex; align-items: center; gap: 10px;\">" +
                    "<h4>" + store.storeName + "</h4>" +
                    "<button class=\"wishlist-btn\" data-store-id=\"" + store.storeId + "\" aria-label=\"위시리스트 추가/제거\">" +
                        "<i class=\"fa fa-bookmark\"></i>" +
                    "</button>" +
                "</div>" +
                "<p><span class=\"rating\">★ " + (store.avgRating || '0.0') + "</span> 리뷰 " + (store.countRating || 0) + "개</p>" +
                "<p class=\"meta-info\">" + store.storeType + " · " + store.roadAddress + "</p>" +
                "<p class=\"meta-info\">" + store.description + "</p>" +
            "</div>";
            container.appendChild(card);
        });

        if (memberId && memberId.trim() !== '') {
            $('.wishlist-btn').each(function() {
                const storeId = $(this).data('store-id');
                checkWishlistStatus(storeId, this);
            });
        }
    }

    function showRegion(region) {
        document.querySelectorAll(".region-btn").forEach(btn => {
            const btnRegion = btn.getAttribute("data-region");

            if (btnRegion === region) {
                btn.classList.add("active");
                btn.disabled = true;
            } else {
                btn.classList.remove("active");
                btn.disabled = false;
            }
        });
    }

    function showType(type) {
        document.querySelectorAll(".region-btn").forEach(btn => {
            const btnType = btn.getAttribute("data-type");

            if (btnType === type) {
                btn.classList.add("active");
                btn.disabled = true;
            } else {
                btn.classList.remove("active");
                btn.disabled = false;
            }
        });
    }

    document.addEventListener('DOMContentLoaded', function () {
        $(document).on('click', '.wishlist-btn', function () {
            const storeId = $(this).data('store-id');
            toggleWishlist(storeId, this);
        });

        initMap();

        if (option === 'region') {
            renderStoreList(regionStores);
            showMarkersOnMap("map", regionStores);
            if (regionStores.length > 0) {
                const firstRegion = "${regions[0]}";
                if (firstRegion) {
                    showRegion(firstRegion);
                }
            }
        } else if (option === 'type') {
            const typeStores = [
                <c:forEach var="store" items="${typelist}" varStatus="status">
                    {
                        storeId: '${store.storeId}',
                        storeName: '${store.storeName}',
                        roadAddress: '${store.roadAddress}',
                        fileName: '${store.fileName}',
                        avgRating: '${store.avgRating}',
                        countRating: '${store.countRating}',
                        storeType: '${store.storeType}',
                        description: '${store.description}'
                    }<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];
            renderStoreList(typeStores);
            showMarkersOnMap("map", typeStores);
            if (typeStores.length > 0) {
                const firstType = "${types[0]}";
                if (firstType) {
                    showType(firstType);
                }
            }
        } else if (option === 'search') {
            renderStoreList(searchStores);
            showMarkersOnMap("map", searchStores);
        } else if (option === 'userLocation') {
            renderStoreList(userLocationStores);
            showMarkersOnMap("map", userLocationStores);
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function(position) {
                    getAddressFromCoords(position.coords.latitude, position.coords.longitude);
                });
            }
        } else if (option === 'newOpen') {
            renderStoreList(newOpenStores);
            showMarkersOnMap("map", newOpenStores);
        }  else if (option === 'like') {
            renderStoreList(likeStores);
            showMarkersOnMap("map", likeStores);
        }


        document.querySelectorAll(".ajax-region-form").forEach(form => {
            form.addEventListener("submit", function (e) {
                e.preventDefault();

                const formData = new FormData(form);

                fetch(contextPath + "/store/filterByRegion", {
                    method: "POST",
                    body: formData
                })
                .then(res => {
                    if (!res.ok) {
                        throw new Error("서버 응답 실패");
                    }
                    return res.json();
                })
                .then(data => {
                    if (data.storeList) {
                        renderStoreList(data.storeList);
                        showMarkersOnMap("map", data.storeList);
                        showRegion(data.region);
                    } else {
                        console.warn("storeList 없음");
                    }
                })
                .catch(err => {
                    console.error("AJAX 지역 요청 실패:", err);
                });
            });
        });

        document.querySelectorAll(".ajax-type-form").forEach(form => {
            form.addEventListener("submit", function (e) {
                e.preventDefault();

                const formData = new FormData(form);

                fetch(contextPath + "/store/filterByType", {
                    method: "POST",
                    body: formData
                })
                .then(res => {
                    if (!res.ok) {
                        throw new Error("서버 응답 실패");
                    }
                    return res.json();
                })
                .then(data => {
                    if (data.storeList) {
                        renderStoreList(data.storeList);
                        showMarkersOnMap("map", data.storeList);
                        showType(data.type);
                    } else {
                        console.warn("storeList 없음");
                    }
                })
                .catch(err => {
                    console.error("AJAX 지역 요청 실패:", err);
                });
            });
        });

    });
</script>

<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB1kAhEMiW_-y5zg2uFTUeAOTG_uVO_kts&callback=initMap&v=weekly&libraries=marker" defer></script>

<div class="storeList">
	<c:choose>
		<c:when test="${option == 'region'}">
			<h2>지역 맛집 검색</h2>
			<div class="region-buttons two-rows mb-4">
			<c:forEach var="regionName" items="${regions}">
				<form class="region-form ajax-region-form">
					<input type="hidden" name="region" value="${regionName}" />
					<button type="submit" class="btn btn-outline-primary region-btn" data-region="${regionName}">${regionName}</button>
				</form>
			</c:forEach>
			</div>
			<div id="map"></div>
			<div id="store-list-container"></div>
		</c:when>
		
		<c:when test="${option == 'type'}">
			<h2>식당별 검색</h2>
			<div class="region-buttons two-rows mb-4">
				<c:forEach var="type" items="${types}">
					<form class="region-form ajax-type-form">
						<input type="hidden" name="type" value="${type}" />
						<button type="submit" class="btn btn-outline-primary region-btn" data-type="${type}">${type}</button>
					</form>
				</c:forEach>
			</div>
			<div id="map"></div>
			<div id="store-list-container"></div>
		</c:when>
		
		<c:when test="${option == 'search'}">
			<section class="search-bar mb-5">
				<div class="input-group">
					<input type="text" class="form-control" id="keyword" value="${keyword }">
					<button class="btn" type="button" onclick="goSearch()"><i class="bi bi-search"></i></button>
				</div>
			</section>
			<div id="map"></div>
			<div id="store-list-container"></div>
		</c:when>
		
		<c:when test="${option eq 'userLocation'}">
			<h2>주변 맛집</h2>
			<p id="userAddress" class="userLocation"></p>
			<hr>
			<div id="map"></div>
			<div id="store-list-container"></div>
		</c:when>
		
		<c:when test="${option eq 'newOpen'}">
			<h2>신규 등록된 맛집</h2>
			<div id="map"></div>
			<c:if test="${empty newOpenStores}">
				<p>신규 오픈 매장이 없습니다.</p>
			</c:if>
			    
			<c:if test="${not empty newOpenStores}">
				<div id="store-list-container"></div>
			</c:if>
		</c:when>

		
		<c:when test="${option eq 'like'}">
			<h2>사용자들이 찜한 맛집</h2>
			<div id="map"></div>
			<div id="store-list-container"></div>
		</c:when>
	</c:choose>
</div>
