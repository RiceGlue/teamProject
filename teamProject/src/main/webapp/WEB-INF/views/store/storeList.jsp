<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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
	
	.tabs { display: flex; margin-top: 20px; padding: 0; list-style: none; overflow: hidden;}
	.tabs li { background-color: #3f3f3f; cursor: pointer; list-style: none; border-right: 1px solid #ddd; flex: 1; text-align: center; }
	.tabs li:last-child { border-right: none; }
	.tabs li.active { background-color: white; }
	.tabs li a { display: block; padding: 10px 0; color: white; text-decoration: none; transition: color 0.3s ease; }
	.tabs li.active a { color: black; }
	.tabs ul { background-color:#3f3f3f; }
	.tabs li:hover { background-color: white; color:black; }
	.tabs li a:hover { color:black; }
	.tab_content { padding: 20px; background-color: #fff; }
</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
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
		<c:forEach var="store" items="${storelist}" varStatus="status">
	    	{ name: "${store.storeName}", address: "${store.address}" }<c:if test="${!status.last}">,</c:if>
	 	</c:forEach>
	];   
	
    const menuStores = [
    	<c:forEach var="menu" items="${menulist}" varStatus="status">
        	{ name: "${menu.storeName}", address: "${menu.address}" }<c:if test="${!status.last}">,</c:if>
      	</c:forEach>
    ];

    const addrStores = [
    	<c:forEach var="addr" items="${addrlist}" varStatus="status">
        	{ name: "${addr.storeName}", address: "${addr.address}" }<c:if test="${!status.last}">,</c:if>
      	</c:forEach>
    ];

    const nameStores = [
      	<c:forEach var="name" items="${namelist}" varStatus="status">
        	{ name: "${name.storeName}", address: "${name.address}" }<c:if test="${!status.last}">,</c:if>
      	</c:forEach>
    ];
    
    let map,markers=[];
    
    function initMap(){map=new google.maps.Map(document.getElementById("map"),{center:{lat:37.5665,lng:126.9780},zoom:12});}
    function showMarkers(storeList){
      const geocoder=new google.maps.Geocoder();
      markers.forEach(m=>m.setMap(null));markers=[];
      storeList.forEach(store=>{
        if(store.address){
          geocoder.geocode({address:store.address},(results,status)=>{
            if(status==="OK"){
              const pos=results[0].geometry.location;
              const marker=new google.maps.Marker({map:map,position:pos,title:store.name});
              markers.push(marker);
            }else{console.error(`주소 변환 실패 (${store.address}): ${status}`);}
          });
        }
      });
    }

    document.addEventListener('DOMContentLoaded', function () {
    	  $(".tab_content").hide();
    	  $("ul.tabs li:first").addClass("active").show();
    	  $(".tab_content:first").show();

    	  // 탭 클릭 이벤트
    	  $("ul.tabs li").click(function (e) {
    	    e.preventDefault();

    	    $("ul.tabs li").removeClass("active");
    	    $(this).addClass("active");
    	    $(".tab_content").hide();

    	    const activeTab = $(this).find("a").attr("href");
    	    $(activeTab).fadeIn();

    	    // 탭에 따라 다른 store 리스트 전달
    	    if (activeTab === "#tab1") {
    	      showMarkers(menuStores);
    	    } else if (activeTab === "#tab2") {
    	      showMarkers(addrStores);
    	    } else if (activeTab === "#tab3") {
    	      showMarkers(nameStores);
    	    }
    	  });

    	  // 최초 지도 초기화 및 첫 탭 데이터 로딩
    	  initMap();
    	  showMarkers(menuStores);
    	});

</script>

<!-- Google Maps API (storeMap은 맨 아래에서 선언) -->
<script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB1kAhEMiW_-y5zg2uFTUeAOTG_uVO_kts&callback=initMap" ></script>

<c:choose>
<c:when test="${option eq 'search'}">
	<h2><span style="color:#4296e0;">${keyword }</span> 검색 결과 </h2>

	
	<div class="tab_container">
		<div class="tab_container" id="container">
			<ul class="tabs">
				<li><a href="#tab1">메뉴 검색</a></li>
				<li><a href="#tab2">주소 검색</a></li>
				<li><a href="#tab3">매장명 검색</a></li>
			</ul>
			<div class="tab_container">
				<div class="tab_content" id="tab1">
					<c:forEach var="menu" items="${menulist}" varStatus="status">
						<div id="map" style="width: 100%; height: 500px; margin: 20px 0;"></div>
						<div class="store-card">
							<div class="store-image">
								<a href="${contextPath}/store/storeDetail?storeId=${menu.storeId}"><img src="${menu.mainImage}" alt="가게이미지"></a>
								<!--       대기 팀 수 표시 -->
								<%--       <c:if test="${store.waitCount > 0}"> --%>
								<%--         <div class="badge-wait">대기 ${store.waitCount}팀</div> --%>
								<%--       </c:if> --%>
							</div>
							
							<div class="store-info">
								<h4>${menu.storeName}</h4>
								<p><span class="rating">★ ${menu.avgRating}</span>리뷰 ${menu.countRating}개</p>
								<p class="meta-info">${menu.storeType} · ${menu.region}</p>
								<p class="meta-info">${menu.description}</p>
								<%--       <p class="meta-info">${menu.openHour}:${menu.openMin}~${menu.endHour}:${menu.endMin}</p> --%>
							</div>
						</div>
					</c:forEach>
				</div>
				<div class="tab_content" id="tab2">
					<c:forEach var="addr" items="${addrlist}" varStatus="status">
						<div id="map" style="width: 100%; height: 500px; margin: 20px 0;"></div>
						<div class="store-card">
							<div class="store-image">
								<a href="${contextPath}/store/storeDetail?storeId=${addr.storeId}"><img src="${addr.mainImage}" alt="가게이미지"></a>
								<!--       대기 팀 수 표시 -->
								<%--       <c:if test="${store.waitCount > 0}"> --%>
								<%--         <div class="badge-wait">대기 ${store.waitCount}팀</div> --%>
								<%--       </c:if> --%>
							</div>
							
							<div class="store-info">
								<h4>${store.storeName}</h4>
								<p><span class="rating">★ ${addr.avgRating}</span>리뷰 ${addr.countRating}개</p>
								<p class="meta-info">${addr.storeType} · ${addr.region}</p>
								<p class="meta-info">${addr.description}</p>
								<%--       <p class="meta-info">${addr.openHour}:${addr.openMin}~${addr.endHour}:${addr.endMin}</p> --%>
							</div>
						</div>
					</c:forEach>
				</div>
				<div class="tab_content" id="tab3">
					<c:forEach var="name" items="${namelist}" varStatus="status">
						<div id="map" style="width: 100%; height: 500px; margin: 20px 0;"></div>
						<div class="store-card">
							<div class="store-image">
								<a href="${contextPath}/store/storeDetail?storeId=${name.storeId}"><img src="${name.mainImage}" alt="가게이미지"></a>
								<!--       대기 팀 수 표시 -->
								<%--       <c:if test="${name.waitCount > 0}"> --%>
								<%--         <div class="badge-wait">대기 ${name.waitCount}팀</div> --%>
								<%--       </c:if> --%>
							</div>
							
							<div class="store-info">
								<h4>${name.storeName}</h4>
								<p><span class="rating">★ ${name.avgRating}</span>리뷰 ${name.countRating}개</p>
								<p class="meta-info">${name.storeType} · ${name.region}</p>
								<p class="meta-info">${name.description}</p>
								<%--       <p class="meta-info">${name.openHour}:${name.openMin}~${name.endHour}:${name.endMin}</p> --%>
							</div>
						</div>
					</c:forEach>
				</div>
			</div>
		</div>
	</div>
</c:when>

<c:when test="${option eq 'region'}">
	<h2>${keyword }</h2>
	<hr>
	
	<!-- 반복 렌더링 시작 -->
	<c:forEach var="store" items="${storelist}" varStatus="status">
	<div id="map" style="width: 100%; height: 500px; margin: 20px 0;"></div>
	  <div class="store-card">
	    <div class="store-image">
	      <a href="${contextPath}/store/storeDetail?storeId=${store.storeId}">
	        <img src="${store.mainImage}" alt="가게이미지">
	      </a>
	<!--       대기 팀 수 표시 -->
	<%--       <c:if test="${store.waitCount > 0}"> --%>
	<%--         <div class="badge-wait">대기 ${store.waitCount}팀</div> --%>
	<%--       </c:if> --%>
	    </div>
	
	    <div class="store-info">
	      <h4>${store.storeName}</h4>
	      <p>
	        <span class="rating">★ ${store.avgRating}</span>
	        리뷰 ${store.countRating}개
	      </p>
	      <p class="meta-info">${store.storeType} · ${store.region}</p>
	      <p class="meta-info">${store.description}</p>
	<%--       <p class="meta-info">${store.openHour}:${store.openMin}~${store.endHour}:${store.endMin}</p> --%>
	    </div>
	  </div>
	</c:forEach>
</c:when>

<c:otherwise></c:otherwise>
</c:choose>