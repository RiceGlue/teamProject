<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${param.success eq 'true'}">
    <script>alert("수정 완료!");</script>
</c:if>
<c:if test="${param.error eq 'true'}">
    <script>alert("수정 실패!");</script>
</c:if>

<script>

function previewImage(file, index) {
	const previewDiv = document.getElementById("preview" + index);
	const reader = new FileReader();
	reader.onload = function(e) { previewDiv.innerHTML = '<img src="' + e.target.result + '" style="max-width: 200px; max-height: 200px;" />'; };
	reader.readAsDataURL(file);
}

function validateImages(input, index) {
	const files = input.files;
	const maxFiles = 20;
	const maxSizeInBytes = 2 * 1024 * 1024;
	const maxResolution = 500;
	
	if (files.length > maxFiles) {
		alert(`최대 ${maxFiles}개까지만 업로드할 수 있습니다.`);
		resetInput(input);
		return;
	}
	
	let errorMessage = null;
	for (let i = 0; i < files.length; i++) {
		const file = files[i];
		if (!file.type.startsWith("image/")) {
			errorMessage = "이미지 파일만 업로드할 수 있습니다.";
			break;
		}
		if (file.size > maxSizeInBytes) {
			errorMessage = `각 파일 크기는 최대 2MB 이하여야 합니다. (${file.name})`;
			break;
		}
	}
	
	if (errorMessage) {
		alert(errorMessage);
		resetInput(input);
		return;
	}
	
	const promises = [];
	for (let i = 0; i < files.length; i++) { promises.push(checkImageResolution(files[i], maxResolution)); }
	
	Promise.all(promises).then(results => {
		if (results.includes(false)) {
			alert(`모든 이미지의 해상도는 최대 ${maxResolution}x${maxResolution} 픽셀을 초과할 수 없습니다.`);
			resetInput(input);
		} else { previewImage(files[0], index); }
	});
}

function checkImageResolution(file, maxResolution) {
	return new Promise((resolve) => {
		const img = new Image();
		img.onload = function() { resolve(img.width <= maxResolution && img.height <= maxResolution); };
		img.onerror = function() { resolve(false); };
		img.src = URL.createObjectURL(file);
	});
}

function resetInput(input) {
	input.value = "";
	const previewId = input.getAttribute("onchange").match(/\d+/)[0];
	document.getElementById("preview" + previewId).innerHTML = "";
}

function submitMenu(index) {
	const form = document.getElementById("menuForm" + index);
	const formData = new FormData(form);

	fetch("/modifyMenu", {
		method: "POST",
		body: formData
	}).then(res => res.json())
	.then(data => {
		if (data.success) { alert("메뉴가 성공적으로 수정되었습니다."); }
		else { alert("수정 실패: " + (data.message || "알 수 없는 오류"));  }
	}).catch(err => { alert("에러 발생: " + err);});
}
</script>

<h1>메뉴 수정</h1>
<input type="hidden" id="storeId" name="storeId" value="${storeId}">

<c:forEach var="menu" items="${menuList}" varStatus="status">
	<form action="/updateMenu" method="post" enctype="multipart/form-data">
		<input type="hidden" name="menuId" value="${menu.menuId}" />
		
		<div class="info_container" style="max-width: 700px; border: 1px solid #ccc; padding: 15px; margin-bottom: 20px; border-radius:10px;">
			<p><strong>${menu.displayNo + 1}</strong></p>
			
			<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
				<div class="form-label" style="width: 200px;">메뉴 이름</div>
				<div class="form-input" style="flex: 1;">
					<input id="menuName${status.index}" name="menuName" type="text" maxLength="15" value="${menu.menuName}" required />
				</div>
			</div>
			
			<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
				<div class="form-label" style="width: 200px;">메뉴 가격</div>
				<div class="form-input" style="flex: 1;">
					<input id="price${status.index}" name="price" type="text" value="${menu.price}" required />
				</div>
			</div>
			
			<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
				<div class="form-label" style="width: 200px;">메뉴 설명</div>
				<div class="form-input" style="flex: 1;">
					<textarea id="description${status.index}" name="description" rows="2" cols="40" required>${menu.description}</textarea>
				</div>
			</div>
			
			<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;">
				<div class="form-label" style="width: 200px;">현재 이미지</div>
				<div class="form-input" style="flex: 1;">
					<img src="${menu.fileName}" alt="${menu.menuName}" style="max-width: 200px;" />
				</div>
			</div>
			
			<div class="form-row" style="display: flex; margin-bottom: 15px; align-items: flex-start;">
				<div class="form-label" style="width: 200px;">이미지 변경</div>
				<div class="form-input" style="flex: 1;">
					<input type="file" name="imageFile" accept="image/*" onchange="validateImages(this, ${status.index})" />
					<div class="image-preview" id="preview${status.index}" style="margin-top: 10px;"></div>
				</div>
			</div>
			
			<div class="form-row" style="text-align: right;">
			<button type="submit">수정하기</button>
			</div>
		</div>
	</form>
</c:forEach>
