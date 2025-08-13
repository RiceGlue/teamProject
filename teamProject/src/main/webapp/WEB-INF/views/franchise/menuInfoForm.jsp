<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${param.success eq 'true'}">
    <script>alert("정보 등록 완료!");</script>
</c:if>
<c:if test="${param.error eq 'true'}">
    <script>alert("정보 등록 실패!");</script>
</c:if>

<script>
	$(document).ready(function() {
		$("#fileName0").on("change", function() {
			const fileName = this.files.length > 0 ? this.files[0].name : '선택된 파일 없음';
			$("#showFileName0").text(fileName);
		});
	});
	
	let menuIdx = 1;
	
	function addMenu() {
		const menuNameIdx = "menuName"+menuIdx;
		const priceIdx ="price"+menuIdx;
		const desIdx = "description"+menuIdx;
		const fileIdx = "fileName"+menuIdx;
		const fileNameIdx ="showFileName"+menuIdx;
		const previewIdx ="preview"+menuIdx;
		const displayNoIdx ="displayNo"+menuIdx;
		
		const html = 
		'<div class="menu-item" style="border-top:1px solid #ddd; padding-top:10px; margin-top:10px;">'+
		'<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">'+
		'<div class="form-label" style="width: 200px;">메뉴 이름</div>'+
		'<div class="form-input" style="flex: 1;">'+
		'<input id="'+ menuNameIdx +'" name="menuName" type="text" maxLength="15" />'+
		'</div></div>'+
		'<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">'+
		'<div class="form-label" style="width: 200px;">메뉴 가격</div>'+
		'<div class="form-input" style="flex: 1;">'+
		'<input id="'+priceIdx+'" name="price" type="text" maxLength="15" />'+
		'</div>'+
		'</div>'+
		'<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">'+
		'<div class="form-label" style="width: 200px;">메뉴 설명</div>'+
		'<div class="form-input" style="flex: 1;">'+
		'<textarea id="'+desIdx+'" name="description" rows="2" cols="40"></textarea>'+
		'</div>'+
		'<input type="hidden" id="'+displayNoIdx+'" name="displayNo" value="'+menuIdx+'" >'+
		'</div>'+
		'<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">'+
		'<div class="form-label" style="width: 200px;">메인 이미지</div>'+
		'<div class="form-input" style="flex: 1;">'+
		'<input type="file" id="'+fileIdx+'" name="fileName" accept="image/*" onchange="validateImages(this);" />'+
		'<label for="'+ fileIdx+'" style="cursor:pointer; background:#007bff; color:#fff; padding:5px 10px; border-radius:4px; margin-left: 10px;">파일 선택</label>'+
		'<span id="'+fileNameIdx+'" style="margin-left:10px; font-size:14px; color:#333;">선택된 파일 없음</span><br />'+
		'</div>'+
		'<div class="image-preview" style="max-width:200px;">'+
		'<img id="'+previewIdx+'" src="" style="max-width: 200px; display: block;" />'+
		'</div>'+
		'</div>'+
		'</div>' ;
		$("#moreMenu").append(html);
		
		console.log("현재 menuIdx:",menuNameIdx);
		
		menuIdx++;
	}
	
	function validateImages(input) {
		const files = input.files;
		const maxFiles = 20;
		const maxSizeInBytes = 2 * 1024 * 1024;
		const maxResolution = 500;
		
		const parentDiv = input.parentElement;
		const fileNameSpan = parentDiv.querySelector('span');
		if (fileNameSpan) { fileNameSpan.textContent = files.length > 0 ? files[0].name : '선택된 파일 없음'; }
		
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
				return;
			}
			
			if (files.length > 0) {
				const reader = new FileReader();
				reader.onload = function (e) {
					const imagePreviewDiv = input.closest('.form-row').querySelector('.image-preview');
					
					if (imagePreviewDiv) {
						// 기존 이미지 제거
						imagePreviewDiv.innerHTML = '';
						
						// 새로운 이미지 생성 및 삽입
						const img = document.createElement('img');
						img.src = e.target.result;
						img.style.maxWidth = '200px';
						img.style.display = 'block';
						
						imagePreviewDiv.appendChild(img);
					}
				};
				reader.readAsDataURL(files[0]);
			}
		});
	}
	
	// 해상도 체크 함수 (비동기)
	function checkImageResolution(file, maxResolution) {
		return new Promise((resolve) => {
			const reader = new FileReader();
			reader.onload = function (e) {
				const img = new Image();
				img.onload = function () {
					if (img.width > maxResolution || img.height > maxResolution) { resolve(false); }
					else { resolve(true); }
				};
				img.onerror = () => resolve(false);
				img.src = e.target.result;
			};
			reader.onerror = () => resolve(false);
			reader.readAsDataURL(file);
		});
	}
	
	function checkMenu() {
	    const form = document.querySelector('form');
	    const menuNames = form.querySelectorAll('input[name="menuName"]');
	    const prices = form.querySelectorAll('input[name="price"]');

	    if (menuNames.length === 0) {
	        alert("최소 하나 이상의 메뉴를 추가해 주세요.");
	        return false; // 폼 제출을 막음
	    }

	    for (let i = 0; i < menuNames.length; i++) {
	        const name = menuNames[i].value.trim();
	        const price = prices[i].value.trim();

	        if (name === '') {
	            alert(`메뉴 이름을 입력해 주세요 (항목 ${i + 1})`);
	            menuNames[i].focus();
	            return false; // 폼 제출을 막음
	        }
	        if (price === '') {
	            alert(`메뉴 가격을 입력해 주세요 (항목 ${i + 1})`);
	            prices[i].focus();
	            return false; // 폼 제출을 막음
	        }
	        if (isNaN(price) || Number(price) <= 0) {
	            alert(`유효한 메뉴 가격을 입력해 주세요 (숫자, 0 초과) (항목 ${i + 1})`);
	            prices[i].focus();
	            return false; // 폼 제출을 막음
	        }
	    }
	    
	    // 모든 검사를 통과했으므로 true를 반환하여 폼 제출 허용
	    return true; 
	}
