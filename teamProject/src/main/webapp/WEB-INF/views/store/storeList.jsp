<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">

<style>
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
	.storeList {width:80%; margin: 0 auto; margin-top:20px; }
	
</style>

<script>
const regionStores = [
    <c:forEach var="store" items="${regionlist}" varStatus="status">
        {
            storeId: '${store.storeId}',
            storeName: '${store.storeName}',
            roadAddress: '${store.roadAddress}',
        }<c:if test="${!status.last}">,</c:if>
    </c:forEach>
];

const menuStores = [
    <c:forEach var="store" items="${menulist}" varStatus="status">
        {
            storeId: '${store.storeId}',
            storeName: '${store.storeName}',
            roadAddress: '${store.roadAddress}',
        }<c:if test="${!status.last}">,</c:if>
    </c:forEach>
];

const addrStores = [
    <c:forEach var="store" items="${addrlist}" varStatus="status">
        {
            storeId: '${store.storeId}',
            storeName: '${store.storeName}',
            roadAddress: '${store.roadAddress}',
        }<c:if test="${!status.last}">,</c:if>
    </c:forEach>
];

const nameStores = [
    <c:forEach var="store" items="${namelist}" varStatus="status">
        {
            storeId: '${store.storeId}',
            storeName: '${store.storeName}',
            roadAddress: '${store.roadAddress}',
        }<c:if test="${!status.last}">,</c:if>
    </c:forEach>
];

const userLocationStores = [
    <c:forEach var="store" items="${userLocationlist}" varStatus="status">
        {
            storeId: '${store.storeId}',
            storeName: '${store.storeName}',
            roadAddress: '${store.roadAddress}',
        }<c:if test="${!status.last}">,</c:if>
    </c:forEach>
];

const memberId = "${memberId != null ? memberId : ''}";
const contextPath = '${contextPath}';
const option = "${option}";

let map;
let markers = [];

