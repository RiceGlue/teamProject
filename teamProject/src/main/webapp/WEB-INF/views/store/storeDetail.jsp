<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
<!-- 구글 맵 API -->
<script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB1kAhEMiW_-y5zg2uFTUeAOTG_uVO_kts&callback=initMap" ></script>

<c:set var="memberId" value="${memberId}" />
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="store" value="${storeMap.store}" />
<c:set var="detailReview" value="${storeMap.detailReview}" />
<c:set var="reviewImage" value="${storeMap.reviewImage}" />
<c:set var="storeId" value="${store.storeId}" />

<%-- <c:set var="res" value="${storeMap.reservation}" /> --%>

<title>${store.storeName}</title>
<!-- 💡 하트 아이콘을 위해 Font Awesome 추가. 기존 script 태그들 아래에 추가하세요. -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
	.review_box {border:1px solid #ddd;padding:12px;border-radius:6px;margin-bottom:10px;background-color:#fff; font-size:10px; }
	.review_stars {color:#f90;font-size:14px;}
	.review_user {font-weight:bold;font-size:13px;margin:4px 0;}
	.review_text {font-size:14px;color:#333;}
	.rating_summary_cards {display:flex;gap:10px;margin-bottom:16px;}
	.review-image-thumbnail {object-fit: cover; border-radius: 4px; border: 1px solid #ccc; }

	.detail-review-list { margin-top: 20px; }
	.review-box { border-bottom: 1px solid #d7cece; padding: 10px 5px; }
	.review-rating { margin-bottom: 5px; }
	.star { font-size: 18px; color: #ddd; }
	.star.filled { color: orange; }
	.review-meta { margin-bottom: 10px; }
	.review-writer { font-weight: bold; margin-bottom: 3px; color:#bdc0bd; }
	.review-content { color: #333; line-height: 1.5; }
	.review-images { display: flex; flex-wrap: wrap; gap: 8px; }
	.review-image { width: 70px; height: 70px; object-fit: cover; border-radius: 4px; }

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

	.carousel-item.active {display: flex; justify-content: center; align-items: }

	/* 예약 UI 관련 CSS 추가 */
	.time-slot-btn { width: 130px; margin: 5px; font-size: 0.9em; white-space: nowrap; }
	.time-slot-btn.selected { background-color: #0d6efd; color: white; border-color: #0d6efd; }
	.time-slot-btn.unavailable { background-color: #e9ecef; color: #6c757d; cursor: not-allowed; border-color: #e9ecef; }
	.table-select-area { display: none; padding: 10px; background-color: #f8f9fa; border-radius: 5px; margin-top: 10px; }
	.table-slot-btn { margin: 5px; }
	.table-slot-btn.selected { background-color: #198754; color: white; }

	/* 💡 위시리스트 버튼 CSS 추가 */
    .wishlist-btn {
        background: none;
        border: none;
        cursor: pointer;
        font-size: 24px;
        color: #ccc; /* 기본 회색 */
        transition: color 0.3s ease;
    }
    .wishlist-btn.active {
        color: #ff6347; /* 찜했을 때 빨간색 */
    }
</style>

<script>
let map;
const memberId = "${memberId}";
const storeId = ${storeId};

//💡 위시리스트 상태를 확인하는 AJAX 요청
function checkWishlistStatus() {
	if (!memberId || memberId === 'null' || memberId === 'undefined') return;
    $.ajax({
        url: '${contextPath}/wishlist/isWishlisted',
        type: 'GET',
        data: {
            memberId: memberId,
            storeId: storeId
        },
        success: function(response) {
            if (response === true) {
                $('#wishlist-btn').addClass('active');
            } else {
                $('#wishlist-btn').removeClass('active');
            }
        },
        error: function(error) {
            console.error('Error checking wishlist status:', error);
        }
    });
}

// 💡 위시리스트 추가/제거를 토글하는 AJAX 요청
function toggleWishlist() {
    if (!memberId || memberId === 'null' || memberId === 'undefined') {
        alert('로그인 후 이용해주세요.');
        return;
    }

    const isWishlisted = $('#wishlist-btn').hasClass('active');

    // 💡 이미 위시리스트에 추가된 경우 삭제 여부를 묻는 로직 추가
    if (isWishlisted) {
        // '확인'을 누르면 true, '취소'를 누르면 false 반환
        if (confirm("위시리스트에 이미 추가되었습니다. 삭제하시겠습니까?")) {
            $.ajax({
                url: '${contextPath}/wishlist/remove',
                type: 'DELETE',
                data: {
                    memberId: memberId,
                    storeId: storeId
                },
                success: function(response) {
                    alert(response);
                    checkWishlistStatus(); // UI 업데이트
                },
                error: function(xhr) {
                    const errorMessage = xhr.responseText || "오류가 발생했습니다.";
                    alert(errorMessage);
                    checkWishlistStatus(); // UI 업데이트
                }
            });
        }
    } else {
        // 💡 위시리스트에 없는 경우 추가하는 로직
        $.ajax({
            url: '${contextPath}/wishlist/add',
            type: 'POST',
            data: {
                memberId: memberId,
                storeId: storeId
            },
            success: function(response) {
                alert(response);
                checkWishlistStatus(); // UI 업데이트
            },
            error: function(xhr) {
                const errorMessage = xhr.responseText || "오류가 발생했습니다.";
                alert(errorMessage);
                checkWishlistStatus(); // UI 업데이트
            }
        });
    }
}


function initMap() {
	const geocoder = new google.maps.Geocoder();
	const address = '<c:out value="${store.address}"/>';
	if (!address) {
		console.log('address : ',address);
		alert("주소 정보가 없습니다.");
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
			alert("지도를 불러올 수 없습니다: " + status);
			console.error("지도를 불러올 수 없습니다: " + status);
		}
	});
}

function changeGuestCount(change) {
	let guestCountInput = $('#guestCount');
	let newCount = parseInt(guestCountInput.val()) + change;
	if (newCount >= 1 && newCount <= 10) {
		guestCountInput.val(newCount);
	}
}

function openTab2() { document.querySelector('ul.tabs li a[href="#tab2"]').click(); }
function openTab3() { document.querySelector('ul.tabs li a[href="#tab3"]').click(); }

$(function () {

	// 💡 페이지 로드 시 위시리스트 상태 확인. 기존 $(function() {}) 내부에 추가하세요.
	checkWishlistStatus();

	// 💡 위시리스트 버튼 클릭 이벤트
    $('#wishlist-btn').on('click', function() {
        toggleWishlist();
    });

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

	document.getElementById('copyaddress').addEventListener('click', function () {
		navigator.clipboard.writeText('${store.address}').then(function () {
			alert("주소가 복사되었습니다.");
		}).catch(function (err) {
			alert("복사 실패: " + err);
		});
	});

	document.getElementById('copyUrlBtn').addEventListener('click', function () {
		navigator.clipboard.writeText(window.location.href).then(function () {
			alert("주소가 복사되었습니다.");
		}).catch(function (err) {
			alert("복사 실패: " + err);
		});
	});

	$(".tab_content").hide();
	$("ul.tabs li:first").addClass("active").show();
	$(".tab_content:first").show();
	$("#reservationDate").datepicker({
		dateFormat: 'yy-mm-dd',
		minDate: 0,
		onSelect: function() {
			$('#bookFormBtn').prop('disabled', false);
		}
	});

	const today = new Date();
	const todayFormatted = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
	$("#reservationDate").val(todayFormatted);
	$('#bookFormBtn').prop('disabled', false);
});
</script>


<div class="store-info">
	<div class="store-info d-flex" style="gap: 20px;">
		<div class="carousel-container" style="flex: 1;">
			<div id="carouselExampleAutoplaying" class="carousel slide" data-bs-ride="carousel">
				<div class="carousel-inner">
					<div class="carousel-item active">
						<img src="${contextPath }/download?directoryName=store&fileName=${store.fileName}" class="d-block w-100" alt="${store.fileName}" height="400px">
					</div>
					<c:forEach var="storeImage" items="${storeMap.storeImage}" varStatus="status">
						<div class="carousel-item">
							<img src="${contextPath }/download?directoryName=store&fileName=${storeImage.fileName}" alt="${storeImage.fileName}" height="400px">
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
		</div>

		<div class="store-details" style="flex: 1;">
			<div style="display: flex; justify-content: space-between; align-items: center;">
				<h4 class="mt-3">${store.storeName}</h4>
				<button class="wishlist-btn" id="wishlist-btn" aria-label="위시리스트 추가/제거"><i class="fa fa-heart"></i></button>
				<button class="btn btn-outline-secondary btn-sm mt-2" id="copyUrlBtn">공유</button>
			</div>
			<div class="rating mt-2 mb-2">
				<img src="${contextPath}/image/review_rating.jpg" width="16" height="16" alt="리뷰이미지"> ${store.avgRating}&nbsp;&nbsp;&nbsp;리뷰 ${store.countRating}개
				<button type="button" onClick="openTab3()" class="btn btn-link" style="text-decoration:none; color:black;"><strong>></strong></button>
			</div>

			<div>
				<p>
					<img src="${contextPath}/image/address_pin.jpg" width="16" height="16" alt="위치"> ${store.address} ${store.detailAddress} ${store.extraAddress}
					<button class="btn btn-link btn-sm" id="copyaddress">위치</button>
				</p>
				<p><img src="${contextPath}/image/calling.png" width="16" height="16" alt="전화번호"> ${store.localNumber} - ${store.number1} - ${store.number2}</p>
			</div>
			<div>
				<p><img src="${contextPath}/image/openhour.png" width="16" height="16" alt="영업시간"><strong>영업중</strong> ${store.operatingTime}</p>
			</div>
		</div>
	</div>

	<div class="wating_container">
		<h4>현재 대기</h4>
		<h6><strong>${currentWaitingCount}</strong>팀</h6>
		<button type="button" style="width:80%" class="btn btn-danger" onClick="window.location.href='${contextPath}/waiting/customer/form?storeId=${storeId}'">웨이팅하기</button>
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
						<div class="mb-3">
							<label for="reservationDate" class="form-label">예약 날짜:</label>
							<input type="text" class="form-control" id="reservationDate" name="reservationDate" placeholder="날짜를 선택하세요" required>
						</div>
						<div class="mb-3 mt-4">
							<label class="form-label">예약 인원:</label>
							<div>
								<button type="button" class="btn btn-outline-secondary" onclick="changeGuestCount(-1)">-</button>
								<input type="text" id="guestCount" name="guestCount" value="1" readonly style="width: 50px; text-align: center;">
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
					<h5 class="mt-4">메뉴</h5>
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
					<h5 class="mt-4">리뷰</h5>
				</div>

				<div class="tab_content" id="tab2">
					<div class="menu_container">
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
					<h5 class="mt-4">리뷰</h5>
					<div class="rating_summary_cards">
						<div class="card card-rating">
							<h7>${store.countRating }개 리뷰 별점 평균</h7>
							<h2><img src="${contextPath}/image/review_rating.jpg" width="40" alt="리뷰이미지">${store.avgRating }</h2>
						</div>
						<div class="card card-detail">
							<c:forEach var="detailReview" items="${storeMap.detailReview}">
								<div class="rating_bar_container">
									<span class="rating_label">${detailReview.rating}점 ${detailReview.countScoreRating}명</span>
									<div class="rating_bar_fill" style="width: calc(${detailReview.countScoreRating * 100 / store.countRating}%);"></div>
								</div>
							</c:forEach>
							<c:forEach var="detailReview" items="${storeMap.detailReview}">
								<div class="rating_bar_container">
									<span class="rating_label">${detailReview.rating}점 ${detailReview.countScoreRating}명</span>
									<div class="rating_bar_fill" style="width: calc(${detailReview.countScoreRating * 100 / store.countRating}%);"></div>
								</div>
							</c:forEach>
						</div>

					</div>
					<div class="detail-review-list">
						<h4>리뷰 ${store.countRating}건</h4>
						<c:forEach var="review" items="${storeMap.review}">
							<div class="review-box">
								<div class="review-rating">
									<c:forEach begin="1" end="5" var="i">
										<c:choose>
											<c:when test="${i <= review.rating}">
												<span class="star filled">★</span>
											</c:when>
											<c:otherwise>
												<span class="star">★</span>
											</c:otherwise>
										</c:choose>
									</c:forEach>
								</div>
								<div class="review-meta">
									<div class="review-writer">
										<c:set var="idLength" value="${fn:length(review.writerId)}" />
										<c:set var="visiblePart" value="${fn:substring(review.writerId, 0, 2)}" />
										<c:set var="maskedPart" value="${fn:substring(review.writerId, 2, idLength)}" />
										${visiblePart}<c:forEach begin="1" end="${fn:length(maskedPart)}">*</c:forEach>
									</div>
									<div class="review-content">${review.content}</div>
								</div>

								<c:forEach var="img" items="${storeMap.reviewImage}">
									<c:if test="${img.reviewId == review.reviewId}">
										<c:if test="${img_status.first}"><div class="review-images"></c:if>
										<img src="${contextPath}/download?fileName=${img.fileName}&directoryName=review" alt="리뷰 이미지" class="review-image">
										<c:if test="${img_status.last}"></c:if>
									</c:if>
								</c:forEach>
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

</html>
