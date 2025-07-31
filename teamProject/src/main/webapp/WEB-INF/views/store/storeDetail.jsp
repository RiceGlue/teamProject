<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="store" value="${storeMap.store}" />
<c:set var="review" value="${storeMap.review }" />
<c:set var="reservation" value="${storeMap.reservation}" />

<html>
<head>
	<title>${store.storeName}</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
	<style>
		.store-info { margin: 20px auto; max-width: 700px; background: #fff; padding: 20px; border-radius: 10px; }
		.store-banner { width: 100%; height: 200px; background-color: #eee; display: flex; justify-content: center; align-items: center; }
		.rating { font-size: 16px; margin-bottom: 10px; }
		.tabs { display: flex; margin-top: 20px; padding: 0; list-style: none; border: 1px solid #ddd; border-radius: 5px; overflow: hidden;}
		.tabs li { background-color: #3f3f3f; cursor: pointer; list-style: none; border-right: 1px solid #ddd; flex: 1; text-align: center; }
		.tabs li:last-child { border-right: none; }
		.tabs li.active { background-color: white; }
		.tabs li a { display: block; padding: 10px 0; color: white; text-decoration: none; transition: color 0.3s ease; }
		.tabs li.active a { color: black; }
		.tabs ul { background-color:#3f3f3f; }
		.tabs li:hover { background-color: white; color:black; }
		.tabs li a:hover { color:black; }
		.tab_content { padding: 20px; background-color: #fff; }
		.reservation-box { margin-top: 30px; }
		.time-slot { padding: 10px 15px; margin: 5px; background: #e0dcdc; border-radius: 5px; display: inline-block; }
		.btn-reserve { margin-top: 15px; width: 100%; padding: 10px; background-color: #f4d6d6; border: none; border-radius: 5px; color: #555; }
		.menu_container { display:flex; flex-wrap:wrap; gap:8px; }
		.menu_card { flex:0 0 calc(25% - 8px); box-sizing:border-box; border:1px solid #000; border-radius:4px; overflow:hidden; font-family:Arial,sans-serif; margin:0; }
		.menu_image { width:100%; height:120px; background:#eee; display:flex; justify-content:center; align-items:center; }
		.menu_image img { max-width:100%; max-height:100%; object-fit:contain; }
		.menu_info { padding:8px; font-size:14px; line-height:1.2; text-align:center; }
		.menu_name { font-weight:bold; margin:4px 0 2px; }
		.menu_price { color:#555; margin:2px 0; }
		.menu_description { color:#777; font-size:12px; margin:2px 0 4px; }
		.detail_countRating { margin-top:16px; }
		.rating_bar_container { display:flex; align-items:center; gap:8px; margin-bottom:6px; }
		.rating_label { width:100px; font-weight:bold; }
		.rating_bar_bg { background:#eee; width:200px; height:12px; border-radius:6px; overflow:hidden; }
		.rating_bar_fill { background:#f90; height:100%; border-radius:6px 0 0 6px; }		
	</style>
	
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
</head>

<body style="background-color: #f4f4f4;">
	<div class="store-info">
		<div id="carouselExampleAutoplaying" class="carousel slide" data-bs-ride="carousel"> <!-- 가게 이미지 캐러셀 -->
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
		<h4 class="mt-3">${store.storeName}</h4>
		<div class="rating">★ ${store.avgRating} 리뷰 ${store.countRating}개</div>
		<div>
			<p><img src="${contextPath}/resources/img/pin.png" width="16" height="16" alt="위치"> ${store.address} <a href="#" style="color: #008cff; font-size: 12px;">위치</a></p>
		</div>
		<div style="color: green;">오늘 ${store.startHour}:${store.startMin} ~ ${store.endHour}:${store.endMin}</div>
		<button class="btn btn-outline-secondary btn-sm mt-2">전화</button>
		<div class="tab_container">
			<div class="tab_container" id="container">
				<ul class="tabs">
					<li><a href="#tab1">홈</a></li>
					<li><a href="#tab2">메뉴</a></li>
					<li><a href="#tab3">리뷰</a></li>
					<li><a href="#tab4">상세 정보</a></li>
				</ul>
				<div class="tab_container">
					<div class="tab_content" id="tab1"> <!-- 홈 -->
						<div class="reservation-box">
							<h5 class="mt-4">예약</h5>
							<div>오늘 (${reservation.day}) · 2명</div>
							<div class="mt-3">
								<span class="time-slot">오전 11:00</span>
								<span class="time-slot">오전 11:30</span>
								<span class="time-slot">오전 12:00</span>
								<span class="time-slot">오전 12:30</span>
								<span class="time-slot">오전 13:00</span>
								<span class="time-slot">오후 13:30</span>
								<span class="time-slot">오후 14:00</span>
							</div>
							<button class="btn-reserve" disabled>예약하기</button>
						</div>
						
						<div class="button-group">
							<%-- 예약 페이지로 이동하는 링크. storeId를 함께 넘깁니다. --%>
							<a href="<c:url value='/reservation/customer/bookForm?storeId=${store.storeId}'/>">예약하기</a>
							<%-- 점주용 관리 페이지로 이동하는 링크. storeId를 함께 넘깁니다. --%>
							<a href="<c:url value='/reservation/owner/manageList?storeId=${store.storeId}'/>">점주 관리 페이지</a>
						</div>
													
						<div class="back-link">
							<a href="<c:url value='/store/storeList.do'/>">매장 목록으로 돌아가기</a>
						</div>
						
					</div>
					<div class="tab_content" id="tab2"> <!-- 메뉴 -->
						<div class="menu_container">
							<c:forEach var="menu" items="${storeMap.menu}">
								<div class="menu_card">
									<div class="menu_image">
										<img src="${menu.imageName}" alt="${menu.menuName}">
									</div>
									<div class="menu_info">
										<p class="menu_name">${menu.menuName}</p>
										<p class="menu_price">${menu.price}원</p>
										<p class="menu_description">${menu.description}</p>
									</div>
								</div>
							</c:forEach>
						</div>
					</div>
					<div class="tab_content" id="tab3"> <!-- 리뷰 -->
						<div class="avgRating">
							<h4>전체 평점</h4>
							<h1><img src="별 사진">${store.avgRating }</h1>
						</div>
						
						<div class="detail_countRating">
							<c:forEach var="detailReview" items="${storeMap.detailReview }">
								<div class="rating_bar_container">
									<span class="rating_label">${detailReview.rating}점 : ${detailReview.countScoreRating}명</span>
									<div class="rating_bar_bg">
										<div class="rating_bar_fill" style="width: ${detailReview.countScoreRating * 10}px;"></div>
									</div>
								</div>
							</c:forEach>
						</div>

					</div>
					<div class="tab_content" id="tab4"> <!-- 상세 정보 -->
					</div>
				</div>
			</div>
		</div>	
	</div>
</body>
</html>