function initMap() {
    map = new google.maps.Map(document.getElementById("map"), {
        center: { lat: 37.5665, lng: 126.9780 },
        zoom: 11
    });
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

async function showMarkers(storeList) {
    console.log("showMarkers 호출, 데이터 개수:", storeList.length);
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

async function centerMapToFirstStore(storeList) {
    if (!storeList || storeList.length === 0) return;
    const firstStore = storeList[0];
    const address = firstStore.roadAddress || firstStore.address;
    if (!address) return;

    const geocoder = new google.maps.Geocoder();

    try {
        const pos = await geocodeAddress(geocoder, address);
        map.setCenter(pos);
        map.setZoom(14);
    } catch (error) {
        console.error("지도 중심 이동 실패:", error);
    }
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

// ⭐ renderStoreList 함수 추가 (AJAX 결과 반영용)
function renderStoreList(storeList) {
    const container = document.getElementById('store-list-container');
    container.innerHTML = '';

    if (!storeList || storeList.length === 0) {
        container.innerHTML = '<h3>검색 결과 없음</h3>';
        return;
    }

    storeList.forEach(store => {
        const card = document.createElement('div');
        card.className = 'store-card';

        card.innerHTML =
            '<div class="store-image">' +
                '<a href="' + contextPath + '/store/storeDetail?storeId=' + store.storeId + '">' +
                    '<img src="' + window.location.origin + '/images/store/' + (store.fileName || 'default.jpg') + '" alt="' + store.storeName + '">' +
                '</a>' +
            '</div>' +
            '<div class="store-info">' +
                '<div style="display: flex; align-items: center; gap: 10px;">' +
                    '<h4>' + store.storeName + '</h4>' +
                    '<button class="wishlist-btn" data-store-id="' + store.storeId + '">' +
                        '<i class="fa fa-bookmark"></i>' +
                    '</button>' +
                '</div>' +
                '<p class="meta-info">' + (store.storeType || '') + ' · ' + (store.roadAddress || '') + '</p>' +
                '<p class="meta-info">' + (store.description || '') + '</p>' +
            '</div>';

            
        container.appendChild(card);
    });

    // 위시리스트 상태 다시 체크
    if (memberId && memberId.trim() !== '') {
        $('.wishlist-btn').each(function() {
            const storeId = $(this).data('store-id');
            checkWishlistStatus(storeId, this);
        });
    }
}

// ⭐ DOMContentLoaded 내부
document.addEventListener('DOMContentLoaded', function () {
    $(".tab_content").hide();
    $("ul.tabs li:first").addClass("active").show();
    $(".tab_content:first").show();

    const activeTabStores = {
        "#tab1": menuStores,
        "#tab2": addrStores,
        "#tab3": nameStores
    };

    $("ul.tabs li").click(function (e) {
        e.preventDefault();
        $("ul.tabs li").removeClass("active");
        $(this).addClass("active");
        $(".tab_content").hide();

        const activeTab = $(this).find("a").attr("href");
        $(activeTab).fadeIn();

        if (activeTabStores[activeTab]) {
            showMarkers(activeTabStores[activeTab]);
        }
    });

    $(document).on('click', '.wishlist-btn', function () {
        const storeId = $(this).data('store-id');
        toggleWishlist(storeId, this);
    });

    initMap();

    if (option === "userLocation") {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                position => {
                    const lat = position.coords.latitude;
                    const lng = position.coords.longitude;
                    getAddressFromCoords(lat, lng);
                    showMarkers(userLocationStores);
                },
                () => {
                    alert("사용자 위치를 가져오지 못했습니다.");
                }
            );
        } else {
            alert("브라우저가 위치 정보를 지원하지 않습니다.");
        }
    } else if (option === "region") {
        showMarkers(regionStores);
    } else if (option === "search") {
        showMarkers(menuStores);
    }

    if (memberId && memberId.trim() !== '') {
        $('.wishlist-btn').each(function() {
            const storeId = $(this).data('store-id');
            checkWishlistStatus(storeId, this);
        });
    }

    document.querySelectorAll(".ajax-region-form").forEach(form => {
        form.addEventListener("submit", function (e) {
            e.preventDefault();

            const formData = new FormData(form);

            fetch(contextPath + "/store/regionList", {
                method: "POST", // ✅ POST 방식으로 변경
                body: formData
            })
            .then(res => {
                if (!res.ok) {
                    throw new Error("서버 응답 실패");
                }
                return res.json();
            })
            .then(data => {
                if (data.regionList) {
                    renderStoreList(data.regionList);
                    showMarkers(data.regionList);
                } else {
                    console.warn("regionList 없음");
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
<c:when test="${option eq 'search'}">
	<h2><span style="color:#4296e0;">${keyword }</span> 검색 결과 </h2>


	<div class="tab_container">
		<div class="tab_container" id="container">
			<ul class="tabs">
				<li><a href="#tab1">메뉴</a></li>
				<li><a href="#tab2">주소</a></li>
				<li><a href="#tab3">매장명</a></li>
			</ul>
			<div class="tab_container">
				<div class="tab_content" id="tab1">
					<c:choose>
						<c:when test="${empty menulist }"><h3>검색 결과 없음</h3></c:when>
						<c:otherwise>
							<div id="map"></div>
							<c:forEach var="menu" items="${menulist}" varStatus="status">
								<div class="store-card">
									<div class="store-image">
										<a href="${contextPath}/store/storeDetail?storeId=${menu.storeId}"><img src="${contextPath }/images/store/${menu.fileName}" alt="${menu.fileName }"></a>
										<!--       대기 팀 수 표시 -->
										<%--       <c:if test="${store.waitCount > 0}"> --%>
										<%--         <div class="badge-wait">대기 ${store.waitCount}팀</div> --%>
										<%--       </c:if> --%>
									</div>
		
									<div class="store-info">
										<div style="display: flex; align-items: center; gap: 10px;">
									      <h4>${menu.storeName}</h4>
									      <button class="wishlist-btn" data-store-id="${menu.storeId }" aria-label="위시리스트 추가/제거">
						                        <i class="fa fa-bookmark"></i>
						                  </button>
						                 </div>
										<p><span class="rating">★ ${menu.avgRating}</span>리뷰 ${menu.countRating}개</p>
										<p class="meta-info">${menu.storeType} · ${menu.roadAddress}</p>
										<p class="meta-info">${menu.description}</p>
									</div>
								</div>
							</c:forEach>
						</c:otherwise>
					</c:choose>
				</div>
				<div class="tab_content" id="tab2">
					<c:choose>
						<c:when test="${empty addrlist }"><h3>검색 결과 없음</h3></c:when>
						<c:otherwise>
							<div id="map"></div>
							<c:forEach var="addr" items="${addrlist}" varStatus="status">	
								<div class="store-card">
									<div class="store-image">
										<a href="${contextPath}/store/storeDetail?storeId=${addr.storeId}"><img src="${contextPath }/images/store/${addr.fileName}" alt="${addr.fileName }"></a>
										<!--       대기 팀 수 표시 -->
										<%--       <c:if test="${store.waitCount > 0}"> --%>
										<%--         <div class="badge-wait">대기 ${store.waitCount}팀</div> --%>
										<%--       </c:if> --%>
									</div>
		
									<div class="store-info">
										<div style="display: flex; align-items: center; gap: 10px;">
									      <h4>${addr.storeName}</h4>
									      <button class="wishlist-btn" data-store-id="${addr.storeId }" aria-label="위시리스트 추가/제거">
						                        <i class="fa fa-bookmark"></i>
						                  </button>
						                 </div>
										<p><span class="rating">★ ${addr.avgRating}</span>리뷰 ${addr.countRating}개</p>
										<p class="meta-info">${addr.storeType} · ${addr.roadAddress}</p>
										<p class="meta-info">${addr.description}</p>
									</div>
								</div>
							</c:forEach>
						</c:otherwise>
					</c:choose>
				</div>
				<div class="tab_content" id="tab3">
					<c:choose>
						<c:when test="${empty namelist }"><h3>검색 결과 없음</h3></c:when>
						<c:otherwise>
							<div id="map"></div>
							<c:forEach var="name" items="${namelist}" varStatus="status">
								<div class="store-card">
									<div class="store-image">
										<a href="${contextPath}/store/storeDetail?storeId=${name.storeId}"><img src="${contextPath }/images/store/${name.fileName}" alt="${name.fileName }"></a>
										<!--       대기 팀 수 표시 -->
										<%--       <c:if test="${name.waitCount > 0}"> --%>
										<%--         <div class="badge-wait">대기 ${name.waitCount}팀</div> --%>
										<%--       </c:if> --%>
									</div>
		
									<div class="store-info">
										<div style="display: flex; align-items: center; gap: 10px;">
										    <h4>${name.storeName}</h4>
										    <button class="wishlist-btn" data-store-id="${name.storeId }" aria-label="위시리스트 추가/제거">
							                	<i class="fa fa-bookmark"></i>
							                </button>
						                </div>
										<p><span class="rating">★ ${name.avgRating}</span>리뷰 ${name.countRating}개</p>
										<p class="meta-info">${name.storeType} · ${name.roadAddress}</p>
										<p class="meta-info">${name.description}</p>
									</div>
								</div>
							</c:forEach>
						</c:otherwise>
					</c:choose>
				</div>
			</div>
		</div>
	</div>
</c:when>

<c:when test="${option eq 'region'}">
	<h2 style="margin-bottom:20px;">지역을 선택해주세요</h2>
    <div class="region-buttons two-rows mb-4">
		<c:forEach var="regionName" items="${regions}">
		    <form class="region-form ajax-region-form">
		        <input type="hidden" name="option" value="region" />
		        <input type="hidden" name="keyword" value="${regionName}" />
		        <button type="submit" class="btn btn-outline-primary">${regionName}</button>
		    </form>
		</c:forEach>
	</div>

	<div id="map"></div>
	<div id="store-list-container"></div>
</c:when>

<c:when test="${option eq 'userLocation'}">
	<h2>주변 맛집</h2>
	<p id="userAddress" class="userLocation"></p>

	<hr>

	<!-- 반복 렌더링 시작 -->
	<div id="map"></div>
	<c:choose>
		<c:when test="${empty userLocationlist }"><h3>검색 결과 없음</h3></c:when>
		<c:otherwise>
			<c:forEach var="userLocation" items="${userLocationlist}" varStatus="status">
			  <div class="store-card">
			    <div class="store-image">
			      <a href="${contextPath}/store/storeDetail?storeId=${userLocation.storeId}">
			        <img src="${contextPath }/images/store/${userLocation.fileName}" alt="${userLocation.fileName }">
			      </a>
			<!--       대기 팀 수 표시 -->
			<%--       <c:if test="${store.waitCount > 0}"> --%>
			<%--         <div class="badge-wait">대기 ${store.waitCount}팀</div> --%>
			<%--       </c:if> --%>
			    </div>
		
			    <div class="store-info">
			     <div style="display: flex; align-items: center; gap: 10px;">
				      <h4>${userLocation.storeName}</h4>
				      <button class="wishlist-btn" data-store-id="${userLocation.storeId }" aria-label="위시리스트 추가/제거">
	                        <i class="fa fa-bookmark"></i>
	                  </button>
	             </div>
			      <p>
			        <span class="rating">★ ${userLocation.avgRating}</span>
			        리뷰 ${userLocation.countRating}개
			      </p>
			      <p class="meta-info">${userLocation.storeType} · ${userLocation.roadAddress}</p>
			      <p class="meta-info">${userLocation.description}</p>
			    </div>
			  </div>
			</c:forEach>
		</c:otherwise>
	</c:choose>
</c:when>
<c:otherwise></c:otherwise>
</c:choose>
</div>