<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="store" value="${storeMap.store}" />
<c:set var="detailReview" value="${storeMap.detailReview}" />
<c:set var="storeId" value="${store.storeId}" />

<html>
<head>
	<title>${store.storeName}</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
	<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">

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
		.review_box {border:1px solid #ddd;padding:12px;border-radius:6px;margin-bottom:10px;background-color:#fff; pont-size:10px; }
		.review_stars {color:#f90; font-size:14px; }
		.review_user {font-weight:bold;font-size:13px;margin:4px 0; }
		.review_text {font-size:14px;color:#333; }
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
		.carousel-item.active {display: flex; justify-content: center; align-items: center; }

		/* ----------------------- 예약 UI 관련 CSS ----------------------- */
		.reservation-or-waiting-select {
			display: flex;
			gap: 10px;
			margin-bottom: 20px;
		}
		.reservation-or-waiting-select button {
			flex: 1;
			padding: 10px;
			border: 1px solid #ccc;
			border-radius: 5px;
			background-color: #f8f9fa;
			cursor: pointer;
		}
		.reservation-or-waiting-select button.active {
			background-color: #0d6efd;
			color: white;
			border-color: #0d6efd;
		}
		#reservationForm, #waitingForm {
			display: none;
		}
		.time-slot-btn, .table-slot-btn {
			width: 100%;
			margin: 5px 0;
			font-size: 0.9em;
			white-space: nowrap;
		}
		/* 호버 효과 추가 */
		.time-slot-btn:hover, .table-slot-btn:hover {
			border-color: #0d6efd;
			transform: translateY(-2px);
			transition: all 0.2s ease-in-out;
		}
		.time-slot-btn.selected {
			background-color: #0d6efd;
			color: white;
		}
		.table-slot-btn.selected {
			background-color: #198754;
			color: white;
		}
		.time-slot-btn.unavailable {
			background-color: #e9ecef;
			color: #6c757d;
			cursor: not-allowed;
			border-color: #e9ecef;
			text-decoration: line-through;
		}
		.table-select-column {
            display: none;
            padding: 10px;
            background-color: #f8f9fa;
            border-radius: 5px;
            margin-top: 10px;
        }
		/* 시간 슬롯 그리드 레이아웃 */
		#time-slots-container {
			display: grid;
			grid-template-columns: repeat(2, 1fr);
			gap: 10px;
		}
		.side-by-side-container {
			display: flex;
			flex-wrap: wrap;
			gap: 20px;
		}
		.time-slot-column, .table-select-column {
			flex: 1;
		}
		.table-select-column {
			 padding: 10px;
			 background-color: #f8f9fa;
			 border-radius: 5px;
		}
		input[type="number"]::-webkit-outer-spin-button,
		input[type="number"]::-webkit-inner-spin-button {
		    -webkit-appearance: none;
		    margin: 0;
		}
	</style>
</head>

<body>

	<div class="store-info">
		<div id="carouselExampleAutoplaying" class="carousel slide" data-bs-ride="carousel">
			<div class="carousel-inner">
				<div class="carousel-item active">
					<img src="${contextPath }/download?directoryName=store&fileName=${store.fileName}" class="d-block w-100" alt="${store.fileName }" height="400px">
				</div>
				<c:forEach var="storeImage" items="${storeMap.storeImage}" varStatus="status">
					<div class="carousel-item">
						<img src="${contextPath }/download?directoryName=store&fileName=${storeImage.fileName}" alt="${storeImage.fileName }" height="400px">
					</div>
				</c:forEach>
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
			<p><img src="${contextPath}/image/address_pin.jpg" width="16" height="16" alt="위치"> ${store.address} ${store.detailAddress } ${store.extraAddress }<button class="btn btn-link btn-sm" id="copyaddress">위치</button></p>
			<p><img src="${contextPath}/image/calling.png" width="16" height="16" alt="전화번호"> ${store.localNumber } - ${store.number1 } - ${store.number2 }</p>
		</div>
		<div>
			<p><img src="${contextPath}/image/openhour.png" width="16" height="16" alt="영업시간">
			<strong>영업중</strong>${store.operatingTime} </p>
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
						<h5 class="mt-4">예약/웨이팅</h5>
						<hr>
						<div class="reservation-or-waiting-select">
							<button type="button" id="showReservationFormBtn">예약</button>
							<button type="button" id="showWaitingFormBtn">웨이팅</button>
						</div>

						<form action="${contextPath}/reservation/customer/bookForm" method="get" id="reservationForm">
							<input type="hidden" name="storeId" value="${storeId}" />
							<input type="hidden" name="reservationTime" id="selectedReservationTime" />
							<input type="hidden" name="tableIds" id="selectedTableIds" />

							<div class="mb-3">
								<label for="guestCount" class="form-label">예약 인원:</label>
								<div class="input-group">
									<button type="button" class="btn btn-outline-secondary" id="decrementGuestCount">-</button>
									<input type="number" class="form-control text-center" id="guestCount" name="guestCount" value="1" min="1" max="10">
									<button type="button" class="btn btn-outline-secondary" id="incrementGuestCount">+</button>
								</div>
								<small class="form-text text-muted">최소 1명, 최대 10명까지 예약 가능합니다.</small>
							</div>

							<div class="mb-3">
								<label for="reservationDate" class="form-label">예약 날짜:</label>
								<input type="text" class="form-control" id="reservationDate" placeholder="날짜를 선택하세요" required>
							</div>

							<div class="side-by-side-container">
								<div class="time-slot-column" id="reservation-times-area" style="display: none;">
									<label class="form-label">예약 시간대:</label>
									<div id="time-slots-container"></div>
								</div>
								<div class="table-select-column" id="table-selection-area">
									<p class="text-muted">시간을 선택하면 예약 가능한 테이블 목록이 표시됩니다.</p>
									<div id="table-selection-container"></div>
									<p id="selected-capacity-info" class="mt-2 text-primary" style="display:none;"></p>
								</div>
							</div>

							<button type="submit" class="btn btn-primary mt-3" id="bookFormBtn" disabled>예약 폼으로 이동</button>
						</form>

						<form id="waitingForm" action="${contextPath}/waiting/customer/form" method="get" style="display: none;">
							<div class="wating_container">
								<h4>현재 대기</h4>
								<h6><strong>${currentWaitingCount}</strong>팀</h6>
								<input type="hidden" name="storeId" value="${storeId}" />
								<button type="submit" style="width:80%" class="btn btn-danger">웨이팅하기</button>
							</div>
						</form>

						<div class="home_menu_container">
							<c:forEach var="menu" items="${storeMap.menu}" varStatus="status">
								<c:if test="${status.index < 5}">
									<div class="home_menu_card">
										<div class="home_menu_image">
											<img src="${contextPath }/download?directoryName=menu&fileName=${menu.fileName}" alt="${menu.menuName}">
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
						<div class="button-group mt-5">
							<a href="<c:url value='/reservation/owner/manageList?storeId=${store.storeId}'/>">점주 관리 페이지</a>
						</div>
						<div class="back-link">
							<a href="<c:url value='${contextPath }/store/storeList'/>">매장 목록으로 돌아가기</a>
						</div>
					</div>
					<div class="tab_content" id="tab2"> <div class="menu_container">
							<c:forEach var="menu" items="${storeMap.menu}">
								<div class="menu_card">
									<div class="menu_image">
										<img src="${contextPath }/download?directoryName=menu&fileName=${menu.fileName}" alt="${menu.menuName}" width="100px">
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
										<div class="rating_bar_fill" style="width:20px;"></div>
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

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB1kAhEMiW_-y5zg2uFTUeAOTG_uVO_kts&callback=initMap" ></script>

<script>
	let map;
    function initMap() {
        const geocoder = new google.maps.Geocoder();
        const address = '<c:out value="${store.address}"/>';

        if (!address) {
            console.error('주소 정보가 없습니다.');
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
                console.error("지도를 불러올 수 없습니다: " + status);
            }
        });
    }

	function openTab2() { document.querySelector('ul.tabs li a[href="#tab2"]').click(); }
	function openTab3() { document.querySelector('ul.tabs li a[href="#tab3"]').click(); }

	$(function () {
		const contextPath = '${contextPath}';
		const storeId = '${storeId}';

		// 예약 폼 관련 상태 변수
		let availableSlotsData = {};

		// 예약/웨이팅 버튼 클릭 이벤트
		$('#showReservationFormBtn').on('click', function() {
			$('#waitingForm').hide();
			$('#reservationForm').show();
			$('#showWaitingFormBtn').removeClass('active');
			$(this).addClass('active');
			initializeReservationForm();
		});

		$('#showWaitingFormBtn').on('click', function() {
			$('#reservationForm').hide();
			$('#waitingForm').show();
			$('#showReservationFormBtn').removeClass('active');
			$(this).addClass('active');
		});

		$('#reservationForm').show();
		$('#showReservationFormBtn').addClass('active');

		// 인원수 변경
		$('#guestCount').on('change', function() {
			let count = parseInt($(this).val());
			if (isNaN(count) || count < 1) {
				$(this).val(1);
			} else if (count > 10) {
				$(this).val(10);
			}
			updateGuestCountInfo();
            // 인원수 변경 시 시간 슬롯 재로딩
            const selectedDate = $('#reservationDate').val();
            if (selectedDate) {
                fetchAvailableSlots(selectedDate);
            }
		});
		$('#decrementGuestCount').on('click', function() {
			let guestCount = parseInt($('#guestCount').val());
			if (guestCount > 1) {
				$('#guestCount').val(guestCount - 1).trigger('change');
			}
		});
		$('#incrementGuestCount').on('click', function() {
			let guestCount = parseInt($('#guestCount').val());
			if (guestCount < 10) {
				$('#guestCount').val(guestCount + 1).trigger('change');
			}
		});

		// 예약 인원 정보 업데이트
        function updateGuestCountInfo() {
            const selectedCapacity = updateSelectedCapacity();
            const guestCount = parseInt($('#guestCount').val(), 10) || 0;
            const capacityInfoText = `테이블 좌석: ${selectedCapacity}명 / 예약 인원: ${guestCount}명`;

            if ($('#table-selection-area').is(':visible') && selectedCapacity > 0) {
                $('#selected-capacity-info').text(capacityInfoText).show();
            } else {
                $('#selected-capacity-info').hide();
            }
            checkFormValidity();
        }

		// jQuery UI Datepicker 초기화
		$("#reservationDate").datepicker({
			dateFormat: 'yy-mm-dd',
			minDate: 0,
			onSelect: function(dateText, inst) {
				fetchAvailableSlots(dateText);
			}
		});

		// 페이지 로드 시 오늘 날짜의 예약 현황을 불러옴
		function initializeReservationForm() {
			const today = new Date();
			const todayFormatted = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
			$("#reservationDate").val(todayFormatted);
			fetchAvailableSlots(todayFormatted);
		}

		initializeReservationForm();

		function fetchAvailableSlots(date) {
			if (!storeId) {
				console.error("storeId가 유효하지 않습니다.");
				return;
			}
			// 로딩 상태 표시
			$('#time-slots-container').html('<p class="text-muted">예약 시간대를 불러오는 중입니다...</p>');
			$('#reservation-times-area').show();
			$('#table-selection-area').hide();

			$.ajax({
				url: contextPath + '/reservation/customer/available-slots',
				type: 'GET',
				data: { storeId: storeId, date: date },
				success: function(data) {
					availableSlotsData = data;
					updateTimeSlots(data);
				},
				error: function(xhr, status, error) {
					console.error("Failed to fetch available slots: ", error);
					$('#reservation-times-area').html('<p class="text-danger">예약 정보를 불러오는 데 실패했습니다. 다시 시도해주세요.</p>');
					$('#table-selection-area').hide();
					$('#bookFormBtn').prop('disabled', true);
				}
			});
		}

		function updateTimeSlots(data) {
			const timeSlotsContainer = $('#time-slots-container');
			timeSlotsContainer.empty();
			// 테이블 선택 영역을 초기화하고 숨김
			$('#table-selection-area').hide().find('#table-selection-container').empty();
			$('#table-selection-area').find('p.text-muted').show();

			$('#selectedReservationTime').val('');
			$('#selectedTableIds').val('');
			$('#bookFormBtn').prop('disabled', true);
			updateGuestCountInfo();

            const guestCount = parseInt($('#guestCount').val(), 10) || 1;

			if (data && Object.keys(data).length > 0) {
				$('#reservation-times-area').show();
				const now = new Date();
				const reservationDate = $('#reservationDate').val();
				const isToday = reservationDate === now.getFullYear() + '-' + ('0' + (now.getMonth() + 1)).slice(-2) + '-' + ('0' + now.getDate()).slice(-2);
				const currentTimestamp = now.getTime();

				$.each(data, function(time, tables) {
					const totalCapacity = tables.reduce((sum, table) => sum + table.capacity, 0);
					let isUnavailable = false;
					let unavailableReason = '';

                    // 인원수 기준으로 예약 가능 여부 판단
                    if (totalCapacity < guestCount) {
                        isUnavailable = true;
                        unavailableReason = '예약 불가';
                    }

					if (!isUnavailable && isToday) {
						const slotDateTime = new Date(reservationDate + 'T' + time + ':00');
						if (slotDateTime.getTime() < currentTimestamp) {
							isUnavailable = true;
							unavailableReason = '마감';
						}
					}

					const timeButton = $('<button>')
						.attr('type', 'button')
						.addClass('btn time-slot-btn')
						.attr('data-time', time);

					if (isUnavailable) {
						timeButton.addClass('btn-outline-secondary unavailable');
						timeButton.prop('disabled', true);
						timeButton.text(time + ' (' + unavailableReason + ')');
					} else {
						timeButton.addClass('btn-outline-secondary');
						timeButton.text(time + ' (최대 ' + totalCapacity + '인)');
					}
					timeSlotsContainer.append(timeButton);
				});

			} else {
				$('#reservation-times-area').html('<p class="text-muted">선택하신 날짜에는 예약 가능한 시간이 없습니다.</p>').show();
				$('#table-selection-area').hide();
			}
		}

		// 시간 슬롯 버튼 클릭 이벤트
		$('#time-slots-container').on('click', '.time-slot-btn:not(.unavailable)', function() {
			$('.time-slot-btn').removeClass('selected');
			$('.table-slot-btn').removeClass('selected');
			$('#selectedTableIds').val('');

			$(this).addClass('selected');

			const selectedTime = $(this).data('time');
			const date = $('#reservationDate').val();
			const reservationDateTime = date + 'T' + selectedTime;
			$('#selectedReservationTime').val(reservationDateTime);

			displayTablesForTime(selectedTime);
		});

		function displayTablesForTime(selectedTime) {
			const tableSelectionContainer = $('#table-selection-container');
			tableSelectionContainer.empty();

			if (!availableSlotsData || !availableSlotsData[selectedTime]) {
				tableSelectionContainer.html('<p class="text-muted">예약 가능한 테이블 정보를 불러오는 중입니다. 잠시 후 다시 시도해주세요.</p>');
				return;
			}

			const tables = availableSlotsData[selectedTime];

			if (tables && tables.length > 0) {
				$('#table-selection-area').find('p.text-muted').hide();
				$.each(tables, function(index, table) {
					var buttonText = '테이블 ' + table.tableId + ' (최대 ' + table.capacity + '인)';
					if (table.tableInfo) {
						buttonText = table.tableInfo + ' (최대 ' + table.capacity + '인)';
					}
					const tableButton = $('<button>')
						.addClass('btn btn-outline-success table-slot-btn')
						.attr('type', 'button')
						.attr('data-table-id', table.tableId)
						.attr('data-capacity', table.capacity)
						.text(buttonText);
					tableSelectionContainer.append(tableButton);
				});
				tableSelectionContainer.append('<p id="selected-capacity-info" class="mt-2 text-primary"></p>');
				$('#table-selection-area').show();
			} else {
				tableSelectionContainer.html('<p class="text-muted">예약 가능한 테이블이 없습니다.</p>');
				$('#table-selection-area').show();
			}
			updateGuestCountInfo();
		}

		// 테이블 슬롯 버튼 클릭 이벤트 (중복 선택 가능)
		$('#table-selection-container').on('click', '.table-slot-btn', function() {
			$(this).toggleClass('selected');

			const selectedTableIds = $('.table-slot-btn.selected').map(function() {
				return $(this).data('table-id');
			}).get().join(',');
			$('#selectedTableIds').val(selectedTableIds);

			updateGuestCountInfo();
		});

		function updateSelectedCapacity() {
			let totalCapacity = 0;
			$('.table-slot-btn.selected').each(function() {
				totalCapacity += parseInt($(this).data('capacity'), 10);
			});
			return totalCapacity;
		}

		function checkFormValidity() {
			const selectedTime = $('#selectedReservationTime').val();
			const selectedTableIds = $('#selectedTableIds').val();
			const guestCount = parseInt($('#guestCount').val(), 10);
			const totalCapacity = updateSelectedCapacity();

			if (selectedTime && selectedTableIds && totalCapacity >= guestCount) {
				$('#bookFormBtn').prop('disabled', false);
			} else {
				$('#bookFormBtn').prop('disabled', true);
			}
		}

		// 폼 제출 시 유효성 검사
		$('#reservationForm').on('submit', function(e) {
			const guestCount = parseInt($('#guestCount').val(), 10);
			const totalCapacity = updateSelectedCapacity();

			if (!totalCapacity || totalCapacity < guestCount) {
				e.preventDefault();
				alert('선택한 테이블의 총 인원수가 예약 인원보다 적습니다. 테이블을 더 추가해주세요.');
			}
		});

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
	});
</script>