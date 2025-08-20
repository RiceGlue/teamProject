<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<style>
	.star-rating {direction: rtl; font-size: 2rem; unicode-bidi: bidi-override; display: inline-flex;}
	.star-rating input[type="radio"] {display: none;}
	.star-rating label {color: #ccc; cursor: pointer; padding: 0 5px; user-select: none;}
	.star-rating input[type="radio"]:checked ~ label,
	.star-rating label:hover,
	.star-rating label:hover ~ label {color: gold;}
	.store-card { border: solid 1px #c7bfbf; border-radius:10px; display:flex; padding:12px; margin:20px; font-family:'Segoe UI', sans-serif; align-items:center; }
	.store-image { position:relative; width:120px; height:120px; border-radius:6px; overflow:hidden; flex-shrink:0; }
	.store-image img { width:100%; height:100%; object-fit:cover; }
	.store-info { margin-left:16px; flex:1; }
	.store-info h4 { margin:0 0 6px; font-size:18px; }
	.store-info p { margin:4px 0; font-size:14px; color:#444; }
	.rating { color:#ffa500; font-weight:bold; }
</style>

<script>

// 평점 필수 체크 (폼 제출 시)
function validateReviewForm(form) {
  if (![...form.rating].some(r => r.checked)) {
    alert('평점을 선택해주세요.');
    return false;
  }
  if (!form.content.value.trim()) {
    alert('리뷰 내용을 입력해주세요.');
    form.content.focus();
    return false;
  }
  return true;
}

function validateReviewForm(form) {
    if (!form.rating.value) {
        alert('평점을 선택해주세요.');
        form.rating.focus();
        return false;
    }
    if (!form.content.value.trim()) {
        alert('리뷰 내용을 입력해주세요.');
        form.content.focus();
        return false;
    }
    return true;
}

function previewReviewImage(input) {
	const preview = document.getElementById('imagePreview');
	preview.innerHTML = '';
	if (input.files && input.files[0]) {
		const file = input.files[0];
		if (!file.type.startsWith('image/')) {
			alert('이미지 파일만 첨부할 수 있습니다.');
			input.value = '';
			return;
		}
		
		const reader = new FileReader();
		reader.onload = function(e) {
			const img = document.createElement('img');
			img.src = e.target.result;
			img.style.maxWidth = '250px';
			img.style.maxHeight = '250px';
			preview.appendChild(img);
		}
		reader.readAsDataURL(file);
	}
}
</script>

<h2>${storeInfo.storeName }의 방문후기</h2>

<div>
	<h3 style="text-align:center;">방문 정보</h3>
	<div class="store-card">
		<div class="store-image">
			<a href="${contextPath}/store/storeDetail?storeId=${storeInfo.storeId}&ownerId=${storeInfo.ownerId}">
			<img src="${contextPath }/download?directoryName=store&fileName=${storeInfo.fileName}" alt="${storeInfo.fileName }">
			</a>
		</div>
		<div class="store-info">
			<h4>${storeInfo.storeName}</h4>
			<p><span class="rating">★ ${storeInfo.avgRating}</span>리뷰 ${storeInfo.countRating}개</p>
			<p class="meta-info">${storeInfo.storeType} · ${storeInfo.address}</p>
			<p class="meta-info">${storeInfo.description}</p>
		</div>
	</div>
	
	<!-- 방문 내역 출력 -->	
	<c:if test="${not empty reservation}">
		<p>방문 유형: 예약</p>
		<p>방문 인원: ${reservation.guestCount } </p>
		<p>예약 시간: ${reservation.reservationTime}</p>
	</c:if>
	
	<c:if test="${not empty waiting}">
		<p>방문 유형: 웨이팅</p>
		<p>방문 인원: ${waiting.guestCount } </p>
		<p>대기 등록 시간: ${waiting.createdAt}</p>
		<p>매장 방문 시간: ${waiting.updatedAt}</p>
	</c:if>
</div>


<div style="display: flex; flex-direction: column; align-items: center; min-height: 100vh; margin-top:50px;">
	<form action="${contextPath}/review/addReview" method="post" enctype="multipart/form-data" onsubmit="return validateReviewForm(this)">
		<input type="hidden" name="memberId" value="${memberId}" />
		<input type="hidden" name="storeId" value="${storeId}" />
		
		<c:choose>
			<c:when test="${not empty reservationId}">
				<input type="hidden" name="reservationId" value="${reservationId}" />
			</c:when>
			<c:otherwise>
				<input type="hidden" name="waitingId" value="${waitingId}" />
			</c:otherwise>
		</c:choose>
		
		<!-- 평점 -->
		<div class="form-row" style="display: flex; flex-direction: column; margin-bottom: 10px; align-items: center;">
			<div class="form-input" style="flex: 1;">
				<div class="star-rating">
					<input type="radio" id="star5" name="rating" value="5" />
					<label for="star5" title="5점">★</label>
					<input type="radio" id="star4" name="rating" value="4" />
					<label for="star4" title="4점">★</label>
					<input type="radio" id="star3" name="rating" value="3" />
					<label for="star3" title="3점">★</label>
					<input type="radio" id="star2" name="rating" value="2" />
					<label for="star2" title="2점">★</label>
					<input type="radio" id="star1" name="rating" value="1" />
					<label for="star1" title="1점">★</label>
				</div>
			</div>
		</div>
		
		<!-- 리뷰 내용 -->
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;">
			<div class="form-input" style="flex: 1;">
				<textarea id="content" name="content" rows="5" cols="100" placeholder="리뷰를 작성해주세요." required></textarea>
			</div>
		</div>
		
		<!-- 이미지 첨부 -->
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
			<div class="form-input" style="flex: 1;">
				<input type="file" id="reviewImage" name="reviewImage" accept="image/*" onchange="previewReviewImage(this)" />
				<div id="imagePreview" style="margin-top: 10px;"></div>
			</div>
		</div>
		
		<!-- 제출 버튼 -->
		<div class="form-row" style="display: flex; margin-top: 20px;">
			<input type="button" onclick="checkReview()" value="리뷰 작성" />
		</div>
	</form>
</div>
