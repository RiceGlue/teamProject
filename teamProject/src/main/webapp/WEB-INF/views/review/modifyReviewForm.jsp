<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<style>
/* 기존 스타일은 유지 */
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
.storeRating { margin-top: 30px; }
.rating-group { margin-bottom: 20px; }
.rating-label { font-weight: bold; font-size: 16px; color: #444; margin-bottom: 8px; }
.rating-options { display: flex; flex-wrap: wrap; gap: 10px; }
.rating-options input[type="radio"] { display: none; }
.rating-options label { background-color: #eee; padding: 8px 16px; border-radius: 20px; cursor: pointer; transition: background-color 0.2s, color 0.2s; }
.rating-options input[type="radio"]:checked + label { background-color: #2196F3; color: white; }
input[type="submit"] { background-color: #1976D2; color: white; border: none; padding: 14px 30px; border-radius: 8px; cursor: pointer; font-size: 16px; transition: background-color 0.2s; }
input[type="submit"]:hover { background-color: #1565C0; }

.image-row { display: flex; flex-direction: column; gap: 15px; margin-top: 20px; }
.image-item-container { display: flex; align-items: center; gap: 15px; justify-content: center; position: relative; border: 1px solid #ddd; padding: 10px; border-radius: 8px; }
.image-item-container img { width: 120px; height: 120px; object-fit: cover; border-radius: 6px; }
.image-item-container .remove-button { background-color: #f44336; color: white; border: none; border-radius: 5px; padding: 8px 12px; cursor: pointer; font-size: 14px; }
.image-item-container .file-label { background-color: #007bff; color: white; padding: 8px 12px; border-radius: 5px; cursor: pointer; font-size: 14px; }\
</style>

<script>
let selectedFiles = []; // 새로 추가된 이미지
let existingImages = []; // 서버에서 받아온 기존 이미지 목록 (변경/삭제 여부 상관없이 그대로 유지)
let deleteFiles = []; // 삭제 또는 변경된 기존 이미지의 파일 이름

document.addEventListener('DOMContentLoaded', function () {
    const imglistExists = ${!empty imglist ? "true" : "false"};

    if (imglistExists) {
        const imageFiles = [
            <c:forEach var="image" items="${imglist}" varStatus="loop">
            { src: '${contextPath}/images/review/${image.fileName}', fileName: '${image.fileName}' }
            <c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ];

        imageFiles.forEach(({ src, fileName }) => {
            existingImages.push(fileName); // 기존 이미지 배열은 삭제 여부와 무관하게 유지
            createImageModifyItem(src, fileName);
        });
    }

    const rating = document.querySelector('input[name="rating"]:checked');
    if (rating) {
        updateRatingMessage(parseInt(rating.value));
    }
});

// 기존 이미지 UI 생성 함수
function createImageModifyItem(src, fileName) {
    const container = document.getElementById('imageContainer');
    const item = document.createElement('div');
    item.className = 'image-item-container';

    const img = document.createElement('img');
    img.src = src;

    const fileInput = document.createElement('input');
    fileInput.type = 'file';
    fileInput.accept = 'image/*';
    fileInput.style.display = 'none';

    const fileLabel = document.createElement('label');
    fileLabel.htmlFor = 'fileInput-' + Date.now();
    fileLabel.className = 'file-label';
    fileLabel.textContent = '변경';

    const removeBtn = document.createElement('button');
    removeBtn.type = 'button';
    removeBtn.className = 'remove-button';
    removeBtn.textContent = '삭제';

    fileInput.onchange = function (e) {
        const newFile = e.target.files[0];
        if (newFile) {
            deleteFiles.push(fileName); // 삭제 목록에 추가
            selectedFiles.push(newFile); // 새로 선택한 파일 추가

            const reader = new FileReader();
            reader.onload = function (e) {
                img.src = e.target.result;
            };
            reader.readAsDataURL(newFile);

            console.log("Image changed. Existing (kept):", existingImages, "New:", selectedFiles, "Deleted:", deleteFiles);
        }
    };

    removeBtn.onclick = function () {
        deleteFiles.push(fileName);
        item.remove();
        console.log("Image removed. Existing (kept):", existingImages, "New:", selectedFiles, "Deleted:", deleteFiles);
    };

    fileLabel.onclick = function () {
        fileInput.click();
    };

    item.appendChild(img);
    item.appendChild(fileLabel);
    item.appendChild(fileInput);
    item.appendChild(removeBtn);
    container.appendChild(item);
}

// 새로운 이미지 추가
function addNewImageInput() {
    const container = document.getElementById('imageContainer');
    const maxImages = 5;
    const totalImages = existingImages.length + selectedFiles.length;

    if (totalImages >= maxImages) {
        alert(`최대 ${maxImages}개의 이미지만 업로드할 수 있습니다.`);
        return;
    }

    const item = document.createElement('div');
    item.className = 'image-item-container';

    const fileInput = document.createElement('input');
    fileInput.type = 'file';
    fileInput.name = 'fileName';
    fileInput.accept = 'image/*';
    fileInput.style.display = 'none';

    const uniqueId = 'newFile-' + Date.now();
    fileInput.id = uniqueId;

    const img = document.createElement('img');
    img.src = '';
    img.alt = '미리보기';
    img.style.display = 'none';

    const fileLabel = document.createElement('label');
    fileLabel.htmlFor = uniqueId;
    fileLabel.className = 'file-label';
    fileLabel.textContent = '파일 선택';

    const removeBtn = document.createElement('button');
    removeBtn.type = 'button';
    removeBtn.className = 'remove-button';
    removeBtn.textContent = '삭제';
    removeBtn.style.display = 'none';

    fileInput.onchange = function (e) {
        const file = e.target.files[0];
        if (file) {
            selectedFiles.push(file);

            const reader = new FileReader();
            reader.onload = function (e) {
                img.src = e.target.result;
                img.style.display = 'block';
                fileLabel.style.display = 'none';
                removeBtn.style.display = 'inline-block';
            };
            reader.readAsDataURL(file);

            console.log("New file added:", selectedFiles);
        }
    };

    removeBtn.onclick = function () {
        selectedFiles = selectedFiles.filter(f => f !== fileInput.files[0]);
        item.remove();
        console.log("New file removed:", selectedFiles);
    };

    item.appendChild(img);
    item.appendChild(fileLabel);
    item.appendChild(fileInput);
    item.appendChild(removeBtn);
    container.appendChild(item);
}

// 전체 이미지 삭제
function clearAllImages() {
    const container = document.getElementById('imageContainer');
    container.innerHTML = '';

    deleteFiles = deleteFiles.concat(existingImages); // 기존 이미지 모두 삭제 목록에 추가
    selectedFiles = [];

    console.log("All images removed. Deleted:", deleteFiles);
}

// 폼 전송 시 모든 데이터 hidden input으로 추가
function checkReview() {
    const rating = document.querySelector('input[name="rating"]:checked');
    const content = document.getElementById('content').value.trim();
    const errorMessage = document.getElementById('errorMessage');

    errorMessage.textContent = '';
    if (!rating) {
        errorMessage.textContent = "별점을 선택해주세요.";
        return false;
    }
    if (content.length < 5) {
        errorMessage.textContent = "리뷰 내용은 5자 이상 입력해야 합니다.";
        return false;
    }

    const form = document.querySelector('form');

    // ✅ 기존 이미지 전송
    existingImages.forEach(fileName => {
        const hiddenInput = document.createElement('input');
        hiddenInput.type = 'hidden';
        hiddenInput.name = 'existingFileNames';
        hiddenInput.value = fileName;
        form.appendChild(hiddenInput);
    });

    // ✅ 삭제된 이미지 전송
    deleteFiles.forEach(fileName => {
        const hiddenInput = document.createElement('input');
        hiddenInput.type = 'hidden';
        hiddenInput.name = 'deleteFileNames';
        hiddenInput.value = fileName;
        form.appendChild(hiddenInput);
    });

    // ✅ 새로 추가된 이미지 전송
    selectedFiles.forEach(file => {
        const fileInput = document.createElement('input');
        fileInput.type = 'file';
        fileInput.name = 'newFiles';

        const dataTransfer = new DataTransfer();
        dataTransfer.items.add(file);
        fileInput.files = dataTransfer.files;

        fileInput.style.display = 'none';
        form.appendChild(fileInput);
    });

    return true;
}

// 별점 메시지 갱신
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

// 별점 변경 감지
document.addEventListener('DOMContentLoaded', function () {
    const ratingInputs = document.querySelectorAll('input[name="rating"]');
    ratingInputs.forEach(input => {
        input.addEventListener('change', function () {
            updateRatingMessage(parseInt(this.value));
        });
    });
});

// 리뷰 삭제 확인
function confirmDelete(reviewId) {
    if (confirm('정말 이 리뷰를 삭제하시겠습니까?')) {
        const form = document.createElement('form');
        form.method = 'post';
        form.action = '${contextPath}/review/deleteReview';

        const reviewIdInput = document.createElement('input');
        reviewIdInput.type = 'hidden';
        reviewIdInput.name = 'reviewId';
        reviewIdInput.value = reviewId;

        form.appendChild(reviewIdInput);
        document.body.appendChild(form);
        form.submit();
    }
}
</script>

<div class="storeInfo">
    <img src="${contextPath }/images/store/${storeInfo.fileName}" alt="${storeInfo.fileName }">
    <h4>${storeInfo.storeName }</h4>
    <h2>리뷰를 수정해 주세요.</h2>
</div>

<div style="display: flex; flex-direction: column; align-items: center; min-height: 100vh;">
    <form action="${contextPath}/review/modifyReview" method="post" enctype="multipart/form-data" onsubmit="return checkReview()">
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
        
        <div id="errorMessage"></div>
        
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
                <textarea id="content" name="content" rows="5" cols="100" placeholder="리뷰 내용을 입력해주세요.">${review.content}</textarea>
            </div>
        </div>
        
        <div class="form-row" style="flex-direction: column; align-items: center;">
            <div id="imageContainer" class="image-row">
                </div>
            <div style="margin-top: 20px;">
                <button type="button" class="btn btn-primary" onclick="addNewImageInput()">새로운 이미지 추가</button>
                <button type="button" class="btn btn-danger" onclick="clearAllImages()">전체 이미지 삭제</button>
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
        
        <div class="form-row" style="display: flex; justify-content: space-between; align-items: center;">
            <input type="button" onclick="confirmDelete(${review.reviewId})" value="리뷰 삭제">
            <input type="submit" value="리뷰 수정" />
        </div>
    </form>
</div>