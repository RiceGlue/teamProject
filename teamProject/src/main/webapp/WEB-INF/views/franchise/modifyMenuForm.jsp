<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<c:set var="contextPath" value="${pageContext.request.contextPath }" />

<c:if test="${param.success eq 'true'}">
    <script>alert("수정 완료");</script>
</c:if>
<c:if test="${param.error eq 'true'}">
    <script>alert("수정 실패");</script>
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

	    // 유효성 검사를 모두 통과하면 미리보기 표시
	    previewImage(files[0], index);
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
	
	function checkMenu(form) {
		
		  // 메뉴 이름 빈칸 체크
		  const menuName = form.menuName.value.trim();
		  if (menuName === "") {
		    alert("메뉴 이름을 입력해주세요.");
		    form.menuName.focus();
		    return false;
		  }

		  // 가격 숫자 체크
		  const price = form.price.value.trim();
		  if (price === "") {
		    alert("메뉴 가격을 입력해주세요.");
		    form.price.focus();
		    return false;
		  }
		  if (!/^\d+$/.test(price)) {
		    alert("가격은 숫자만 입력할 수 있습니다.");
		    form.price.focus();
		    return false;
		  }

		  // 설명 빈칸 체크
		  const description = form.description.value.trim();
		  if (description === "") {
		    alert("메뉴 설명을 입력해주세요.");
		    form.description.focus();
		    return false;
		  }

		  return true; // 모두 통과하면 제출 허용
	}
	
	function confirmDelete(menuId, storeId, fileName) {
	    if (confirm('정말 이 메뉴를 삭제하시겠습니까?')) {
	        const form = document.createElement('form');
	        form.method = 'post';
	        form.action = '${contextPath}/franchise/deleteMenu';  // 삭제 요청 URL

	        // menuId hidden input
	        const menuIdInput = document.createElement('input');
	        menuIdInput.type = 'hidden';
	        menuIdInput.name = 'menuId';
	        menuIdInput.value = menuId;
	        form.appendChild(menuIdInput);
	        
	     	// storeId hidden input
	        const storeIdInput = document.createElement('input');
	        storeIdInput.type = 'hidden';
	        storeIdInput.name = 'storeId';
	        storeIdInput.value = storeId;
	        form.appendChild(storeIdInput);

	        // fileName hidden input
	        const fileNameInput = document.createElement('input');
	        fileNameInput.type = 'hidden';
	        fileNameInput.name = 'fileName';
	        fileNameInput.value = fileName;
	        form.appendChild(fileNameInput);

	        document.body.appendChild(form);
	        form.submit();
	    }
	}


</script>

<h1>메뉴 수정</h1>

<c:forEach var="menu" items="${menuList}" varStatus="status">
	<form action="${contextPath}/franchise/modifyMenu" method="post" enctype="multipart/form-data" onsubmit="return checkMenu()">
		<input type="hidden" id="storeId" name="storeId" value="${menu.storeId}">
		<input type="hidden" name="menuId" value="${menu.menuId}" />
		
		<div class="info_container" style="max-width: 700px; border: 1px solid #ccc; padding: 15px; margin-bottom: 20px; border-radius:10px;">
			
			<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
				<div class="form-label" style="width: 200px;">메뉴 이름</div>
				<div class="form-input" style="flex: 1;">
					<input id="menuName${status.index}" name="menuName" type="text" maxLength="15" value="${menu.menuName}"/>
				</div>
			</div>
			
			<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
				<div class="form-label" style="width: 200px;">메뉴 가격</div>
				<div class="form-input" style="flex: 1;">
					<input id="price${status.index}" name="price" type="text" value="${menu.price}"/>
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
					<img src="${contextPath}/images/menu/${menu.fileName}" alt="${menu.menuName}" style="max-width: 200px;" />
					<input type="hidden" name="originalFileName" value="${menu.fileName }">
				</div>
			</div>
			
			<div class="form-row" style="display: flex; margin-bottom: 15px; align-items: flex-start;">
				<div class="form-label" style="width: 200px;">이미지 변경</div>
				<div class="form-input" style="flex: 1;">
					<input type="file" name="fileName" accept="image/*" onchange="validateImages(this, ${status.index})" />
					<div class="image-preview" id="preview${status.index}" style="margin-top: 10px;"></div>
				</div>
			</div>
			
			<div class="form-row" style="display: flex; justify-content: space-between; align-items: center;">
				<input type="button" onclick="confirmDelete(${menu.menuId}, ${menu.storeId}, '${menu.fileName}')" value="메뉴 삭제">
				<input type="button" onclick="this.form.submit()" value="메뉴 수정">
			</div>

		</div>
	</form>
</c:forEach>

