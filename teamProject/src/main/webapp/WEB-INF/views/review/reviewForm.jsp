<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:if test="${param.error eq 'true'}">
    <script>alert("리뷰 작성 실패");</script>
</c:if>

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
	debugger;
	console.log('✅ checkReview() 함수 시작');

  const form = document.querySelector('form');

  const ratingInputs = document.querySelectorAll('input[name="rating"]');
  if (![...ratingInputs].some(r => r.checked)) {
    alert('별점을 선택해주세요.');
    return false; // form.submit() 대신 false 반환
  }

//   const content = form.content.value.trim();
//   if (content.length < 10) {
//     alert('리뷰 내용을 10자 이상 작성해주세요.');
//     form.content.focus();
//     return false;
//   }

  //const content = form.content.value.trim();

  const contentElement = document.getElementById('content'); // ✨ ID로 직접 요소 가져오기
  const content = contentElement.value.trim(); // ✨ 가져온 요소의 value에 접근
  if (content.length < 10) {
      console.log('리뷰 내용이 10자 미만입니다. return false를 실행합니다.');
      form.content.focus();
      return false; // 이 줄이 실행되는지 확인하세요.
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
  console.log('✅ fetch 요청 시작');
  fetch(form.action, {
	    method: 'POST',
	    body: formData
	})
	.then(response => {
		console.log('✅ fetch 응답 받음:', response.status);
	    // HTTP 응답이 성공적인지 확인
	    if (!response.ok) {
	        throw new Error('네트워크 응답이 실패했습니다.');
	    }
	    // 응답 본문을 텍스트로 먼저 변환하여 오류를 방지
	    return response.text();
	})
	.then(text => {
	    try {
	    	console.log('✅ 서버 응답 텍스트:', text);
	        // 텍스트를 JSON으로 파싱 시도
	        const data = JSON.parse(text);
	        console.log('✅ JSON 파싱 성공:',data); // 서버가 보낸 데이터를 콘솔에 출력
	        if (data.success) {
	            alert(data.message);
	            window.location.href='${contextPath}/member/mypage';
	        } else {
	            alert(data.message);
	            window.history.back();
	        }
	    } catch (e) {
	        // JSON 파싱 오류 발생 시
	        console.error('JSON 파싱 오류:', e);
	        console.error('서버 응답 텍스트:', text);
	        alert("서버 응답을 처리하는 중 오류가 발생했습니다.");
	    }
	})
	.catch(error => {
	    alert("요청 중 오류 발생: " + error.message);
	    console.error("Fetch error:", error);
	    window.history.back();
	});

  return false; // 기본 폼 제출을 막습니다.
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

		<div class="form-row" style="display: flex; flex-direction: column; margin-bottom: 10px; align-items: center;">
			<div class="form-input" style="flex: 1;">
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