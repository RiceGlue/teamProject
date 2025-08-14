<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">

<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="store" value="${storeMap.store}" />
<c:set var="detailReview" value="${storeMap.detailReview}" />
<c:set var="storeId" value="${store.storeId}" />
<%-- <c:set var="res" value="${storeMap.reservation}" /> --%>

<html>
<head>
	<title>${store.storeName}</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
	<style>
		/* 기존 CSS 유지 */
		p { display: flex; align-items: center; gap: 7px;}
	 	input[type="text"]:not(.form-control) { width: 50px; text-align: center; }
		.store-info { margin: 20px auto; max-width: 700px; background: #fff; padding: 20px; border-radius: 10px; }
		.store-banner { width: 100%; height: 200px; background-color: #eee; display: flex; justify-content: center; align-items: center; }
		
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
		
		/*메뉴*/
		.menu_container { display:flex; flex-wrap:wrap; gap:8px; }
		.menu_card { flex:0 0 calc(25% - 8px); box-sizing:border-box; border:1px solid #000; border-radius:4px; overflow:hidden; font-family:Arial,sans-serif; margin:0; }
		.menu_image { width:100%; height:120px; background:#eee; display:flex; justify-content:center; align-items:center; }
		.menu_image img { max-width:100%; max-height:100%; object-fit:contain; }
		.menu_info { padding:8px; font-size:14px; line-height:1.2; text-align:center; }
		.menu_name { font-weight:bold; margin:4px 0 2px; }
		.menu_price { color:#555; margin:2px 0; }
		.menu_description { color:#777; font-size:12px; margin:2px 0 4px; }
		
		/*리뷰*/
		.rating{ font-size: 16px; margin-bottom: 10px; }
		.card-rating, .card-detail {flex:1;padding:16px;border:1px solid #ccc;border-radius:6px;text-align:center;background-color:#f9f9f9;}
		.review_count {font-weight:bold;margin-bottom:12px;}
		.countRating {margin-bottom:20px;}
		.rating_bar_container {display:flex;align-items:center;gap:8px;margin-bottom:8px;}
		.rating_label {width:120px;font-weight:500;}
		.rating_bar_bg {background:#e1e1df; width:200px; height:12px; border-radius:6px; overflow:hidden;}
		.rating_bar_fill {background:#f90;height:100%;border-radius:6px 0 0 6px;}
		.detailReviewList {margin-top:20px;}
		.review_box {border:1px solid #ddd;padding:12px;border-radius:6px;margin-bottom:10px;background-color:#fff;}
		.review_stars {color:#f90;font-size:14px;}
		.review_user {font-weight:bold;font-size:13px;margin:4px 0;}
		.review_text {font-size:14px;color:#333;}
		.rating_summary_cards {display:flex;gap:10px;margin-bottom:16px;}
		.detail-box { padding:auto 10px; margin:30px; }
		
		.wating_container { text-align:center; border: 1px solid #d0d0cd; padding:10px; border-radius:10px; }
		
		#googleMap { width: 100%; height: 300px; border-radius:10px; }
		.home_menu_container { display: flex; flex-direction: column; gap: 20px; padding:20px; margin: 0 auto; }
		.home_menu_card { display: flex; border-bottom: 1px solid #ccc; padding-bottom: 15px; }
		.home_menu_image img { width: 100px; height: 100px; object-fit: cover; border-radius: 8px; }
		.home_menu_info { margin-left: 15px; }
		.home_menu_name { font-size: 18px; font-weight: bold; margin: 5px 0; }
		.home_menu_price { font-size: 16px; color: #000; }
		.home_menu_description { color: #555; font-size: 14px; }
		.home_menu_badge { display: inline-block; font-size: 12px; padding: 2px 6px; border-radius: 4px; margin-bottom: 4px; font-weight: bold; color: white; }
		.home_menu_badge.red { background-color: red; }
		.home_menu_badge.orange { background-color: orange; }
		.home_menu_more_btn_wrap { text-align: center; margin-top: 20px; }
		.home_menu_more_btn { padding: 10px 20px; color: black; border: 1px solid black; border-radius: 6px; font-size: 16px; cursor: pointer; }

		/* 예약 UI 관련 CSS 추가 */
		.time-slot-btn {
            width: 130px;
            margin: 5px;
            font-size: 0.9em;
            white-space: nowrap;
        }
        .time-slot-btn.selected {
            background-color: #0d6efd;
            color: white;
        }
        .time-slot-btn.unavailable {
            background-color: #e9ecef;
            color: #6c757d;
            cursor: not-allowed;
            border-color: #e9ecef;
        }
        .time-slot-btn.selected {
            border-color: #0d6efd;
        }
		.table-select-area {
            display: none;
            padding: 10px;
            background-color: #f8f9fa;
            border-radius: 5px;
            margin-top: 10px;
        }
		.table-slot-btn {
            margin: 5px;
        }
        .table-slot-btn.selected {
            background-color: #198754;
            color: white;
        }
	</style>

	<script>
		let map;

	    function initMap() {
	        const geocoder = new google.maps.Geocoder();
	        const address = '<c:out value="${store.address}"/>';

	        if (!address) {
	        	console.log('address : ',address);
	            alert("주소 정보가 없습니다.");
	            return;
	        }

	        geocoder.geocode({ address: address }, function(results, status) {
	            if (status === 'OK') {
	                const location = results[0].geometry.location;
	                map = new google.maps.Map(document.getElementById("googleMap"), {
	                    center: location,
	                    zoom: 16
	                });
	                new google.maps.Marker({
	                    map: map,
	                    position: location
	                });
	            } else {
	                alert("지도를 불러올 수 없습니다: " + status);
	            }
	        });
	    }

		// 인원수 변경 함수
		function changeGuestCount(change) {
			let guestCountInput = $('#guestCount');
			let guestCountHiddenInput = $('#guestCountInput');
			let currentCount = parseInt(guestCountInput.val());
			let newCount = currentCount + change;

			if (newCount >= 1 && newCount <= 10) {
				guestCountInput.val(newCount);
				guestCountHiddenInput.val(newCount);
			}
		}

		document.addEventListener('DOMContentLoaded', function () {
			// JSP 변수인 contextPath를 JavaScript 변수로 저장
            var contextPath = '${contextPath}';
            var storeId = '${storeId}';

		    // 탭 클릭 시 지도 resize
		    $("ul.tabs li a").click(function () {
		        const activeTab = $(this).attr("href");
		        $(".tab_content").hide();
		        $(activeTab).fadeIn();
		        $("ul.tabs li").removeClass("active");
		        $(this).parent().addClass("active");

		        if (activeTab === "#tab4" && map) {
		            google.maps.event.trigger(map, "resize");
		        }
		        return false;
		    });

		    // 복사 기능 (주소)
		    document.getElementById('copyaddress').addEventListener('click', function () {
		        navigator.clipboard.writeText('${store.address}').then(function () {
		            alert("주소가 복사되었습니다.");
		        }).catch(function (err) {
		            alert("복사 실패: " + err);
		        });
		    });

		    // 공유 버튼 (URL)
		    document.getElementById('copyUrlBtn').addEventListener('click', function () {
		        navigator.clipboard.writeText(window.location.href).then(function () {
		            alert("주소가 복사되었습니다.");
		        }).catch(function (err) {
		            alert("복사 실패: " + err);
		        });
		    });

		    // 탭 초기 설정
		    $(".tab_content").hide();
		    $("ul.tabs li:first").addClass("active").show();
		    $(".tab_content:first").show();
		    
		    
			// jQuery UI Datepicker 초기화
			$("#reservationDate").datepicker({
				dateFormat: 'yy-mm-dd',
				minDate: 0, // 오늘 날짜부터 선택 가능
				onSelect: function(dateText, inst) {
					fetchAvailableSlots(dateText);
				}
			});

			// 페이지 로드 시 오늘 날짜의 예약 현황을 불러옴
			var today = new Date();
			// -- 수정된 부분: 날짜 형식을 올바르게 수정합니다.
			var todayFormatted = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);

			// 날짜 선택 필드에 오늘 날짜를 설정하고 이벤트를 트리거하여 예약 슬롯을 불러옴
			$("#reservationDate").val(todayFormatted);
			fetchAvailableSlots(todayFormatted);

			function fetchAvailableSlots(date) {
				if (!storeId) {
					console.error("storeId가 유효하지 않습니다.");
					return;
				}

				$.ajax({
					url: contextPath + '/reservation/customer/available-slots',
					type: 'GET',
					data: { storeId: storeId, date: date },
					success: function(data) {
						updateTimeSlots(data);
					},
					error: function(xhr, status, error) {
						console.error("Failed to fetch available slots: ", error);
						// -- 기존 알림을 수정하여 더 구체적인 안내를 제공합니다.
						if (xhr.status === 404) {
							alert("예약 정보를 불러오는 API를 찾을 수 없습니다.");
						} else {
							alert("예약 정보를 불러오는 데 실패했습니다. 다시 시도해주세요.");
						}
					}
				});
			}

			function updateTimeSlots(data) {
				var timeSlotsContainer = $('#time-slots-container');
				var tableSelectionContainer = $('#table-selection-container');
				timeSlotsContainer.empty();
				tableSelectionContainer.empty();

				// 모든 선택 상태 초기화
				$('#selectedReservationTime').val('');
				$('#selectedTableId').val('');
				$('#bookFormBtn').prop('disabled', true);

				if (data && Object.keys(data).length > 0) {
					$('#reservation-times-area').show();

					const now = new Date();
					const reservationDate = $('#reservationDate').val();
					const isToday = reservationDate === now.getFullYear() + '-' + ('0' + (now.getMonth() + 1)).slice(-2) + '-' + ('0' + now.getDate()).slice(-2);
					const currentTimestamp = now.getTime();

					$.each(data, function(time, tables) {
						const availableTablesCount = tables.length;
						let isUnavailable = false;

						if (availableTablesCount === 0) {
							isUnavailable = true;
						} else if (isToday) {
							const slotDateTime = new Date(reservationDate + 'T' + time + ':00');
							// -- 현재 시간의 분을 고려하여 마감 처리
							if (slotDateTime.getTime() < currentTimestamp) {
								isUnavailable = true;
							}
						}

						var timeButton = $('<button>')
							.attr('type', 'button')
							.attr('data-time', time);

						if (isUnavailable) {
							timeButton.addClass('btn time-slot-btn unavailable');
							timeButton.prop('disabled', true);
							timeButton.text(time + ' (마감)');
						} else {
							timeButton.addClass('btn btn-outline-secondary time-slot-btn');
							timeButton.text(time + ' (' + availableTablesCount + '석)');
						}
						timeSlotsContainer.append(timeButton);

						var tableArea = $('<div>')
							.addClass('table-select-area')
							.attr('id', 'table-area-' + time.replace(':', ''));

						if (tables && tables.length > 0) {
							$.each(tables, function(index, table) {
								var tableButton = $('<button>')
									.addClass('btn btn-outline-success table-slot-btn')
									.attr('type', 'button')
									.attr('data-table-id', table.tableId)
									.attr('data-time', time)
									.text(table.tableName + ' (' + table.capacity + '인석)');
								tableArea.append(tableButton);
							});
						} else {
							tableArea.html('<p class="text-muted">예약 가능한 테이블이 없습니다.</p>');
						}
						tableSelectionContainer.append(tableArea);
					});

				} else {
					$('#reservation-times-area').hide();
					alert("선택하신 날짜에는 예약 가능한 시간이 없습니다.");
				}
			}

			// 시간 슬롯 버튼 클릭 이벤트
			$('#time-slots-container').on('click', '.time-slot-btn:not(.unavailable)', function() {
				$('.time-slot-btn').removeClass('selected');
				$(this).addClass('selected');

				// 테이블 선택 영역 보이기
				$('#table-selection-area').show();
				$('.table-select-area').hide();
				var selectedTime = $(this).data('time').replace(':', '');
				$('#table-area-' + selectedTime).show();

				// 시간 선택 시 테이블 선택 및 폼 필드 초기화
				$('.table-slot-btn').removeClass('selected');
				$('#selectedReservationTime').val('');
				$('#selectedTableId').val('');
				$('#bookFormBtn').prop('disabled', true);
			});

			// 테이블 슬롯 버튼 클릭 이벤트
			$('#table-selection-container').on('click', '.table-slot-btn', function() {
				var selectedTime = $('.time-slot-btn.selected').data('time');
				if (!selectedTime) {
					alert('먼저 시간을 선택해주세요.');
					return;
				}

				$('.table-slot-btn').not(this).removeClass('selected');
				$(this).toggleClass('selected');

				var tableId = $(this).hasClass('selected') ? $(this).data('table-id') : '';

				$('#selectedTableId').val(tableId);

				var date = $('#reservationDate').val();
				var reservationDateTime = date + 'T' + selectedTime;
				$('#selectedReservationTime').val(reservationDateTime);

				// 시간과 테이블이 모두 선택되면 버튼 활성화
				if ($('#selectedReservationTime').val() && $('#selectedTableId').val()) {
					$('#bookFormBtn').prop('disabled', false);
				} else {
					$('#bookFormBtn').prop('disabled', true);
				}
			});

			// 폼 제출 시 유효성 검사
			$('#reservationForm').on('submit', function(e) {
				if (!$('#selectedReservationTime').val() || !$('#selectedTableId').val()) {
					e.preventDefault();
					alert('예약 날짜, 시간, 테이블을 모두 선택해주세요.');
				}
			});
		});

		function openTab2() { document.querySelector('ul.tabs li a[href="#tab2"]').click(); }
		function openTab3() { document.querySelector('ul.tabs li a[href="#tab3"]').click(); }
	</script>

<!-- 구글 맵 API -->
<script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB1kAhEMiW_-y5zg2uFTUeAOTG_uVO_kts&callback=initMap" ></script>

</head>

<body>

	<div class="store-info">
		<div id="carouselExampleAutoplaying" class="carousel slide" data-bs-ride="carousel"> <div class="carousel-inner">
				<div class="carousel-item active">
					<img src="https://cdn.pixabay.com/photo/2022/03/04/02/28/window-7046360_1280.jpg" class="d-block w-100" alt=${store.fileName }" height="400px">
				</div>
				<div class="carousel-item">
					<img src="https://cdn.pixabay.com/photo/2017/01/26/02/06/christmas-wallpaper-2009590_1280.jpg" alt="..." height="400px">
				</div>
				<div class="carousel-item">
					<img src="https://cdn.pixabay.com/photo/2016/04/21/12/52/restaurant-1343327_1280.jpg" class="d-block w-100" alt="..." height="400px">
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

		<div style="display: flex; justify-content: space-between; align-items: center;">
			<h4 class="mt-3">${store.storeName}</h4>
			<button class="btn btn-outline-secondary btn-sm mt-2" id="copyUrlBtn">공유</button>
		</div>
		<div class="rating"><img src="${contextPath}/image/review_rating.jpg" width="16" height="16" alt="리뷰이미지">${store.avgRating}&nbsp;&nbsp;&nbsp;리뷰 ${store.countRating}개 <button type="button" onClick="openTab3()" class="btn btn-link" style="text-decoration:none; color:black;"><strong>></strong></button></div>
		<div>
			<p><img src="${contextPath}/image/address_pin.jpg" width="16" height="16" alt="위치"> ${store.address} ${store.detailAddress } ${store.extraAddress }<button class="btn btn-link btn-sm mt-2" id="copyaddress">위치</button></p>
			<p><img src="${contextPath}/image/calling.png" width="16" height="16" alt="전화번호"> ${store.localNumber } - ${store.number1 } - ${store.number2 }</p>
		</div>
		<div>
			<p><img src="${contextPath}/image/openhour.png" width="16" height="16" alt="영업시간">
<%-- 			<c:choose> --%>
<%-- 				<c:when test="${res.isActive }"> --%>
<!-- 					<strong>영업중</strong> -->
<%-- 				</c:when> --%>
<%-- 				<c:otherwise> --%>
<!-- 					<strong>영업종료</strong> -->
<%-- 				</c:otherwise> --%>
<%-- 			</c:choose> --%>
			<strong>영업중</strong>${store.operatingTime} </p>
		</div>
		
		<div class="wating_container">
			<h4>현재 대기</h4>
			<h6><strong>3</strong>팀</h6>
			<button type="button" style="width:80%" class="btn btn-danger" onClick="location.href='${contextPath}/waiting/customer/register'">웨이팅하기</button>
		</div>
		<div class="tab_container">
			<div class="tab_container" id="container">
				<ul class="tabs">
					<li><a href="#tab1">홈</a></li>
					<li><a href="#tab2">메뉴</a></li>
					<li><a href="#tab3">리뷰</a></li>
					<li><a href="#tab4">매장정보</a></li>
				</ul>
				<div class="tab_container">
					<div class="tab_content" id="tab1">
						<h5 class="mt-4">예약</h5>
							<hr>
							<form action="${contextPath}/reservation/customer/bookForm" method="get" id="reservationForm">
								<input type="hidden" name="storeId" value="${storeId}" />
								<input type="hidden" name="reservationTime" id="selectedReservationTime" />
								<input type="hidden" name="tableId" id="selectedTableId" />
								<input type="hidden" name="guestCount" id="guestCountInput" value="1" />

								<div class="mb-3">
									<label for="reservationDate" class="form-label">예약 날짜:</label>
									<input type="text" class="form-control" id="reservationDate" placeholder="날짜를 선택하세요" required>
								</div>

								<div id="reservation-times-area" class="mb-3" style="display: none;">
									<label class="form-label">예약 시간대:</label>
									<div id="time-slots-container" class="d-flex flex-wrap"></div>
								</div>

								<div id="table-selection-area" class="mb-3" style="display: none;">
									<label class="form-label">테이블 선택:</label>
									<div id="table-selection-container" class="d-flex flex-wrap"></div>
								</div>

								<div class="mb-3 mt-4">
									<label class="form-label">예약 인원:</label>
									<div>
										<button type="button" class="btn btn-outline-secondary" onclick="changeGuestCount(-1)">-</button>
										<input type="text" id="guestCount" value="1" readonly style="width: 50px; text-align: center;">
										<button type="button" class="btn btn-outline-secondary" onclick="changeGuestCount(1)">+</button>
									</div>
								</div>

								<button type="submit" class="btn btn-primary mt-3" id="bookFormBtn" disabled>예약 폼으로 이동</button>
							</form>
						<div class="button-group mt-5">
							<a href="<c:url value='/reservation/owner/manageList?storeId=${store.storeId}'/>">점주 관리 페이지</a>
						</div>
						<div class="back-link">
							<a href="<c:url value='${contextPath }/store/storeList'/>">매장 목록으로 돌아가기</a>
						</div>

						<div class="home_menu_container">
							<c:forEach var="menu" items="${storeMap.menu}" varStatus="status">
								<c:if test="${status.index < 5}">
									<div class="home_menu_card">
										<div class="home_menu_image">
											<img src="${menu.fileName}" alt="${menu.menuName}">
										</div>
										<div class="home_menu_info">
											<p class="home_menu_name">${menu.menuName}</p>
											<p class="home_menu_price">${menu.price}원</p>
											<p class="home_menu_description">${menu.description}</p>
										</div>
									</div>
								</c:if>
							</c:forEach>
							<div class="home_menu_more_btn_wrap">
								<button class="home_menu_more_btn" onclick="openTab2()">메뉴 전체 보기</button>
							</div>
						</div>
					</div>
					<div class="tab_content" id="tab2"> <div class="menu_container">
							<c:forEach var="menu" items="${storeMap.menu}">
								<div class="menu_card">
									<div class="menu_image">
										<img src="${menu.fileName}" alt="${menu.menuName}" width="100px">
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
								<h7>${store.countRating }개 리뷰 별점 평균</h7>
								<h2><img src="${contextPath}/image/review_rating.jpg" width="40" alt="리뷰이미지">${store.avgRating }</h2>
							</div>
							<div class="card card-detail">
								<c:forEach var="detailReview" items="${storeMap.detailReview}">
									<div class="rating_bar_container">
										<span class="rating_label">${detailReview.rating}점 ${detailReview.countScoreRating}</span>
										<div class="rating_bar_bg">
											<div class="rating_bar_fill" style="width:20px;"></div>
										</div>
									</div>
								</c:forEach>
							</div>
						</div>
						<div class="detailReviewList">
							<h4>리뷰 ${store.countRating}건</h4>
							<c:forEach var="review" items="${storeMap.review }" >
								<div class="review_box">
									<p>${review.rating }점<br>
									${review.writerId}<br>
									${review.content}
								</div>
							</c:forEach>
						</div>
					</div>
					<div class="tab_content" id="tab4">
						<div class="detail-box">
							<h4>매장소개</h4>
							<p>${store.description }
						</div>
						<div class="detail-box">
							<h4>편의시설</h4>
							<p>${store.amenities }
						</div>
						<div class="detail-box">
							<h4>위치</h4>
							<div id="googleMap"></div>
							<p ><img src="${contextPath}/image/location.png" width="10" height="10" alt="위치">${store.address } <button class="btn btn-outline-secondary btn-sm" id="copyaddress">복사</button> </p>
						</div>
						<div class="detail-box">
							<h4>상세정보</h4>
							<div>
								<p><strong>영업시간</strong></p>
								<p>${store.operatingTime }
							</div>
							<div>
								<P><strong>브레이크 타임</strong></P>
								<p>${store.breakTime }</p>
							</div>
							<div>
								<P><strong>라스트 오더</strong></P>
								<p>${store.lastOrder }</p>
							</div>
							<div>
								<P><strong>정기휴무</strong></P>
								<p>${store.closed }</p>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>