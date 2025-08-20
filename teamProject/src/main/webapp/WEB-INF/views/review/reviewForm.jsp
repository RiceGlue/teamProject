<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:if test="${param.error eq 'true'}">
    <script>alert("리뷰 작성 실패");</script>
</c:if>

<style>
.storeInfo { text-align: center; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
.storeInfo img { width: 80px; height: 80px; border-radius: 50%; object-fit: cover; margin-bottom: 10px; display: block; margin-left: auto; margin-right: auto; }
.storeInfo h4 { margin: 5px 0; font-weight: 600; font-size: 1.2rem; }
.storeInfo h2 { margin: 10px 0 0; font-weight: 700; font-size: 1.5rem; }
form { max-width: 420px; margin: 0 auto; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; display: flex; flex-direction: column; gap: 10px; }
.star-rating { direction: rtl; font-size: 2.5rem; unicode-bidi: bidi-override; display: flex; justify-content: center; gap: 8px; }
.star-rating input[type="radio"] { display: none; }
.star-rating label { cursor: pointer; color: #ccc; user-select: none; transition: color 0.2s ease-in-out; }
.star-rating input[type="radio"]:checked ~ label, .star-rating label:hover, .star-rating label:hover ~ label { color: gold; }
.form-row { display: flex; flex-direction: column; align-items: center; gap: 8px; }
.form-row h4 { margin: 0; font-weight: 500; color: #555; }
textarea#content { width: 100%; min-height: 100px; padding: 10px; font-size: 1rem; border: 1px solid #ccc; border-radius: 8px; resize: vertical; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
input[type="file"] { width: 100%; padding: 12px; border: 2px dashed #ccc; border-radius: 8px; cursor: pointer; font-size: 0.9rem; color: #666; box-sizing: border-box; }
#imagePreview {margin-top: 10px; display: flex; flex-wrap: wrap; gap: 10px; width: 420px; }
.image-preview-item {position: relative; width: calc(20% - 8px); height: auto; aspect-ratio: 1 / 1;}
.image-preview-item img {width: 100%; height: 100%; border-radius: 8px; object-fit: cover; border: 1px solid #ddd;}
.remove-image {position: absolute; top: -5px; right: -5px; background-color: #000; color: white; border-radius: 50%; width: 20px; height: 20px; text-align: center; line-height: 20px; font-size: 14px; cursor: pointer; z-index: 10;}
#fileNames {margin-top: 10px; font-size: 0.9em; color: #555;}
#fileNames > div {margin-bottom: 5px;}
.clear-button-container {width: 100%; text-align: right; margin-top: 5px;}
.clear-images-button {background: none; border: 1px solid #ccc; border-radius: 5px; padding: 5px 10px; font-size: 0.9rem; cursor: pointer;}
input[type="button"] { width: 100%; padding: 12px 0; background: none; border: 1.5px solid #444; border-radius: 8px; font-weight: 600; font-size: 1.1rem; cursor: pointer; transition: background-color 0.2s ease-in-out; }
input[type="button"]:hover { background-color: #f0f0f0; }
.storeRating {display: flex; flex-direction: column; gap: 30px; margin-top: 30px;}
.rating-group {display: flex; flex-direction: column; align-items: center; gap: 10px;}
.rating-label {font-weight: bold; font-size: 1rem;}
.rating-options {display: flex; gap: 10px; flex-wrap: wrap; justify-content: center;}
.rating-options input[type="radio"] {display: none;}
.rating-options label {padding: 8px 14px; border: 1px solid #ccc; border-radius: 20px; font-size: 0.9rem; cursor: pointer; color: #333; background-color: #f9f9f9; transition: all 0.2s ease-in-out;}
.rating-options input[type="radio"]:checked + label {border-color: #000; font-weight: bold; background-color: #eaeaea;}
</style>

<script>
function updateRatingMessage(rating) {
	  const message = document.getElementById('rating-message');
	  if (rating >= 4) {
	    message.textContent = '어떤 점이 좋았나요?';
	  } else if (rating === 3) {
	    message.textContent = '어떤 점이 괜찮았나요?';
	  } else if (rating >= 1) {
	    message.textContent = '어떤 점이 아쉬웠나요?';
	  } else {
	    message.textContent = '별점을 선택해주세요';
	  }
	}

	document.addEventListener('DOMContentLoaded', function () {
	  const ratingInputs = document.querySelectorAll('input[name="rating"]');
	  ratingInputs.forEach(input => {
	    input.addEventListener('change', function () {
	      updateRatingMessage(parseInt(this.value));
	    });
	  });
	});

	function previewReviewImage(input) {
		const preview = document.getElementById('imagePreview');
		const files = Array.from(input.files);
		const maxImages = 5;

		const existingImagesCount = preview.getElementsByClassName('image-preview-item').length;
		
		if (existingImagesCount >= maxImages) {
			alert(`이미지는 최대 ${maxImages}장까지 업로드할 수 있습니다.`);
			input.value = '';
			return;
		}

		if (existingImagesCount + files.length > maxImages) {
			alert(`이미지는 최대 ${maxImages}장까지 업로드할 수 있습니다.`);
			input.value = '';
			return;
		}

		files.forEach(file => {
			if (!file.type.startsWith('image/')) return;
			const reader = new FileReader();
			reader.onload = function(e) {
				const item = document.createElement('div');
				item.className = 'image-preview-item';
				const img = document.createElement('img');
				img.src = e.target.result;
				const removeBtn = document.createElement('span');
				removeBtn.className = 'remove-image';
				removeBtn.innerHTML = '&times;';
				
				removeBtn.onclick = function() {
					item.remove();
					updateFileNameDisplay();
				};

				item.appendChild(img);
				item.appendChild(removeBtn);
				preview.appendChild(item);
			};
			reader.readAsDataURL(file);
		});
		
		updateFileNameDisplay();
		input.value = '';
	}

	function updateFileNameDisplay() {
		const fileInput = document.getElementById('fileName');
		const fileNamesDisplay = document.getElementById('fileNameDisplay');
		
		if (fileInput.files.length > 0) {
			let fileNames = Array.from(fileInput.files).map(file => file.name).join(', ');
			fileNamesDisplay.textContent = fileNames;
		} else {
			fileNamesDisplay.textContent = '선택된 파일 없음';
		}
	}
	
	function clearImages() {
		const preview = document.getElementById('imagePreview');
		const fileInput = document.getElementById('fileName');
		preview.innerHTML = '';
		fileInput.value = '';
	}
	
	function checkReview() {
	  const form = document.querySelector('form');

	  const ratingInputs = document.querySelectorAll('input[name="rating"]');
	  if (![...ratingInputs].some(r => r.checked)) {
	    alert('별점을 선택해주세요.');
	    return;
	  }

	  const content = form.content.value.trim();
	  if (content.length < 10) {
	    alert('리뷰 내용을 10자 이상 작성해주세요.');
	    form.content.focus();
	    return;
	  }

	  const tasteInputs = document.getElementsByName('taste');
	  if (![...tasteInputs].some(r => r.checked)) {
	    alert('음식 맛 평점을 선택해주세요.');
	    return;
	  }

	  const moodInputs = document.getElementsByName('mood');
	  if (![...moodInputs].some(r => r.checked)) {
	    alert('분위기 평점을 선택해주세요.');
	    return;
	  }

	  const serviceInputs = document.getElementsByName('service');
	  if (![...serviceInputs].some(r => r.checked)) {
	    alert('서비스 평점을 선택해주세요.');
	    return;
	  }

	  const cleanInputs = document.getElementsByName('clean');
	  if (![...cleanInputs].some(r => r.checked)) {
	    alert('청결 상태 평점을 선택해주세요.');
	    return;
	  }

	  form.submit();
	}

</script>

<div class="storeInfo">
	<img src="${contextPath }/download?directoryName=store&fileName=${storeInfo.fileName}" alt="${storeInfo.fileName }">
	<h4>${storeInfo.storeName }</h4>
	<h2>방문 어떠셨나요?</h2>
</div>

<div style="display: flex; flex-direction: column; align-items: center; min-height: 100vh;">
	<form action="${contextPath}/review/addReview" method="post" enctype="multipart/form-data" onsubmit="return checkReview()">
		<input type="hidden" name="memberId" value="${memberId}" />
		<input type="hidden" name="storeId" value="${storeInfo.storeId}" />
		<c:choose>
			<c:when test="${not empty reservationId}">
				<input type="hidden" name="reservationId" value="${reservationId}" />
			</c:when>
			<c:otherwise>
				<input type="hidden" name="waitingId" value="${waitingId}" />
			</c:otherwise>
		</c:choose>
		
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
	
			<h4 id="rating-message">별점을 선택해주세요</h4>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;">
			<div class="form-input" style="flex: 1;">
				<textarea id="content" name="content" rows="5" cols="100" placeholder="리뷰를 작성해주세요." required></textarea>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; flex-direction: column; margin-bottom: 10px; align-items: center;">
			<div class="form-input" style="flex: 1;">
				<input type="file" id="fileName" name="fileName" accept="image/*" multiple onchange="previewReviewImage(this)" />
				<div id="imagePreview"></div>
				<div class="clear-button-container">
					<button type="button" class="clear-images-button" onclick="clearImages()">전체 이미지 삭제</button>
				</div>
			</div>
		</div>
		
		<div class="storeRating">
			<div class="rating-group">
				<div class="rating-label">음식 맛은 어떤가요?</div>
				<div class="rating-options">
					<input type="radio" id="taste-1" name="taste" value="1"><label for="taste-1">최악</label>
					<input type="radio" id="taste-2" name="taste" value="2"><label for="taste-2">별로</label>
					<input type="radio" id="taste-3" name="taste" value="3"><label for="taste-3">보통</label>
					<input type="radio" id="taste-4" name="taste" value="4"><label for="taste-4">만족</label>
					<input type="radio" id="taste-5" name="taste" value="5"><label for="taste-5">최고</label>
				</div>
			</div>
			
			<div class="rating-group">
				<div class="rating-label">분위기는 어떤가요?</div>
				<div class="rating-options">
					<input type="radio" id="mood-1" name="mood" value="1"><label for="mood-1">최악</label>
					<input type="radio" id="mood-2" name="mood" value="2"><label for="mood-2">별로</label>
					<input type="radio" id="mood-3" name="mood" value="3"><label for="mood-3">보통</label>
					<input type="radio" id="mood-4" name="mood" value="4"><label for="mood-4">만족</label>
					<input type="radio" id="mood-5" name="mood" value="5"><label for="mood-5">최고</label>
				</div>
			</div>
			
			<div class="rating-group">
				<div class="rating-label">서비스는 친절했나요?</div>
				<div class="rating-options">
					<input type="radio" id="service-1" name="service" value="1"><label for="service-1">최악</label>
					<input type="radio" id="service-2" name="service" value="2"><label for="service-2">별로</label>
					<input type="radio" id="service-3" name="service" value="3"><label for="service-3">보통</label>
					<input type="radio" id="service-4" name="service" value="4"><label for="service-4">만족</label>
					<input type="radio" id="service-5" name="service" value="5"><label for="service-5">최고</label>
				</div>
			</div>
			
			<div class="rating-group">
				<div class="rating-label">매장 청결상태는 양호한가요?</div>
				<div class="rating-options">
					<input type="radio" id="clean-1" name="clean" value="1"><label for="clean-1">최악</label>
					<input type="radio" id="clean-2" name="clean" value="2"><label for="clean-2">별로</label>
					<input type="radio" id="clean-3" name="clean" value="3"><label for="clean-3">보통</label>
					<input type="radio" id="clean-4" name="clean" value="4"><label for="clean-4">만족</label>
					<input type="radio" id="clean-5" name="clean" value="5"><label for="clean-5">최고</label>
				</div>
			</div>
		</div>

		
		<div class="form-row" style="display: flex; margin-top: 20px;">
			<input type="submit" value="리뷰 작성" />
		</div>
	</form>
</div>