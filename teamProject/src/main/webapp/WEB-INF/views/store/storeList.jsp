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
</style>

<script>
const memberId = "${memberId}";
var contextPath = '${contextPath}';

	document.addEventListener('DOMContentLoaded', function () {
		$(".tab_content").hide(); // 모든 탭 콘텐츠 숨김
		$("ul.tabs li:first").addClass("active").show(); // 첫 번째 탭 활성화
		$(".tab_content:first").show(); // 첫 번째 탭 콘텐츠 보여줌

		// 탭 클릭 이벤트
		$("ul.tabs li").click(function (e) {
			e.preventDefault();

			$("ul.tabs li").removeClass("active"); // 모든 탭 비활성화
			$(this).addClass("active"); // 클릭한 탭 활성화
			$(".tab_content").hide(); // 모든 탭 콘텐츠 숨김

			var activeTab = $(this).find("a").attr("href"); // href에서 id 가져옴
			$(activeTab).fadeIn(); // 해당 콘텐츠 표시
		});
	});

	const regionStores = [
		<c:forEach var="region" items="${regionlist}" varStatus="status">
	    	{ name: "${region.storeName}", address: "${region.roadAddress}" }<c:if test="${!status.last}">,</c:if>
	 	</c:forEach>
	];

    const menuStores = [
    	<c:forEach var="menu" items="${menulist}" varStatus="status">
        	{ name: "${menu.storeName}", address: "${menu.roadAddress}" }<c:if test="${!status.last}">,</c:if>
      	</c:forEach>
    ];

    const addrStores = [
    	<c:forEach var="addr" items="${addrlist}" varStatus="status">
        	{ name: "${addr.storeName}", address: "${addr.roadAddress}" }<c:if test="${!status.last}">,</c:if>
      	</c:forEach>
    ];

    const nameStores = [
      	<c:forEach var="name" items="${namelist}" varStatus="status">
        	{ name: "${name.storeName}", address: "${name.roadAddress}" }<c:if test="${!status.last}">,</c:if>
      	</c:forEach>
    ];
    
    const userLocationStores = [
		<c:forEach var="userLocation" items="${userLocationlist}" varStatus="status">
	    	{ name: "${userLocation.storeName}", address: "${userLocation.roadAddress}" }<c:if test="${!status.last}">,</c:if>
	 	</c:forEach>
	];

    let map,markers=[];

    function initMap(){map=new google.maps.Map(document.getElementById("map"),{center:{lat:37.5665,lng:126.9780},zoom:11});}
    
    function showMarkers(storeList) {
    	  const geocoder = new google.maps.Geocoder();
    	  markers.forEach(m => m.setMap(null));
    	  markers = [];

    	  let isFirstMarker = true;

    	  storeList.forEach(store => {
    	    if (store.address) {
    	      geocoder.geocode({ address: store.roadAddress }, (results, status) => {
    	        if (status === "OK") {
    	          const pos = results[0].geometry.location;
    	          const marker = new google.maps.Marker({
    	            map: map,
    	            position: pos,
    	            title: store.name
    	          });

    	          // ✅ 첫 마커 위치로 지도 중심 이동
    	          if (isFirstMarker) {
    	            map.setCenter(pos);
    	            map.setZoom(14); // 확대 정도 조절 가능
    	            isFirstMarker = false;
    	          }

    	          markers.push(marker);
    	        } else {
    	          console.error(`주소 변환 실패 (${store.roadAddress}): ${status}`);
    	        }
    	      });
    	    }
    	  });
    	}


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

    	  // 지도 초기화
    	  initMap();

    	  // 어떤 option으로 왔는지에 따라 초기 마커 설정
    	  const option = "${option}";
    	  if (option === "userLocation") {
    	    showMarkers(userLocationStores);
    	  } else if (option === "region") {
    	    showMarkers(regionStores);
    	  } else if (option === "search") {
    	    // 기본 탭에 따라 결정
    	    showMarkers(menuStores); // tab1이 기본이므로
    	  }
    	});
    
    document.addEventListener('DOMContentLoaded', function () {
        const option = "${option}";

        if (option === "userLocation") {
            // 사용자 위치 가져오기 시작
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(success, error);
            } else {
                alert("브라우저가 위치 정보를 지원하지 않습니다.");
            }
        } else {
            // 기존 초기화 로직
            initMap();
            // 그리고 기존 탭별 마커 표시 등 처리
            // ...
        }

        function success(position) {
            const lat = position.coords.latitude;
            const lng = position.coords.longitude;
            getAddressFromCoords(lat, lng);
        }

        function error() {
            alert("사용자 위치를 가져오지 못했습니다.");
        }

        function getAddressFromCoords(lat, lng) {
            const geocoder = new google.maps.Geocoder();
            const latlng = { lat: lat, lng: lng };
            geocoder.geocode({ location: latlng }, function (results, status) {
                if (status === "OK" && results[0]) {
                    const fullAddress = results[0].formatted_address;
                    console.log("사용자 주소:", fullAddress);

                    // 여기서 주소를 화면에 출력
                    const addressElem = document.getElementById("userAddress");
                    if (addressElem) {
                        addressElem.innerText = fullAddress;
                    }

                    // 주소 기반 근처 매장 검색 함수 실행
                    fetchNearbyStores(fullAddress);
                } else {
                    alert("주소를 가져올 수 없습니다.");
                }
            });
        }

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

    $(document).on('click', '.wishlist-btn', function () {
        const storeId = $(this).data('store-id');
        toggleWishlist(storeId, this);
    });

    function toggleWishlist(storeId, btnElement) {
    	if (!memberId || memberId == null || memberId.trim() === '') {
            if (confirm('로그인 후 이용해주세요. 로그인 페이지로 이동하시겠습니까?')) {
                window.location.href = contextPath + '/member/login';  // 로그인 페이지 경로 맞게 수정하세요
            }
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

    $(function () {
        // 로그인 된 상태라면 위시리스트 상태 확인 실행
        if (memberId) {
            $('.wishlist-btn').each(function() {
                const storeId = $(this).data('store-id');
                checkWishlistStatus(storeId, this);
            });
        }
    });
</script>

<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB1kAhEMiW_-y5zg2uFTUeAOTG_uVO_kts&callback=initMap&v=weekly&libraries=marker" defer></script>
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
	<h2>${keyword }</h2>
	<hr>

	<!-- 반복 렌더링 시작 -->
	<div id="map"></div>
	<c:choose>
		<c:when test="${empty regionlist }"><h3>검색 결과 없음</h3></c:when>
		<c:otherwise>
			<c:forEach var="region" items="${regionlist}" varStatus="status">
			  <div class="store-card">
			    <div class="store-image">
			      <a href="${contextPath}/store/storeDetail?storeId=${region.storeId}">
			        <img src="${contextPath }/images/store/${region.fileName}" alt="${region.fileName }">
			      </a>
			<!--       대기 팀 수 표시 -->
			<%--       <c:if test="${store.waitCount > 0}"> --%>
			<%--         <div class="badge-wait">대기 ${store.waitCount}팀</div> --%>
			<%--       </c:if> --%>
			    </div>
		
			    <div class="store-info">
			    	<div style="display: flex; align-items: center; gap: 10px;">
				      <h4>${region.storeName}</h4>
				      <button class="wishlist-btn" data-store-id="${region.storeId }" aria-label="위시리스트 추가/제거">
	                        <i class="fa fa-bookmark"></i>
	                  </button>
	                 </div>
			      <p>
			        <span class="rating">★ ${region.avgRating}</span>
			        리뷰 ${region.countRating}개
			      </p>
			      <p class="meta-info">${region.storeType} · ${region.roadAddress}</p>
			      <p class="meta-info">${region.description}</p>
			    </div>
			  </div>
			</c:forEach>
		</c:otherwise>
	</c:choose>
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