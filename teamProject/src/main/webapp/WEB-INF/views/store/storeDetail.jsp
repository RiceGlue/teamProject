<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>


<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="store" value="${storeMap.store}" />
<c:set var="detailReview" value="${storeMap.detailReview}" />


<html>
<head>
	<title>${store.storeName}</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
	<style>
	 	input[type="text"] { width: 50px; text-align: center; }
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
		.card-rating, .card-detail {flex:1;padding:16px;border:1px solid #ccc;border-radius:6px;text-align:center;background-color:#f9f9f9;}
		.review_count {font-weight:bold;margin-bottom:12px;}
		.countRating {margin-bottom:20px;}
		.rating_bar_container {display:flex;align-items:center;gap:8px;margin-bottom:8px;}
		.rating_label {width:120px;font-weight:500;}
		.rating_bar_bg {background:#eee;width:200px;height:12px;border-radius:6px;overflow:hidden;}
		.rating_bar_fill {background:#f90;height:100%;border-radius:6px 0 0 6px;}
		.detailReviewList {margin-top:20px;}
		.review_box {border:1px solid #ddd;padding:12px;border-radius:6px;margin-bottom:10px;background-color:#fff;}
		.review_stars {color:#f90;font-size:14px;}
		.review_user {font-weight:bold;font-size:13px;margin:4px 0;}
		.review_text {font-size:14px;color:#333;}
		.rating_summary_cards {display:flex;gap:10px;margin-bottom:16px;}
		.card-rating {flex:1;padding:16px;border:1px solid #ccc;border-radius:6px;text-align:center;background-color:#f9f9f9;}
		.card-detail {flex:1;padding:16px;border:1px solid #ccc;border-radius:6px;text-align:center;background-color:#f9f9f9;}
		.time-slot.selected { background-color: #ffc107; font-weight: bold; }
	</style>

	<script>

	document.addEventListener('DOMContentLoaded', function () {
		const timeSlots = document.querySelectorAll('.time-slot');
		const hiddenInput = document.getElementById('selectedTimeSlot');
		const reserveBtn = document.getElementById('reserveBtn');
		const storeId = '${store.storeId}';
		const contextPath = '${contextPath}';

		timeSlots.forEach(slot => {
			slot.addEventListener('click', function () {
				timeSlots.forEach(s => s.classList.remove('selected'));
			this.classList.add('selected');
			hiddenInput.value = this.dataset.time;
			reserveBtn.disabled = false;
			});
		});

		reserveBtn.addEventListener('click', function () {
			const time = hiddenInput.value;
			if (!time) {
				alert("예약 시간을 선택하세요.");
				return;
			}
			const url = contextPath + '/reservation/customer/bookingForm?storeId=' + storeId + '&time=' + encodeURIComponent(time);
			window.location.href = url;
		});
	});

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

		document.addEventListener('DOMContentLoaded', function () {
			const copyBtn = document.getElementById('copyUrlBtn');
			copyBtn.addEventListener('click', function () {
				const url = window.location.href;
				navigator.clipboard.writeText(url).then(function () {
					alert("주소가 복사되었습니다.");
				}).catch(function (err) {
					alert("복사에 실패했습니다: " + err);
				});
			});
		});

		let count = 1; // 초기값

		    function updateDisplay() { document.getElementById("guestCount").value = count;}

		    function addGuest() {
		      count++;
		      updateDisplay();
		    }

		    function minusGuest() {
		      if (count > 1) {
		        count--;
		        updateDisplay();
		      }
		    }
	</script>
</head>

<body>
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
		<button class="btn btn-outline-secondary btn-sm mt-2" id="copyUrlBtn">주소복사</button>



		<div class="tab_container">
			<div class="tab_container" id="container">
				<ul class="tabs">
					<li><a href="#tab1">홈</a></li>
					<li><a href="#tab2">메뉴</a></li>
					<li><a href="#tab3">리뷰</a></li>
				</ul>
				<div class="tab_container">
					<div class="tab_content" id="tab1">
						<div class="reservation-box">
							<h5 class="mt-4">예약</h5>
								<form action="${contentPath }/reservation/customer/bookForm" id="reservation" method="post">
									<div class="mt-3" id="timeSlotContainer">
										<button type="button" onclick="minusGuest()">-</button><input type="text" id="guestCount" value="1" readonly><button type="button" onclick="addGuest()">+</button>
										<c:forEach var="reservation" items="${storeMap.reservation}">
											<input type="button" value="${reservation.timeSlot }">
										</c:forEach>
									</div>

								<input type="hidden" id="selectTimeSlot" value="" />
								<button class="btn-reserve" id="reserveBtn" disabled>예약하기</button>
							</form>
						</div>

						<div class="button-group">
							<a href="<c:url value='/reservation/customer/bookForm?storeId=${store.storeId}'/>">예약하기</a>
							<a href="<c:url value='/reservation/owner/manageList?storeId=${store.storeId}'/>">점주 관리 페이지</a>
						</div>
						<div class="back-link">
							<a href="<c:url value='/store/storeList'/>">매장 목록으로 돌아가기</a>
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
					<div class="tab_content" id="tab3">
						<div class="rating_summary_cards">
							<div class="card card-rating">
								<p>전체 별점</p>
								<h2><img src="별 이미지" alt="별점 이미지">${store.avgRating }</h2>
							</div>
							<div class="card card-detail">
								<c:forEach var="detailReview" items="${storeMap.detailReview}">
									<div class="rating_bar_container">
										<span class="rating_label">${detailReview.rating}점 : ${detailReview.countScoreRating}명</span>
										<div class="rating_bar_bg">
											<div class="rating_bar_fill" style="width: ${detailReview.countScoreRating * 10}px;"></div>
										</div>
									</div>
								</c:forEach>
							</div>
						</div>
						<div class="detailReviewList">
							<h4>리뷰 ${store.countRating}건</h4>
							<c:forEach var="review" items="${storeMap.review }" >
								<div class="review_box">
									<p>${review.rating }점<p>
									<p>${review.writerId}<p>
									<p>${review.content}<p>
								</div>
							</c:forEach>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>