</script>


<h1>정보 등록</h1>
<form action="${contextPath}/franchise/addMenuInfo" method="post" name="menuInfo" enctype="multipart/form-data" onsubmit="return checkMenu()">
	<input type="hidden" id="storeId" name="storeId" value="${storeId}">
	<input type="hidden" id="regId" name="regId" value="${ownerId}">
	
	<div class="info_container" style="max-width: 700px;">
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
			<div class="form-label" style="width: 200px;">메뉴 이름</div>
			<div class="form-input" style="flex: 1;">
				<input id="menuName0" name="menuName" type="text" maxLength="15" />
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
			<div class="form-label" style="width: 200px;">메뉴 가격</div>
			<div class="form-input" style="flex: 1;">
				<input id="price0" name="price" type="text" maxLength="15" />
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
			<div class="form-label" style="width: 200px;">메뉴 설명</div>
			<div class="form-input" style="flex: 1;">
				<textarea id="description0" name="description" rows="2" cols="40"></textarea>
			</div>
		</div>
		
		<input type="hidden" id="displayNo0" name="displayNo" value="0" >
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
			<div class="form-label" style="width: 200px;">메인 이미지</div>
			<div class="form-input" style="flex: 1;">
				<input type="file" id="fileName0" name="fileName" accept="image/*" onchange="validateImages(this);" >
				<label for="fileName0" style="cursor:pointer; background:#007bff; color:#fff; padding:5px 10px; border-radius:4px; margin-left: 10px;">파일 선택</label>
				<span id="showFileName0" style="margin-left:10px; font-size:14px; color:#333;">선택된 파일 없음</span>
				<br />
			</div>
			<div class="image-preview" style="max-width:200px;"></div>
		</div>
		
		<div id="moreMenu" class="menu_container"></div>
	</div>

	<div style="margin-top: 15px;">
		<input type="button" value="메뉴 추가" onClick="addMenu()">
		<input type="submit" value="메뉴 등록">
	</div>
</form>
