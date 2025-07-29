<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<script>
	$(document).ready(function() { //tab 실행

		//When page loads...
		$(".tab_content").hide(); //Hide all content
		$("ul.tabs li:first").addClass("active").show(); //Activate first tab
		$(".tab_content:first").show(); //Show first tab content

		//On Click Event
		$("ul.tabs li").click(function() {

			$("ul.tabs li").removeClass("active"); //Remove any "active" class
			$(this).addClass("active"); //Add "active" class to selected tab
			$(".tab_content").hide(); //Hide all tab content

			var activeTab = $(this).find("a").attr("href"); //Find the href attribute value to identify the active tab + content
			$(activeTab).fadeIn(); //Fade in the active ID content
			return false;
		});

	});
</script>

<c:set var="store"  value="${storeMap.storeVO}"  />
<c:set var="imagelist"  value="${storeMap.imageFileVO }"  />

<c:forEach var="image" items="${imagelist }">
	<div id="carouselExampleAutoplaying" class="carousel slide" data-bs-ride="carousel">
		<div class="carousel-inner">
			<div class="carousel-item active">
				<img src="..." class="d-block w-100" alt="...">
			</div>
			<div class="carousel-item">
				<img src="..." class="d-block w-100" alt="...">
			</div>
			<div class="carousel-item">
				<img src="..." class="d-block w-100" alt="...">
			</div>
		</div>
		<button class="carousel-control-prev" type="button" data-bs-target="#carouselExampleAutoplaying" data-bs-slide="prev">
			<span class="carousel-control-prev-icon" aria-hidden="true"></span>
			<span class="visually-hidden">Previous</span>
		</button>
		<button class="carousel-control-next" type="button" data-bs-target="#carouselExampleAutoplaying" data-bs-slide="next">
			<span class="carousel-control-next-icon" aria-hidden="true"></span>
			<span class="visually-hidden">Next</span>
		</button>
	</div>
</forEach>

<div>
	<h4>${store.storeName } </h4>
	<p>⭐${store.avgRating} 리뷰 ${store.countRating}개</p>
	<p>${store.address}
	<p>${store.startHour}:${store.startMin}~${store.endHour}:${store.endMin}
</div>

<div class="tab_container">
	<div class="tab_container" id="container">
		<ul class="tabs">
			<li><a href="#tab1">홈</a></li>
			<li><a href="#tab2">메뉴</a></li>
			<li><a href="#tab3">리뷰</a></li>
			<li><a href="#tab4">매장 정보</a></li>
		</ul>
		<div class="tab_container">
			<div class="tab_content" id="tab1">
			</div>
		</div>
	</div>
<div>
			