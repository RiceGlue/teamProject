<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

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
input[type="submit"] { width: 100%; padding: 12px 0; background: none; border: 1.5px solid #444; border-radius: 8px; font-weight: 600; font-size: 1.1rem; cursor: pointer; transition: background-color 0.2s ease-in-out; }
input[type="submit"]:hover { background-color: #f0f0f0; }
.storeRating {display: flex; flex-direction: column; gap: 30px; margin-top: 30px;}
.rating-group {display: flex; flex-direction: column; align-items: center; gap: 10px;}
.rating-label {font-weight: bold; font-size: 1rem;}
.rating-options {display: flex; gap: 10px; flex-wrap: wrap; justify-content: center;}
.rating-options input[type="radio"] {display: none;}
.rating-options label {padding: 8px 14px; border: 1px solid #ccc; border-radius: 20px; font-size: 0.9rem; cursor: pointer; color: #333; background-color: #f9f9f9; transition: all 0.2s ease-in-out;}
.rating-options input[type="radio"]:checked + label {border-color: #000; font-weight: bold; background-color: #eaeaea;}
#errorMessage { color: red; font-size: 0.9em; text-align: center; margin-bottom: 10px; }
</style>


<script>
let selectedFiles = [];     // 새로 추가한 파일 객체
let existingImages = [];    // 서버에서 불러온 기존 이미지 파일 이름
let deleteFiles = [];       // 삭제할 기존 파일 이름

// 기존 이미지 로딩 스크립트
document.addEventListener('DOMContentLoaded', function () {
    const preview = document.getElementById('imagePreview');
    const imglist = ${!empty imglist ? "true" : "false"};

    if (imglist) {
        const imageFiles = [
            <c:forEach var="image" items="${imglist}" varStatus="loop">
            { src: '${contextPath}/download?fileName=${image.fileName}&directoryName=review', fileName: '${image.fileName}' }
            <c:if test="${!loop.last}">,</c:if>
            </c:forEach>
        ];

        imageFiles.forEach(({ src, fileName }) => {
            existingImages.push(fileName); // 기존 파일 이름 저장

            const item = document.createElement('div');
            item.className = 'image-preview-item';

            const img = document.createElement('img');
            img.src = src;

            const removeBtn = document.createElement('span');
            removeBtn.className = 'remove-image';
            removeBtn.innerHTML = '&times;';

            // 기존 파일 삭제 로직
            removeBtn.onclick = function () {
                deleteFiles.push(fileName);
                existingImages = existingImages.filter(f => f !== fileName);
                item.remove();
            };

            item.appendChild(img);
            item.appendChild(removeBtn);
            preview.appendChild(item);
        });
    }
});

function previewReviewImage(input) {
    const files = Array.from(input.files);
    const preview = document.getElementById('imagePreview');
    const maxImages = 5;

    let totalImages = existingImages.length + selectedFiles.length;

    console.log("이벤트 발생 - 선택한 files:", files.map(f => f.name));

    files.forEach(file => {
        const canAdd = totalImages < maxImages;

        if (canAdd) {
            const isDuplicate = selectedFiles.some(f => f.name === file.name && f.size === file.size);
            console.log(`파일: ${file.name}, 중복 여부: ${isDuplicate}`);

            if (!isDuplicate) {
                selectedFiles.push(file);
                totalImages++;

                const reader = new FileReader();
                reader.onload = function (e) {
                    const item = document.createElement('div');
                    item.className = 'image-preview-item';

                    const img = document.createElement('img');
                    img.src = e.target.result;

                    const removeBtn = document.createElement('span');
                    removeBtn.className = 'remove-image';
                    removeBtn.innerHTML = '&times;';

                    // 새로 추가한 파일 삭제 로직
                    removeBtn.onclick = function () {
                        selectedFiles = selectedFiles.filter(f => !(f.name === file.name && f.size === file.size));
                        item.remove();
                        console.log("파일 제거됨:", file.name);
                    };

                    item.appendChild(img);
                    item.appendChild(removeBtn);
                    preview.appendChild(item);
                };
                reader.readAsDataURL(file);
            }
        } else {
            alert("최대 5개의 이미지만 업로드할 수 있습니다.");
        }
    });
    // 같은 파일 다시 선택 가능하게
    input.value = '';
}

function clearImages() {
    const preview = document.getElementById('imagePreview');
    preview.innerHTML = '';

    deleteFiles = deleteFiles.concat(existingImages); // 기존 이미지들 삭제 처리
    selectedFiles = [];
    existingImages = [];

    const fileInput = document.getElementById('fileName');
    if (fileInput) {
        fileInput.value = '';
    }

    console.log("전체 이미지 삭제됨");
}

function checkReview() {
    const form = document.querySelector('form');
    const formData = new FormData(form);

    const rating = document.querySelector('input[name="rating"]:checked');
    const content = document.getElementById('content').value.trim();
    const errorMessage = document.getElementById('errorMessage');

    errorMessage.textContent = ''; // 초기화

    if (!rating) {
        errorMessage.textContent = "별점을 선택해주세요.";
        return false;
    }

    if (content.length < 5) {
        errorMessage.textContent = "리뷰 내용은 5자 이상 입력해야 합니다.";
        return false;
    }

    // 새로 추가된 파일 append
    selectedFiles.forEach(file => {
        formData.append('fileName[]', file);
    });

    // 삭제할 기존 파일 append
    deleteFiles.forEach(fileName => {
        formData.append('deleteFileName', fileName);
    });

    console.log("전송 직전 - selectedFiles:", selectedFiles.map(f => f.name));
    console.log("전송 직전 - deleteFiles:", deleteFiles);

    fetch(form.action, {
        method: 'POST',
        body: formData
    })
    .then(response => {
        if (!response.ok) {
            return response.json().then(errorData => {
                throw new Error(errorData.message || '리뷰 수정 실패');
            });
        }
        return response.json();
    })
    .then(data => {
        alert("리뷰 수정 완료"); // "리뷰 수정 완료"
        location.reload(); // 새로고침하여 수정된 내용 바로 반영
    })
    .catch(error => {
        document.getElementById('errorMessage').textContent = "리뷰 수정 실패: " + error.message;
    });
    
    // Ajax를 사용하므로 폼 제출을 막아야 함
    return false;
}
</script>

<div class="storeInfo">
    <img src="${contextPath }/download?directoryName=store&fileName=${storeInfo.fileName}" alt="${storeInfo.fileName }">
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