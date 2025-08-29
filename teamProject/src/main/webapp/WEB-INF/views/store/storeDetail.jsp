<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script> -->
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
<!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script> -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">

<!-- 구글 맵 API -->
<script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB1kAhEMiW_-y5zg2uFTUeAOTG_uVO_kts&callback=initMap" ></script>


<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="store" value="${storeMap.store}" />
<c:set var="detailReview2" value="${storeMap.detailReview2}" />
<c:set var="storeId" value="${store.storeId}" />

<%-- <c:set var="res" value="${storeMap.reservation}" /> --%>

<title>${store.storeName}</title>

<style>
/* 기본 CSS 스타일 */
p{display:flex;align-items:center;gap:7px;}
input[type="text"]:not(.form-control){width:50px;text-align:center;}
.store-info{margin:20px auto;max-width:950px;background:#fff;padding:20px;border-radius:10px;}
.store-banner{width:100%;height:200px;background-color:#eee;display:flex;justify-content:center;align-items:center;}

/* 웨이팅 섹션 스타일 */
.waiting-container{text-align:center;border:1px solid #e0e0e0;padding:15px;border-radius:10px;margin-top:20px;background-color:#fafafa;}
.waiting-container h4{margin-bottom:5px;font-size:1.25rem;}
.waiting-container h6{margin-bottom:15px;font-size:1.5rem;font-weight:bold;color:#dc3545;}
.waiting-container .btn{width:80%;}

/* 탭 메뉴 스타일 */
.tabs{display:flex;margin-top:20px;padding:0;list-style:none;overflow:hidden;}
.tabs li{background-color:#3f3f3f;cursor:pointer;list-style:none;border-right:1px solid #ddd;flex:1;text-align:center;}
.tabs li:last-child{border-right:none;}
.tabs li.active{background-color:white;}
.tabs li a{display:block;padding:10px 0;color:white;text-decoration:none;transition:color 0.3s ease;}
.tabs li.active a{color:black;}
.tabs ul{background-color:#3f3f3f;}
.tabs li:hover{background-color:white;color:black;}
.tabs li a:hover{color:black;}
.tab_content{padding:20px;background-color:#fff;}

/* 메뉴 카드 스타일 */
.menu-container{display:flex;flex-wrap:wrap;gap:8px;}
.menu-card{flex:0 0 calc(25% - 8px);box-sizing:border-box;border:1px solid #000;border-radius:4px;overflow:hidden;font-family:Arial,sans-serif;margin:0;}
.menu-image{width:100%;height:120px;background:#eee;display:flex;justify-content:center;align-items:center;}
.menu-image img{max-width:100%;max-height:100%;object-fit:contain;}
.menu-info{padding:8px;font-size:14px;line-height:1.2;text-align:center;}
.menu-name{font-weight:bold;margin:4px 0 2px;}
.menu-price{color:#555;margin:2px 0;}
.menu-description{color:#777;font-size:12px;margin:2px 0 4px;}

/* 리뷰 요약 섹션 스타일 */
.rating-summary{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:5px;margin-bottom:20px;}
.rating-card{padding:15px;text-align:center;background-color:#fafafa;}
.rating-card h2{font-size:2rem;margin:10px 0;}
.rating-card h7{font-size:0.9em;color:#555;}
.rating-breakdown-bar{display:flex;align-items:center;gap:10px;margin-bottom:8px;}
.rating-breakdown-bar .label{width:120px;flex-shrink:0;font-size:0.9em;}
.rating-bar-container{flex-grow:1;background:#cfcfcf;height:12px;border-radius:6px;overflow:hidden;}
.rating-bar-fill{background:#ffc107;height:100%;border-radius:6px;}
.review-list{margin-top:20px;}
.review-box{padding:15px 0;border-bottom:1px solid #e0e0e0;}
.review-box:last-child{border-bottom:none;}
.review-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:5px;}
.review-rating .star{color:#ccc;font-size:1.2rem;}
.review-rating .star.filled{color:orange;}
.review-writer{font-weight:bold;color:#555;}
.review-content{color:#333;line-height:1.5;margin-bottom:10px;}
.review-images{display:flex;flex-wrap:wrap;gap:8px;}
.review-image{width:70px;height:70px;object-fit:cover;}
.load-more-btn{display:block;width:100%;padding:10px;margin-top:20px;background:#f0f0f0;border:1px solid #ccc;border-radius:6px;cursor:pointer;transition:background 0.3s;}
.load-more-btn:hover{background:#e0e0e0;}
.detail-box{padding:15px 0;border-bottom:1px solid #e0e0e0;margin-bottom:15px;}
.detail-box:last-child{border-bottom:none;}

 /* 리뷰 상세 스타일 */
.rating{font-size:16px;margin-bottom:10px;}
.card-rating,.card-detail{flex:1;padding:16px;border:1px solid #ccc;border-radius:6px;text-align:center;background-color:#f9f9f9;}
.review_count{font-weight:bold;margin-bottom:12px;}
.countRating{margin-bottom:20px;}
.rating_bar_container{display:flex;align-items:center;gap:8px;margin-bottom:8px;}
.rating_label{width:120px;font-weight:500;}
.rating_bar_bg{background:#e1e1df;width:200px;height:12px;border-radius:6px;overflow:hidden;}
.rating_bar_fill{background:#f90;height:100%;border-radius:6px 0 0 6px;}
.detailReviewList{margin-top:20px;}
.review_box{border:1px solid #ddd;padding:12px;border-radius:6px;margin-bottom:10px;background-color:#fff;font-size:10px;}
.review_stars{color:#f90;font-size:14px;}
.review_user{font-weight:bold;font-size:13px;margin:4px 0;}
.review_text{font-size:14px;color:#333;}
.rating_summary_cards{display:flex;gap:10px;margin-bottom:16px;}
.review-image-thumbnail{object-fit:cover;border-radius:4px;border:1px solid #ccc;}

.detail-review-list{margin-top:20px;}
.review-box{border-bottom:1px solid #d7cece;padding:10px 5px;}
.review-rating{margin-bottom:5px;}
.star{font-size:18px;color:#ddd;}
.star.filled{color:orange;}
.review-meta{margin-bottom:10px;}
.review-writer{font-weight:bold;margin-bottom:3px;color:#bdc0bd;}
.review-content{color:#333;line-height:1.5;}
.review-images{display:flex;flex-wrap:wrap;gap:8px;}
.review-image{width:70px;height:70px;object-fit:cover;border-radius:4px;}

/* 기타 스타일 */
.detail-box{padding:auto 10px;margin:30px;}
.wating_container{text-align:center;border:1px solid #d0d0cd;padding:10px;border-radius:10px;}
#googleMap{width:100%;height:300px;border-radius:10px;}

/* 홈 메뉴 섹션 스타일 */
.home_menu_container{display:flex;flex-direction:column;gap:20px;padding:20px;margin:0 auto;}
.home_menu_card{display:flex;border-bottom:1px solid #ccc;padding-bottom:15px;}
.home_menu_image img{width:100px;height:100px;object-fit:cover;border-radius:8px;}
.home_menu_info{margin-left:15px;}
.home_menu_name{font-size:18px;font-weight:bold;margin:5px 0;}
.home_menu_price{font-size:16px;color:#000;}
.home_menu_description{color:#555;font-size:14px;}
.home_menu_badge{display:inline-block;font-size:12px;padding:2px 6px;border-radius:4px;margin-bottom:4px;font-weight:bold;color:white;}
.home_menu_badge.red{background-color:red;}
.home_menu_badge.orange{background-color:orange;}
.home_menu_more_btn_wrap{text-align:center;margin-top:20px;}
.home_menu_more_btn{padding:10px 20px;color:black;border:1px solid black;border-radius:6px;font-size:16px;cursor:pointer;}

.carousel-item.active{display:flex;justify-content:center;align-items:;}

 /* 예약 UI 관련 CSS 추가 */
.time-slot-btn{width:130px;margin:5px;font-size:0.9em;white-space:nowrap;}
.time-slot-btn.selected{background-color:#0d6efd;color:white;border-color:#0d6efd;}
.time-slot-btn.unavailable{background-color:#e9ecef;color:#6c757d;cursor:not-allowed;border-color:#e9ecef;}
.table-select-area{display:none;padding:10px;background-color:#f8f9fa;border-radius:5px;margin-top:10px;}
.table-slot-btn{margin:5px;}
.table-slot-btn.selected{background-color:#198754;color:white;}

 /* 홈 페이지 리뷰 섹션 스타일 */
.home_review-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:20px;}
/* .home_review-item{display:flex;justify-content:space-between;align-items:flex-start;padding:5px 10px;border-bottom:solid 1px #cfcfcf;background-color:#fdfdfd;height:100px;border-top:solid 1px #cfcfcf;} */
.home_review-text-wrapper{flex:1;margin-right:15px;}
.home_review-image-wrapper{flex-shrink:0;}
.home_review-image{width:90px;height:90px;object-fit:cover;border-radius:5px;align-items:flex-start;}
.home_review-writer{font-weight:bold;margin-bottom:5px;}
/* .home_review-content{font-size:0.95em;color:#333;white-space:normal;} */
.home_review-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:15px;}
.home_rating p{margin:0;font-weight:bold;font-size:1rem;}
.review-view-all button{font-size:0.9rem;padding:4px 10px;}
.home_review-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 5px 10px;
  border-bottom: solid 1px #cfcfcf;
  background-color: #fdfdfd;
  border-top: solid 1px #cfcfcf;
  /* height: 100px; ← 이 줄 제거 */
  min-height: 100px; /* 최소 높이 설정 */
}

.home_review-content {
  font-size: 0.95em;
  color: #333;
  white-space: normal;
  word-break: break-word;
}


.like-icon {
  font-size: 1.2em; /* 필요에 따라 조절 */
  color: grey; /* 기본 하얀 하트 대신 회색으로 */
  transition: color 0.3s ease;
}

.like-button.likes .like-icon {
  color: red;
}


  /* 💡 위시리스트 버튼 CSS 추가 */
.wishlist-btn{background:none;border:none;cursor:pointer;font-size:24px;color:#ccc;transition:color 0.3s ease;}
.wishlist-btn.active{color:#ff6347;}

.type-store-container { display: flex; flex-wrap: wrap; gap: 20px; }
.type-store {width: calc((100% - 40px) / 3);border: 1px solid grey;border-radius: 10px;padding: 5px 5px;}
.meta-info { font-size:13px; color:#777; margin:0; }

.review-like-btn {font-size: 12px; background:none;border:none;cursor:pointer;color:#ccc;transition:color 0.3s ease;}
.review-like-btn.active{color:#ff6347;}
.review-like-btn.fa-heart { font-size: 12px; }
.review-like-btn.liked{ color: red; }

</style>

</head>


<body>

<script>
let map;
const memberId = "${memberId}";
const storeId = ${storeId};
const contextPath = '${contextPath}';

// 💡 위시리스트 상태 확인
function checkWishlistStatus() {
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

// 💡 위시리스트 추가/제거 토글
function toggleWishlist() {
	if (!memberId || memberId.trim() === '' || memberId === 'null' || memberId === 'undefined') {
		if (confirm('로그인 후 이용해주세요. 로그인 페이지로 이동하시겠습니까?')) {
			window.location.href = contextPath + '/member/login';
		}
		return;
	}

	const isWishlisted = $('#wishlist-btn').hasClass('active');

	if (isWishlisted) {
		if (confirm("위시리스트에 이미 추가되었습니다. 삭제하시겠습니까?")) {
			$.ajax({
				url: `${contextPath}/wishlist/remove`,
				type: 'DELETE',
				data: {
					memberId: memberId,
					storeId: storeId
				},
				success: function(response) {
					alert(response);
					checkWishlistStatus();
				},
				error: function(xhr) {
					const errorMessage = xhr.responseText || "오류가 발생했습니다.";
					alert(errorMessage);
					checkWishlistStatus();
				}
			});
		}
	} else {
		$.ajax({
			url: `${contextPath}/wishlist/add`,
			type: 'POST',
			data: {
				memberId: memberId,
				storeId: storeId
			},
			success: function(response) {
				alert(response);
				checkWishlistStatus();
			},
			error: function(xhr) {
				const errorMessage = xhr.responseText || "오류가 발생했습니다.";
				alert(errorMessage);
				checkWishlistStatus();
			}
		});
	}
}

//💡 리뷰 좋아요 상태 확인
function checkReviewLikeStatus() {
	if (!memberId || memberId === 'null' || memberId === 'undefined') return;

	$('.review-like-btn').each(function () {
		const $btn = $(this);
		const reviewId = $btn.data('review-id');
		if (!reviewId) return;

		$.ajax({
			url: `${contextPath}/review/isLiked`,
			type: 'GET',
			data: {
				memberId: memberId,
				reviewId: reviewId
			},
			success: function(response) {
				console.log(response);
				if (response === true) {
					$btn.addClass('liked');
				} else {
					$btn.removeClass('liked');
				}
			},
			error: function(error) {
				console.error('리뷰 좋아요 상태 확인 실패:', error);
			}
		});
	});
}

//💡 리뷰 좋아요 추가/제거 토글
function toggleReviewLike(event) {
	if (!memberId || memberId.trim() === '' || memberId === 'null' || memberId === 'undefined') {
		if (confirm('로그인 후 이용해주세요. 로그인 페이지로 이동하시겠습니까?')) {
			window.location.href = contextPath + '/member/login';
		}
		return;
	}

	const $btn = $(event.currentTarget);
	const reviewId = $btn.data('review-id');
	if (!reviewId) {
		alert("리뷰 ID가 없습니다.");
		return;
	}

	const isLiked = $btn.hasClass('liked');

	if (isLiked) {
		$.ajax({
			url: `${contextPath}/review/decreaseLikes`,
			type: 'DELETE',
			data: {
				memberId: memberId,
				reviewId: reviewId
			},
			success: function(response) {
				$btn.removeClass('liked');
				$btn.find('.likes-count').text(response.likes);
			},
			error: function(xhr) {
				const errorMessage = xhr.responseText || "오류가 발생했습니다.";
				alert(errorMessage);
			}
		});
	} else {
		$.ajax({
			url: `${contextPath}/review/increaseLikes`,
			type: 'POST',
			data: {
				memberId: memberId,
				reviewId: reviewId
			},
			success: function(response) {
				$btn.addClass('liked');
				$btn.find('.likes-count').text(response.likes);
			},
			error: function(xhr) {
				const errorMessage = xhr.responseText || "오류가 발생했습니다.";
				alert(errorMessage);
			}
		});
	}
}

// 💡 구글 지도 초기화
function initMap() {
	const geocoder = new google.maps.Geocoder();
	const address = '<c:out value="${store.roadAddress}"/>';
	if (!address) {
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

// 💡 게스트 수 변경
function changeGuestCount(change) {
	let guestCountInput = $('#guestCount');
	let newCount = parseInt(guestCountInput.val()) + change;
	if (newCount >= 1 && newCount <= 10) {
		guestCountInput.val(newCount);
	}
}

function openTab2() {
	document.querySelector('ul.tabs li a[href="#tab2"]').click();
}
function openTab3() {
	document.querySelector('ul.tabs li a[href="#tab3"]').click();
}

$(function () {
	checkWishlistStatus();
	checkReviewLikeStatus();

	$('#wishlist-btn').on('click', toggleWishlist);

	$(document).on('click', '.review-like-btn', toggleReviewLike);

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

	$('#copyaddress').on('click', function () {
		navigator.clipboard.writeText('${store.roadAddress}').then(function () {
			alert("주소가 복사되었습니다.");
		}).catch(function (err) {
			alert("복사 실패: " + err);
		});
	});

	$('#copyUrlBtn').on('click', function () {
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

$(document).ready(function(){
	let reviewsLoaded = 10;
	const totalReviews = ${store.countRating};

	$('#loadMoreBtn').on('click', function() {
		$.ajax({
			url: `${contextPath}/reviews/loadMore`,
			type: 'GET',
			data: {
				storeId: '${store.storeId}',
				start: reviewsLoaded,
				count: 10
			},
			success: function(response) {
				response.forEach(function(review) {
					const newReviewHtml = `
					<div class="review-box">
						<div class="review-rating">...</div>
							<div class="review-meta">...</div>
					</div>
					`;
					$('.detail-review-list').append(newReviewHtml);
				});

				reviewsLoaded += response.length;

				if (reviewsLoaded >= totalReviews) {
					$('#loadMoreBtn').hide();
				}
			},
			error: function() {
				alert('리뷰를 불러오는 데 실패했습니다.');
			}
		});
	});
});

</script>


<div class="store-info">
	<div class="store-info d-flex" style="gap: 20px; margin:0px; ">
		<div class="carousel-container" style="display: table-cell; vertical-align:middle; width:50%; padding-right:20px;">
			<div id="carouselExampleAutoplaying" class="carousel slide" data-bs-ride="carousel">
				<div class="carousel-inner">
					<div class="carousel-item active">
						<img src="${contextPath }/images/store/${store.fileName}" class="d-block w-100" alt="${store.fileName}" height="400px">
					</div>
					<c:forEach var="storeImage" items="${storeMap.storeImage}" varStatus="status">
						<div class="carousel-item">
							<img src="${contextPath }/images/store/${storeImage.fileName}" alt="${storeImage.fileName}" height="400px">
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
				<!-- <button class="wishlist-btn" id="wishlist-btn" aria-label="위시리스트 추가/제거"><i class="fa fa-heart"></i></button> -->
				<button class="wishlist-btn" id="wishlist-btn" aria-label="위시리스트 추가/제거"><i class="fa fa-bookmark "></i></button>
				<button class="btn btn-outline-secondary btn-sm mt-2" id="copyUrlBtn">공유</button>
			</div>
			<small>${store.storeType }</small>
			<div class="rating mt-2 mb-2">
				<img src="${contextPath}/image/review_rating.jpg" width="16" height="16" alt="리뷰이미지"> ${store.avgRating}&nbsp;&nbsp;&nbsp;리뷰 ${store.countRating}개
				<button type="button" onClick="openTab3()" class="btn btn-link" style="text-decoration:none; color:black;"><strong>></strong></button>
			</div>
			<div>
				<p>
					<img src="${contextPath}/image/address_pin.jpg" width="16" height="16" alt="위치"> ${store.roadAddress} ${store.detailAddress} ${store.extraAddress}
					<button class="btn btn-link btn-sm" id="copyaddress">위치</button>
				</p>
				<p><img src="${contextPath}/image/calling.png" width="16" height="16" alt="전화번호"> ${store.localNumber} - ${store.number1} - ${store.number2}</p>
			</div>
			<div>
				<p><img src="${contextPath}/image/openhour.png" width="16" height="16" alt="영업시간"><strong>영업중</strong> ${store.operatingTime}</p>
			</div>
			<div class="waiting-container">
				<h4>현재 대기</h4>
				<h6><strong>${currentWaitingCount}</strong>팀</h6>
				<button type="button" style="width:80%" class="btn btn-danger" onClick="window.location.href='${contextPath}/waiting/customer/form?storeId=${storeId}'">웨이팅하기</button>
			</div>
		</div>
	</div>
	<div class="home_review_container">
	    <div class="home_review-meta">
	        <div class="home_review-header">
	            <div class="home_rating">
	                <p>리뷰 ${store.countRating } <img src="${contextPath}/image/review_rating.jpg" width="20px" alt="리뷰이미지"> ${store.avgRating } / 5</p>
	            </div>
	            <div class="review-view-all">
	                <button class="btn btn-sm btn-outline-secondary" onclick="openTab3()">전체보기</button>
	            </div>
	        </div>
	        <div class="home_review-grid">
	            <c:forEach var="review" items="${storeMap.review}" varStatus="status">
	                <c:if test="${status.index < 4}">
	                    <div class="home_review-item">
	                        <div class="home_review-text-wrapper">
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
	                            <div class="home_review-writer">
	                                <c:set var="visiblePart" value="${fn:substring(review.writerId, 0, 2)}" />
	                                <c:set var="maskedLength" value="${fn:length(review.writerId) - 2}" />
	                                ${visiblePart}
	                                <c:forEach begin="1" end="${maskedLength}">*</c:forEach>
	                            </div>
	                            <div class="home_review-content">${review.content}</div>
	                        </div>

	                        <div class="home_review-image">
	                            <c:forEach var="homeReviewImage" items="${storeMap.homeReviewImage}">
	                                <c:if test="${homeReviewImage.reviewId == review.reviewId}">
	                                    <img src="${contextPath}/images/review/${homeReviewImage.fileName}" alt="리뷰 이미지" class="home_review-image" />
	                                </c:if>
	                            </c:forEach>
	                        </div>
	                    </div>
	            	</c:if>
	            </c:forEach>
	        </div>
		</div>
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

						<%--
						<div class="button-group mt-5">
							<a href="<c:url value='/reservation/owner/manageList?storeId=${store.storeId}'/>">점주 관리 페이지</a>
						</div>

						<div class="back-link">
							<a href="<c:url value='${contextPath }/store/storeList'/>">매장 목록으로 돌아가기</a>
						</div>
						 --%>

					<h5 class="mt-4">메뉴</h5>
					<div class="home_menu_container">
						<c:forEach var="menu" items="${storeMap.menu}" varStatus="status">
							<c:if test="${status.index < 4}">
								<div class="home_menu_card ">
									<div class="home_menu_image">
										<img src="${contextPath}/images/menu/${menu.fileName}" alt="${menu.menuName}">
									</div>
									<div class=".home_menu_info ">
										<p class="home_menu_name ">${menu.menuName}</p>
										<p class="home_menu_price ">${menu.price}원</p>
										<p class="home_menu_description ">${menu.description}</p>
									</div>
								</div>
							</c:if>
						</c:forEach>
					</div>
					<div class="home_menu_more_btn_wrap">
						<button class="home_menu_more_btn" onclick="openTab2()">메뉴 전체 보기</button>
					</div>
					
					<h5 class="mt-4">비슷한 가게 추천</h5>
					<div class="type-store-container">
						<c:forEach var="type" items="${storeTypeList}">
							<div class="type-store">
								<a href="${contextPath}/store/storeDetail?storeId=${type.storeId}"><img alt="${type.storeName}" src="${contextPath}/images/store/${type.fileName}" width="180px"></a>
								<div class="type-storeInfo">
									<p><span class="rating">⭐ ${type.avgRating}</span> 리뷰 ${type.countRating}개</p> 
									<h5>${type.storeName} · ${type.storeType}</h5>
									<p class="meta-info">📍${type.roadAddress}</p>
								    <p class="meta-info">📞${type.localNumber} - ${type.number1} - ${type.number2}</p>
								    <p class="meta-info">📝${type.description}</p>
								</div>
							</div>
						</c:forEach>
					</div>
					
					<h5 class="mt-4">가게 주변 맛집</h5>
					<div class="type-store-container">
						<c:forEach var="near" items="${nearByStoreList}">
						    <c:if test="${near.storeId != store.storeId}">
						        <div class="type-store">
						            <a href="${contextPath}/store/storeDetail?storeId=${near.storeId}"><img alt="${near.storeName}" src="${contextPath}/images/store/${near.fileName}" width="180px"></a>
						            <div class="type-storeInfo">
						                <p><span class="rating">⭐ ${near.avgRating}</span> 리뷰 ${near.countRating}개</p> 
						                <h5>${near.storeName} · ${near.storeType}</h5>
						                <p class="meta-info">📍${near.roadAddress}</p>
						                <p class="meta-info">📞${near.localNumber} - ${near.number1} - ${near.number2}</p>
						                <p class="meta-info">📝${near.description}</p>
						            </div>
						        </div>
						    </c:if>
						</c:forEach>
					</div>
				</div>

				<div class="tab_content" id="tab2">
					<div class="menu-container">
						<c:forEach var="menu" items="${storeMap.menu}">
							<div class="menu-card">
								<div class="menu-image">
									<img src="${contextPath }/images/menu/${menu.fileName}" alt="${menu.menuName}" width="100px">
								</div>
								<div class="menu-info">
									<p class="menu-name">${menu.menuName}</p>
									<p class="menu-price">${menu.price}원</p>
									<p class="menu-description">${menu.description}</p>
								</div>
							</div>
						</c:forEach>
					</div>
				</div>
				<div class="tab_content" id="tab3">
					<h5 class="mt-4">리뷰</h5>
					<div class="rating-summary">
						<div class="rating-card">
							<h7>${store.countRating}개 리뷰 별점 평균</h7>
							<h2><img src="${contextPath}/image/review_rating.jpg" width="40" alt="별점 아이콘">${store.avgRating}</h2>
						</div>

						<div class="rating-card">
							<c:forEach var="detailReview1" items="${storeMap.detailReview1}">
								<div class="rating-breakdown-bar">
									<span class="label">${detailReview1.rating}점 (${detailReview1.countScoreRating}명)</span>
									<div class="rating-bar-container">
										<div class="rating-bar-fill" style="width: calc(${detailReview1.countScoreRating * 100 / store.countRating}%);"></div>
									</div>
								</div>
							</c:forEach>
						</div>
						<div class="rating-card">
							<div class="rating-breakdown-bar">
								<span class="label">음식 맛 (${detailReview2.tastePercent}%)</span>
								<div class="rating-bar-container">
									<div class="rating-bar-fill" style="width: calc(${detailReview2.tastePercent}%);"></div>
								</div>
							</div>
							<div class="rating-breakdown-bar">
								<span class="label">분위기 (${detailReview2.moodPercent}%)</span>
								<div class="rating-bar-container">
									<div class="rating-bar-fill" style="width: calc(${detailReview2.moodPercent}%);"></div>
								</div>
							</div>
							<div class="rating-breakdown-bar">
								<span class="label">서비스 (${detailReview2.servicePercent}%)</span>
								<div class="rating-bar-container">
									<div class="rating-bar-fill" style="width: calc(${detailReview2.servicePercent}%);"></div>
								</div>
							</div>
							<div class="rating-breakdown-bar">
								<span class="label">청결 (${detailReview2.cleanPercent}%)</span>
								<div class="rating-bar-container">
									<div class="rating-bar-fill" style="width: calc(${detailReview2.cleanPercent}%);"></div>
								</div>
							</div>
						</div>
					</div>
					<div class="review-list">
						<h4>리뷰 ${store.countRating}건</h4>
						<c:forEach var="review" items="${storeMap.review}" varStatus="loop">
							<div class="review-box">
								<div class="review-header">
									<div class="review-rating">
										<c:forEach begin="1" end="5" var="i">
											<span class="star <c:if test="${i <= review.rating}">filled</c:if>">★</span>
										</c:forEach>
									</div>
								</div>
								<div class="review-writer">
									${fn:substring(review.writerId, 0, 2)}<c:forEach begin="1" end="${fn:length(review.writerId) - 2}">*</c:forEach>
								</div>
								
								<c:if test="${not empty storeMap.reviewImage}">
								    <div class="review-images">
								        <c:forEach var="img" items="${storeMap.reviewImage}">
								            <c:if test="${img.reviewId == review.reviewId}">
								                <img src="${contextPath}/images/review/${img.fileName}" alt="리뷰 이미지" class="review-image">
								            </c:if>
								        </c:forEach>
								    </div>
								</c:if>
								<div class="review-content">${review.content}</div>
								<!-- 중복 ID 제거 -->
								<button class="review-like-btn ${isLiked ? 'liked' : ''}" 
								        data-review-id="${review.reviewId}" 
								        aria-label="리뷰 좋아요 추가/제거">
								    <i class="fa fa-heart"></i> <span class="likes-count">${review.likes}</span>
								</button>
							</div>
						</c:forEach>
						<c:if test="${store.countRating > 10}">
							<button id="loadMoreBtn" class="load-more-btn">더보기</button>
						</c:if>
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
						<p ><img src="${contextPath}/image/location.png" width="10" height="10" alt="위치">${store.roadAddress } <button class="btn btn-outline-secondary btn-sm" id="copyaddress">복사</button> </p>
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
