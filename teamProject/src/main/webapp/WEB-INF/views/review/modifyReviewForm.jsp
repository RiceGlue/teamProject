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
// 전역 변수로 선택된 모든 파일을 저장할 배열을 선언합니다.
let selectedFiles = [];

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

	  // 새로 선택한 파일 중 중복되지 않은 파일만 추가
	  files.forEach(file => {
	    const isDuplicate = selectedFiles.some(f => f.name === file.name && f.size === file.size);
	    if (!isDuplicate) {
	      selectedFiles.push(file);
	    }
	  });

	  // 최대 이미지 개수 제한
	  if (selectedFiles.length > maxImages) {
	    alert(`이미지는 최대 ${maxImages}장까지 업로드할 수 있습니다.`);
	    selectedFiles = selectedFiles.slice(0, maxImages);
	  }

	  // 미리보기 다시 그리기
	  preview.innerHTML = '';
	  selectedFiles.forEach(file => {
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

	      // 삭제 버튼 클릭 시 해당 파일 제거
	      removeBtn.onclick = function() {
	        selectedFiles = selectedFiles.filter(f => f !== file);
	        previewReviewImage(input);  // 미리보기 갱신
	      };

	      item.appendChild(img);
	      item.appendChild(removeBtn);
	      preview.appendChild(item);
	    };
	    reader.readAsDataURL(file);
	  });

	  // input 초기화 필요 없음 (파일 추가 누적 허용)
	}


function clearImages() {
  const preview = document.getElementById('imagePreview');
  preview.innerHTML = '';
  // 배열도 함께 비웁니다.
  selectedFiles = [];
  const fileInput = document.getElementById('fileName');
  fileInput.value = ''; // 이 부분은 비워도 됩니다.
}

function checkReview() {
  const form = document.querySelector('form');

  const ratingInputs = document.querySelectorAll('input[name="rating"]');
  if (![...ratingInputs].some(r => r.checked)) {
    alert('별점을 선택해주세요.');
    return false; // form.submit() 대신 false 반환
  }

  const content = form.content.value.trim();
  if (content.length < 10) {
    alert('리뷰 내용을 10자 이상 작성해주세요.');
    form.content.focus();
    return false;
  }

  const tasteInputs = document.getElementsByName('taste');
  if (![...tasteInputs].some(r => r.checked)) {
    alert('음식 맛 평점을 선택해주세요.');
    return false;
  }

  const moodInputs = document.getElementsByName('mood');
  if (![...moodInputs].some(r => r.checked)) {
    alert('분위기 평점을 선택해주세요.');
    return false;
  }

  const serviceInputs = document.getElementsByName('service');
  if (![...serviceInputs].some(r => r.checked)) {
    alert('서비스 평점을 선택해주세요.');
    return false;
  }

  const cleanInputs = document.getElementsByName('clean');
  if (![...cleanInputs].some(r => r.checked)) {
    alert('청결 상태 평점을 선택해주세요.');
    return false;
  }
  
  // 폼 제출 전에 FormData에 파일을 추가합니다.
  const formData = new FormData(form);
  selectedFiles.forEach((file, index) => {
      formData.append('fileName[]', file);
  });

  // AJAX를 통해 폼 데이터를 서버로 보냅니다.
  fetch(form.action, {
      method: 'POST',
      body: formData
  })
  .then(response => {
      if (!response.ok) {
          throw new Error('리뷰 작성 실패');
      }
      // 성공적으로 완료되면 페이지를 리다이렉트합니다.
      window.location.href = '${contextPath}/member/myPage';
  })
  .catch(error => {
      alert(error.message);
      // 실패 시 리뷰 작성 페이지로 다시 이동
      window.location.href = '${contextPath}/review/reviewForm?memberId=' + form.memberId.value + '&storeId=' + form.storeId.value + '&reservationId=' + form.reservationId.value + '&waitingId=' + form.waitingId.value + '&error=true';
  });

  return false; // 기본 폼 제출을 막습니다.
}
</script>


