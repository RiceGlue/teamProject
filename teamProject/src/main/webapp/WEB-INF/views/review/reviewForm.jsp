<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f9f9f9; margin: 0; padding: 0; }

.storeInfo { text-align: center; padding: 40px 20px 20px 20px; background-color: #fff; border-bottom: 1px solid #e0e0e0; }
.storeInfo img { width: 120px; height: 120px; object-fit: cover; border-radius: 50%; box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
.storeInfo h4 { font-size: 22px; color: #333; margin: 10px 0 5px; }
.storeInfo h2 { font-size: 26px; font-weight: 600; color: #444; margin: 10px 0; }

form { width: 95%; max-width: 750px; margin: 30px auto; background-color: #fff; border-radius: 12px; padding: 30px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05); }

.form-row { margin-bottom: 20px; display: flex; flex-direction: column; align-items: center; }

.star-rating { direction: rtl; display: flex; justify-content: center; font-size: 2.2rem; gap: 5px; }
.star-rating input[type="radio"] { display: none; }
.star-rating label { color: #ccc; cursor: pointer; transition: color 0.2s; }
.star-rating input[type="radio"]:checked ~ label { color: #FFD700; }
.star-rating label:hover, .star-rating label:hover ~ label { color: #FFD700; }

#rating-message { font-size: 16px; color: #666; margin-top: 10px; }

textarea#content { width: 100%; max-width: 100%; padding: 14px; border: 1px solid #ddd; border-radius: 8px; resize: vertical; font-size: 16px; background-color: #fafafa; }

#imagePreview { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 10px; justify-content: center; }
#imagePreview img { width: 100px; height: 100px; object-fit: cover; border-radius: 6px; border: 1px solid #ccc; }

.clear-button-container { margin-top: 10px; text-align: center; }
.clear-images-button { background-color: #e53935; color: white; padding: 6px 12px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; transition: background-color 0.2s; }
.clear-images-button:hover { background-color: #c62828; }

.storeRating { margin-top: 30px; }
.rating-group { margin-bottom: 20px; }
.rating-label { font-weight: bold; font-size: 16px; color: #444; margin-bottom: 8px; }
.rating-options { display: flex; flex-wrap: wrap; gap: 10px; }
.rating-options input[type="radio"] { display: none; }
.rating-options label { background-color: #eee; padding: 8px 16px; border-radius: 20px; cursor: pointer; transition: background-color 0.2s, color 0.2s; }
.rating-options input[type="radio"]:checked + label { background-color: #2196F3; color: white; }

input[type="submit"] { background-color: #1976D2; color: white; border: none; padding: 14px 30px; border-radius: 8px; cursor: pointer; font-size: 16px; transition: background-color 0.2s; }
input[type="submit"]:hover { background-color: #1565C0; }

@media (max-width: 600px) {
  form { padding: 20px; }
  .rating-options { justify-content: center; }
  .storeInfo img { width: 90px; height: 90px; }
  .star-rating { font-size: 1.8rem; }
  textarea#content { font-size: 15px; }
}
</style>

<script>
const contextPath = '${contextPath}';

let imageCount = 0;
const maxImages = 5;

// 별점 선택에 따라 메시지 업데이트
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

// 페이지 로드 시 별점 이벤트 리스너 등록
document.addEventListener('DOMContentLoaded', function () {
  const ratingInputs = document.querySelectorAll('input[name="rating"]');
  ratingInputs.forEach(input => {
    input.addEventListener('change', function () {
      updateRatingMessage(parseInt(this.value));
    });
  });
});

// 이미지 인풋 추가
function addImageInput() {
  if (imageCount >= maxImages) {
    alert(`이미지는 최대 ${maxImages}장까지 업로드할 수 있습니다.`);
    return;
  }

  const container = document.getElementById('imageUploadContainer');

  const wrapper = document.createElement('div');
  wrapper.className = 'image-upload-wrapper';
  wrapper.style.display = 'flex';
  wrapper.style.alignItems = 'center';
  wrapper.style.gap = '10px';
  wrapper.style.marginBottom = '10px';

  const fileInput = document.createElement('input');
  fileInput.type = 'file';
  // 이 부분을 수정합니다.
  fileInput.name = 'reviewImage'; // 변경: reviewImage[] -> reviewImage
  fileInput.accept = 'image/*';
  fileInput.onchange = function () {
    showPreview(fileInput, previewImg);
  };

  const previewImg = document.createElement('img');
  previewImg.style.width = '100px';
  previewImg.style.height = '100px';
  previewImg.style.borderRadius = '6px';
  previewImg.style.border = '1px solid #ccc';
  previewImg.style.objectFit = 'cover';
  previewImg.style.display = 'none';

  const removeBtn = document.createElement('button');
  removeBtn.type = 'button';
  removeBtn.textContent = '삭제';
  removeBtn.style.backgroundColor = '#f44336';
  removeBtn.style.color = 'white';
  removeBtn.style.border = 'none';
  removeBtn.style.padding = '6px 10px';
  removeBtn.style.borderRadius = '6px';
  removeBtn.style.cursor = 'pointer';

  removeBtn.onclick = function () {
    container.removeChild(wrapper);
    imageCount--;
  };

  wrapper.appendChild(fileInput);
  wrapper.appendChild(previewImg);
  wrapper.appendChild(removeBtn);
  container.appendChild(wrapper);

  imageCount++;
}

// 이미지 미리보기 표시
function showPreview(input, imgElement) {
  if (input.files && input.files[0]) {
    const reader = new FileReader();
    reader.onload = function (e) {
      imgElement.src = e.target.result;
      imgElement.style.display = 'block';
    };
    reader.readAsDataURL(input.files[0]);
  }
}

// 전체 이미지 삭제
function clearAllImages() {
  const container = document.getElementById('imageUploadContainer');
  container.innerHTML = '';
  imageCount = 0;
}

// 리뷰 폼 유효성 검사
function checkReview() {
  const ratingInputs = document.querySelectorAll('input[name="rating"]');
  if (![...ratingInputs].some(r => r.checked)) {
    alert('별점을 선택해주세요.');
    return false;
  }

  const contentElement = document.getElementById('content');
  const content = contentElement.value.trim();
  if (content.length < 10) {
    alert('리뷰 내용은 최소 10자 이상 작성해주세요.');
    contentElement.focus();
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

  return true;
}
</script>


<div class="storeInfo">
	<img src="${contextPath }/images/store/${storeInfo.fileName}" alt="${storeInfo.fileName }">
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

		<div class="form-row" style="flex-direction: column; align-items: center;">
			<div id="imageUploadContainer"></div>
			<div style="margin-top: 10px;">
				<button type="button" onclick="addImageInput()" class="btn btn-primary">이미지 추가</button>
				<button type="button" class="btn btn-danger" onclick="clearAllImages()">전체 삭제</button>
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