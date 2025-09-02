<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<style>
body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f9f9f9; margin: 0; padding: 0; }
.storeInfo { text-align: center; padding: 40px 20px 20px 20px; background-color: #fff; border-bottom: 1px solid #e0e0e0; }
.storeInfo img { width: 120px; height: 120px; object-fit: cover; border-radius: 50%; box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
.storeInfo h4 { font-size: 22px; color: #333; margin: 10px 0 5px; }
.storeInfo h2 { font-size: 26px; font-weight: 600; color: #444; margin: 10px 0; }
form { width: 95%; max-width: 750px; margin: 30px auto; border-radius: 12px; padding: 30px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05); }
.form-row { margin-bottom: 20px; display: flex; flex-direction: column; align-items: center; }
.star-rating { direction: rtl; display: flex; justify-content: center; font-size: 2.2rem; gap: 5px; }
.star-rating input[type="radio"] { display: none; }
.star-rating label { color: #ccc; cursor: pointer; transition: color 0.2s; }
.star-rating input[type="radio"]:checked ~ label { color: #FFD700; }
.star-rating label:hover, .star-rating label:hover ~ label { color: #FFD700; }
#rating-message { font-size: 16px; color: #666; margin-top: 10px; }
textarea#content { width: 100%; max-width: 100%; padding: 14px; border: 1px solid #ddd; border-radius: 8px; resize: vertical; font-size: 16px; background-color: #fafafa; }
.storeRating { margin-top: 30px; }
.rating-group { margin-bottom: 20px;  margin:40px; }
.rating-label { text-align: center; font-weight: bold; font-size: 16px; color: #444; margin-bottom: 8px; }
.rating-options { display: flex; flex-wrap: wrap; gap: 50px; justify-content:center; }
.rating-options input[type="radio"] { display: none; }
.rating-options label { background-color: #eee; padding: 8px 16px; border-radius: 20px; cursor: pointer; transition: background-color 0.2s, color 0.2s; }
.rating-options input[type="radio"]:checked + label { background-color: #2196F3; color: white; }
.btn { border: none; padding: 14px 30px; border-radius: 8px; cursor: pointer; font-size: 16px; transition: background-color 0.2s; color: white; }
.btn-primary { background-color: #1976D2; }
.btn-primary:hover { background-color: #1565C0; }
.btn-warning { background-color: #FFC107; }
.btn-warning:hover { background-color: #E0A800; }
.btn-danger { background-color: #DC3545; }
.btn-danger:hover { background-color: #C82333; }
.image-container-wrapper { display: flex; flex-wrap: wrap; justify-content: space-between; gap: 20px; padding: 20px; border-radius: 8px; margin: 20px 0; width: 100%; box-sizing: border-box; }
.image-section { flex: 1; min-width: 250px; display: flex; flex-direction: column; align-items: center; }
#existingImageContainer.image-row { flex-direction: column; flex-wrap: nowrap; gap: 10px; }
#newImageContainer.image-row { flex-direction: row; flex-wrap: wrap; gap: 15px; }
.image-item-container { display: flex; align-items: center; gap: 10px; padding: 10px; border-radius: 8px; }
.image-item-container img { width: 120px; height: 120px; object-fit: cover; border-radius: 6px; }
.image-item-container .remove-button { background-color: #f44336; color: white; border: none; border-radius: 5px; padding: 8px 12px; cursor: pointer; font-size: 14px; }
.image-item-container .file-label { background-color: #007bff; color: white; padding: 8px 12px; border-radius: 5px; cursor: pointer; font-size: 14px; }
.image-buttons { margin-top: 20px; display: flex; justify-content: center; align-items: center; gap: 10px; width: 100%; }
.deleted-image-inputs { text-align: center; margin-top: 20px; }
</style>

<script>
    // 삭제할 이미지 ID를 저장하는 배열
    let deleteFiles = []; 

    // 업로드 가능한 최대 이미지 수
    const maxImages = 5;

    // 페이지 로딩 완료 후 실행
    document.addEventListener('DOMContentLoaded', function () {
        const imglistExists = ${!empty imglist ? "true" : "false"};

        // 기존 이미지가 있을 경우 화면에 표시
        if (imglistExists) {
            const imageFiles = [
                <c:forEach var="image" items="${imglist}" varStatus="loop">
                {
                    src: '${contextPath}/images/review/${image.fileName}',
                    fileName: '${image.fileName}',
                    imageId: '${image.imageId}'
                }
                <c:if test="${!loop.last}">,</c:if>
                </c:forEach>
            ];

            imageFiles.forEach(({ src, fileName, imageId }) => {
                createExistingImageItem(src, fileName, imageId); 
            });
        }

        // 별점이 선택되어 있으면 해당 메시지 출력
        const rating = document.querySelector('input[name="rating"]:checked');
        if (rating) {
            updateRatingMessage(parseInt(rating.value));
        }

        // 별점 변경 시 메시지 업데이트
        const ratingInputs = document.querySelectorAll('input[name="rating"]');
        ratingInputs.forEach(input => {
            input.addEventListener('change', function () {
                updateRatingMessage(parseInt(this.value));
            });
        });
    });

    // 기존 이미지를 화면에 추가하는 함수
    function createExistingImageItem(src, fileName, imageId) {
        const container = document.getElementById('existingImageContainer');
        const item = document.createElement('div');
        item.className = 'image-item-container';
        item.setAttribute('data-file-name', fileName);
        item.setAttribute('data-image-id', imageId); 

        const img = document.createElement('img');
        img.src = src;

        const removeBtn = document.createElement('button');
        removeBtn.type = 'button';
        removeBtn.className = 'remove-button';
        removeBtn.textContent = '삭제';

        // 삭제 버튼 클릭 시 해당 이미지 삭제 처리
        removeBtn.onclick = function () {
            const idToDelete = item.dataset.imageId; 
            // 삭제할 이미지 ID 배열에 추가
            if (idToDelete) {
                // 중복 추가 방지
                if (!deleteFiles.includes(idToDelete)) {
                    deleteFiles.push(idToDelete);
                    createDeletedImageInput(idToDelete); // 바로 input 생성
                    console.log("삭제할 이미지 ID:", idToDelete);
                }
            }
            // 화면에서 이미지 제거
            item.remove();
            console.log("삭제 목록:", deleteFiles);
        };

        item.appendChild(img);
        item.appendChild(removeBtn);
        container.appendChild(item);
    }

    // 삭제된 이미지 ID를 표시하는 input을 동적으로 생성
    function createDeletedImageInput(imageId) {
        const container = document.getElementById('deletedImageInputsContainer');
        const input = document.createElement('input');
        input.type = 'hidden'; // 테스트용으로 'text'
        input.name = 'deleteFiles';
        input.value = imageId;
        container.appendChild(input);
    }
    
    // 새로운 이미지 input 추가
    function addNewImageInput() {
        const existingCount = document.querySelectorAll('#existingImageContainer .image-item-container').length;
        const newCount = document.querySelectorAll('#newImageContainer .image-item-container').length;
        const totalImages = existingCount + newCount;

        if (totalImages >= maxImages) {
            alert(`최대 ${maxImages}개의 이미지만 업로드할 수 있습니다.`);
            return;
        }

        const container = document.getElementById('newImageContainer');

        const item = document.createElement('div');
        item.className = 'image-item-container new-file-item';

        const fileInput = document.createElement('input');
        fileInput.type = 'file';
        fileInput.name = 'newFiles';
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

        // 파일 선택 시 미리보기 표시
        fileInput.onchange = function (e) {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function (e) {
                    img.src = e.target.result;
                    img.style.display = 'block';
                    fileLabel.style.display = 'none';
                    removeBtn.style.display = 'inline-block';
                };
                reader.readAsDataURL(file);
            }
        };

        // 삭제 버튼 클릭 시 항목 제거
        removeBtn.onclick = function () {
            item.remove(); 
        };

        item.appendChild(fileInput);
        item.appendChild(img);
        item.appendChild(fileLabel);
        item.appendChild(removeBtn);
        container.appendChild(item);
    }

    // 새로 추가한 이미지 모두 제거
    function clearNewImages() {
        const container = document.getElementById('newImageContainer');
        container.innerHTML = '';
    }

    // 폼 유효성 검사 (삭제 input은 이미 생성되었으므로 여기서는 유효성 검사만)
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
        
        return true;
    }


    // 별점에 따라 안내 문구 표시
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

    // 리뷰 삭제 요청 전 확인 창 띄우고 처리
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
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

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
        
        <div id="deletedImageInputsContainer" class="deleted-image-inputs"></div>

        <div class="image-container-wrapper" style="text-align:center;">
            <c:if test="${not empty imglist}">
                <div class="image-section">
                    <h4>기존 이미지</h4>
                    <div id="existingImageContainer" class="image-row">
                    </div>
                </div>
            </c:if>
            
            <div class="image-section">
                <h4>추가할 이미지</h4>
                <div id="newImageContainer" class="image-row">
                </div>
            </div>
            
            <div class="image-buttons">
                <button type="button" class="btn btn-primary" onclick="addNewImageInput()">새로운 이미지 추가</button>
                <button type="button" class="btn btn-danger" onclick="clearNewImages()">전체 이미지 삭제</button>
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

        <div style="display: flex; align-items: center; gap:10px; justify-content:center;">
            <input type="button" class="btn btn-danger" onclick="confirmDelete(${review.reviewId})" value="리뷰 삭제">
            <input type="submit" class="btn btn-primary" value="리뷰 수정" />
        </div>
    </form>
</div>