<div class="storeInfo">
	<img src="${contextPath }/download?directoryName=store&fileName=${storeInfo.fileName}" alt="${storeInfo.fileName }">
	<h4>${storeInfo.storeName }</h4>
	<h2>리뷰를 수정해 주세요.</h2>
</div>

<div style="display: flex; flex-direction: column; align-items: center; min-height: 100vh;">
	<%-- 폼의 action을 수정 또는 삭제 기능으로 변경해야 함 --%>
	<form action="${contextPath}/review/modifyReview" method="post" enctype="multipart/form-data" onsubmit="return checkReview()">
		<%-- review 객체에서 값을 가져와 hidden 필드에 넣습니다. --%>
		<input type="hidden" name="reviewId" value="${review.reviewId}" />
		<input type="hidden" name="memberId" value="${review.memberId}" />
		<input type="hidden" name="storeId" value="${review.storeId}" />
		
		<c:choose>
			<c:when test="${not empty review.reservationId}">
				<input type="hidden" name="reservationId" value="${review.reservationId}" />
			</c:when>
			<c:otherwise>
				<input type="hidden" name="waitingId" value="${review.waitingId}" />
			</c:otherwise>
		</c:choose>
		
		<div class="form-row" style="display: flex; flex-direction: column; margin-bottom: 10px; align-items: center;">
			<div class="form-input" style="flex: 1;">
				<div class="star-rating">
					<input type="radio" id="star5" name="rating" value="5" ${review.rating eq 5 ? 'checked' : ''} />
					<label for="star5" title="5점">★</label>
					<input type="radio" id="star4" name="rating" value="4" ${review.rating eq 4 ? 'checked' : ''} />
					<label for="star4" title="4점">★</label>
					<input type="radio" id="star3" name="rating" value="3" ${review.rating eq 3 ? 'checked' : ''} />
					<label for="star3" title="3점">★</label>
					<input type="radio" id="star2" name="rating" value="2" ${review.rating eq 2 ? 'checked' : ''} />
					<label for="star2" title="2점">★</label>
					<input type="radio" id="star1" name="rating" value="1" ${review.rating eq 1 ? 'checked' : ''} />
					<label for="star1" title="1점">★</label>
				</div>
			</div>
			<h4 id="rating-message">별점을 선택해주세요</h4>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;">
			<div class="form-input" style="flex: 1;">
				<%-- 리뷰 내용 미리 채우기 --%>
				<textarea id="content" name="content" rows="5" cols="100" >${review.content}</textarea>
			</div>
		</div>
				<%-- 이미지 미리보기 로직 --%>
		<c:if test="${not empty imglist}">
		<script>
			document.addEventListener('DOMContentLoaded', function() {
				const preview = document.getElementById('imagePreview');
				const imageFiles = [
					<c:forEach var="image" items="${imglist}" varStatus="loop">
						'${contextPath}/download?fileName=${image.fileName}&directoryName=review'
						<c:if test="${not loop.last}">,</c:if>
					</c:forEach>
				];
				
				imageFiles.forEach(src => {
					const item = document.createElement('div');
					item.className = 'image-preview-item';
		
					const img = document.createElement('img');
					img.src = src;
		
					const removeBtn = document.createElement('span');
					removeBtn.className = 'remove-image';
					removeBtn.innerHTML = '&times;';
		
					// 삭제 버튼 로직 추가 필요
					removeBtn.onclick = function() {
						// 서버에서 이미지를 삭제하거나, 제출 시 삭제할 목록에 추가하는 로직
						item.remove();
					};
		
					item.appendChild(img);
					item.appendChild(removeBtn);
					preview.appendChild(item);
				});
			});
		</script>
		</c:if>
		
		<div class="form-row" style="display: flex; flex-direction: column; margin-bottom: 10px; align-items: center;">
			<div class="form-input" style="flex: 1;">
				<%-- 파일 업로드 부분은 그대로 유지 --%>
				<input type="file" id="fileName" name="fileName" accept="image/*" multiple="multiple" onchange="previewReviewImage(this)" />
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
					<input type="radio" id="taste-1" name="taste" value="1" ${review.taste eq 1 ? 'checked' : ''}><label for="taste-1">최악</label>
					<input type="radio" id="taste-2" name="taste" value="2" ${review.taste eq 2 ? 'checked' : ''}><label for="taste-2">별로</label>
					<input type="radio" id="taste-3" name="taste" value="3" ${review.taste eq 3 ? 'checked' : ''}><label for="taste-3">보통</label>
					<input type="radio" id="taste-4" name="taste" value="4" ${review.taste eq 4 ? 'checked' : ''}><label for="taste-4">만족</label>
					<input type="radio" id="taste-5" name="taste" value="5" ${review.taste eq 5 ? 'checked' : ''}><label for="taste-5">최고</label>
				</div>
			</div>
			
			<div class="rating-group">
				<div class="rating-label">분위기는 어떤가요?</div>
				<div class="rating-options">
					<input type="radio" id="mood-1" name="mood" value="1" ${review.mood eq 1 ? 'checked' : ''}><label for="mood-1">최악</label>
					<input type="radio" id="mood-2" name="mood" value="2" ${review.mood eq 2 ? 'checked' : ''}><label for="mood-2">별로</label>
					<input type="radio" id="mood-3" name="mood" value="3" ${review.mood eq 3 ? 'checked' : ''}><label for="mood-3">보통</label>
					<input type="radio" id="mood-4" name="mood" value="4" ${review.mood eq 4 ? 'checked' : ''}><label for="mood-4">만족</label>
					<input type="radio" id="mood-5" name="mood" value="5" ${review.mood eq 5 ? 'checked' : ''}><label for="mood-5">최고</label>
				</div>
			</div>
			
			<div class="rating-group">
				<div class="rating-label">서비스는 친절했나요?</div>
				<div class="rating-options">
					<input type="radio" id="service-1" name="service" value="1" ${review.service eq 1 ? 'checked' : ''}><label for="service-1">최악</label>
					<input type="radio" id="service-2" name="service" value="2" ${review.service eq 2 ? 'checked' : ''}><label for="service-2">별로</label>
					<input type="radio" id="service-3" name="service" value="3" ${review.service eq 3 ? 'checked' : ''}><label for="service-3">보통</label>
					<input type="radio" id="service-4" name="service" value="4" ${review.service eq 4 ? 'checked' : ''}><label for="service-4">만족</label>
					<input type="radio" id="service-5" name="service" value="5" ${review.service eq 5 ? 'checked' : ''}><label for="service-5">최고</label>
				</div>
			</div>
			
			<div class="rating-group">
				<div class="rating-label">매장 청결상태는 양호한가요?</div>
				<div class="rating-options">
					<input type="radio" id="clean-1" name="clean" value="1" ${review.clean eq 1 ? 'checked' : ''}><label for="clean-1">최악</label>
					<input type="radio" id="clean-2" name="clean" value="2" ${review.clean eq 2 ? 'checked' : ''}><label for="clean-2">별로</label>
					<input type="radio" id="clean-3" name="clean" value="3" ${review.clean eq 3 ? 'checked' : ''}><label for="clean-3">보통</label>
					<input type="radio" id="clean-4" name="clean" value="4" ${review.clean eq 4 ? 'checked' : ''}><label for="clean-4">만족</label>
					<input type="radio" id="clean-5" name="clean" value="5" ${review.clean eq 5 ? 'checked' : ''}><label for="clean-5">최고</label>
				</div>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-top: 20px;">
			<input type="submit" value="리뷰 수정" />
		</div>
	</form>
</div>