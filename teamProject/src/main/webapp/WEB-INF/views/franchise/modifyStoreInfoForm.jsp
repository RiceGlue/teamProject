<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="store" value="${storeMap.storeInfo }" />

<c:if test="${param.success eq 'true'}">
    <script>alert("수정 등록 완료!");</script>
</c:if>
<c:if test="${param.error eq 'true'}">
    <script>alert("수정 등록 실패!");</script>
</c:if>

<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script>
    function sample6_execDaumPostcode() {
        new daum.Postcode({
            oncomplete: function(data) {
                // 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

                // 각 주소의 노출 규칙에 따라 주소를 조합한다.
                // 내려오는 변수가 값이 없는 경우엔 공백('')값을 가지므로, 이를 참고하여 분기 한다.
                var addr = ''; // 주소 변수
                var extraAddr = ''; // 참고항목 변수

                //사용자가 선택한 주소 타입에 따라 해당 주소 값을 가져온다.
                if (data.userSelectedType === 'R') { // 사용자가 도로명 주소를 선택했을 경우
                    addr = data.roadAddress;
                } else { // 사용자가 지번 주소를 선택했을 경우(J)
                    addr = data.jibunAddress;
                }

                // 사용자가 선택한 주소가 도로명 타입일때 참고항목을 조합한다.
                if(data.userSelectedType === 'R'){
                    // 법정동명이 있을 경우 추가한다. (법정리는 제외)
                    // 법정동의 경우 마지막 문자가 "동/로/가"로 끝난다.
                    if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
                        extraAddr += data.bname;
                    }
                    // 건물명이 있고, 공동주택일 경우 추가한다.
                    if(data.buildingName !== '' && data.apartment === 'Y'){
                        extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                    }
                    // 표시할 참고항목이 있을 경우, 괄호까지 추가한 최종 문자열을 만든다.
                    if(extraAddr !== ''){
                        extraAddr = ' (' + extraAddr + ')';
                    }
                    // 조합된 참고항목을 해당 필드에 넣는다.
                    document.getElementById("extraAddress").value = extraAddr;
                
                } else {
                    document.getElementById("extraAddress").value = '';
                }

                // 우편번호와 주소 정보를 해당 필드에 넣는다.
                document.getElementById('zipcode').value = data.zonecode;
                document.getElementById("address").value = addr;
                // 커서를 상세주소 필드로 이동한다.
                document.getElementById("detailAddress").focus();
            }
        }).open();
    }
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

</script>


<h1>매장 정보 수정</h1>
	<input type="hidden" id="storeId" name="storeId" value="${store.storeId}" />
	<input type="hidden" id="ownerId" name="ownerId" value="${store.ownerId}" />
	
	<div class="info_container" style="max-width: 700px;">
	
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;"> <!-- 매장 전화번호 -->
			<div class="form-label" style="width: 200px;">상호명</div>
			<div class="form-input" style="flex: 1;">
				<input id="storeName" name="storeName" type="text" maxLength="15" value="${store.storeName }" />
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;"> <!-- 유형 -->
			<div class="form-label" style="width: 200px;">유형</div>
			<div class="form-input" style="flex: 1;">
				<select id="storeType" name="storeType">
					<option value="${store.storeType }" selected>${store.storeType }</option>
					<option value="한식">한식</option>
					<option value="양식">양식</option>
					<option value="일식">일식</option>
					<option value="중식">중식</option>
					<option value="분식">분식</option>
					<option value="세계음식">세계음식</option>
					<option value="카페/베이커리">카페/베이커리</option>
				</select>
			</div>
		</div>		
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;"> <!-- 주소 -->
			<div class="form-label" style="width: 200px;">주소</div>
			<div class="form-input" style="flex: 1;">
				<input type="text" id="zipcode" name="zipcode" value="${store.zipcode }">
				<input type="button" onclick="sample6_execDaumPostcode()" value="우편번호 찾기"><br>
				<input type="text" id="address" name="address" value="${store.address }"><br>
				<input type="text" id="detailAddress" name="detailAddress" value="${store.detailAddress }">
				<input type="text" id="extraAddress" name="extraAddress" value="${store.extraAddress }">
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;"> <!-- 운영 방식 -->
			<div class="form-label" style="width: 200px;">운영 방식</div>
			<div class="form-input" style="flex: 1;">
				<select id="operationType" name="operationType">
					<option value="${store.operationType }" selected>
					    <c:choose>
					        <c:when test="${store.operationType eq 'ALL'}">
					            모두
					        </c:when>
					        <c:when test="${store.operationType eq 'WAITING_ONLY'}">
					            웨이팅만
					        </c:when>
					        <c:when test="${store.operationType eq 'RESERVATION_ONLY'}">
					            예약만
					        </c:when>
					    </c:choose>
					</option>
					<option value="ALL">모두</option>
					<option value="WAITING_ONLY">웨이팅만</option>
					<option value="RESERVATION_ONLY">예약만</option>
				</select>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;"> <!-- 매장 전화번호 -->
			<div class="form-label" style="width: 200px;">매장 전화번호</div>
			<div class="form-input" style="flex: 1;">
				<select id="localNumber" name="localNumber">
					<option value="${store.localNumber }" selected>${store.localNumber }</option>
					<option value="02">02</option>
					<option value="051">051</option>
					<option value="053">053</option>
					<option value="032">032</option>
					<option value="062">062</option>
					<option value="042">042</option>
					<option value="052">052</option>
					<option value="044">044</option>
					<option value="031">031</option>
					<option value="033">033</option>
					<option value="043">043</option>
					<option value="041">041</option>
					<option value="063">063</option>
					<option value="061">061</option>
					<option value="054">054</option>
					<option value="055">055</option>
					<option value="064">064</option>
				</select>-<input type="text" id="number1" name="number1" size="4" value="${store.number1 }">-<input type="text" id="number2" name="number2" size="4" value="${store.number2 }">
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;"> <!-- 매장 소개 -->
			<div class="form-label" style="width: 200px;">매장 소개</div>
			<div class="form-input" style="flex: 1;">
				<textarea id="description" name="description" rows="2" cols="40" >${store.description }</textarea>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;">  <!-- 정기 휴무 설정 -->
			<div class="form-label" style="width: 200px;">정기 휴무<small>(복수 선택 가능)</small></div>
			<div class="form-input" style="flex: 1;">
				<label><input type="checkbox" name="closedOption" value="월요일" /> 월요일</label>
				<label><input type="checkbox" name="closedOption" value="화요일" /> 화요일</label>
				<label><input type="checkbox" name="closedOption" value="수요일" /> 수요일</label>
				<label><input type="checkbox" name="closedOption" value="목요일" /> 목요일</label>
				<label><input type="checkbox" name="closedOption" value="금요일" /> 금요일</label>
				<label><input type="checkbox" name="closedOption" value="토요일" /> 토요일</label>
				<label><input type="checkbox" name="closedOption" value="일요일" /> 일요일</label>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">  <!--  운영 시간 -->
			<div class="form-label" style="width: 200px;">영업시간 <small>(24시간제로 입력)</small></div>
			<div class="form-input" style="flex: 1;">
				<select id="startHour" name="startHour">
					<option value="">시</option>
					<script>
					for(let i=0; i<=23; i++) { document.write('<option value="' + i + '">' + i.toString().padStart(2,'0') + '</option>'); }
					</script>
				</select> :
				<select id="startMin" name="startMin">
					<option value="">분</option>
					<option value="0">00</option>
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="40">40</option>
					<option value="50">50</option>
				</select> ~
				<select id="endHour" name="endHour">
					<option value="">시</option>
					<script>
					for(let i=0; i<=23; i++) { document.write('<option value="' + i + '">' + i.toString().padStart(2,'0') + '</option>'); }
					</script>
				</select> :
				<select id="endMin" name="endMin">
					<option value="">분</option>
					<option value="0">00</option>
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="40">40</option>
					<option value="50">50</option>
				</select>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">  <!-- 브레이크 타임 -->
			<div class="form-label" style="width: 200px;">브레이크 타임</div>
			<div class="form-input" style="flex: 1;">
				<select id="breakStartHour" name="breakStartHour">
					<option value="">시</option>
					<script>
					for(let i=0; i<=23; i++) { document.write('<option value="' + i + '">' + i.toString().padStart(2,'0') + '</option>'); }
					</script>
				</select> :
				<select id="breakStartMin" name="breakStartMin">
					<option value="">분</option>
					<option value="0">00</option>
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="40">40</option>
					<option value="50">50</option>
				</select> ~
				<select id="breakEndHour" name="breakEndHour">
					<option value="">시</option>
					<script>
					for(let i=0; i<=23; i++) { document.write('<option value="' + i + '">' + i.toString().padStart(2,'0') + '</option>'); }
					</script>
				</select> :
				<select id="breakEndMin" name="breakEndMin">
					<option value="">분</option>
					<option value="0">00</option>
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="40">40</option>
					<option value="50">50</option>
				</select>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;"> <!-- 라스트 오더 -->
			<div class="form-label" style="width: 200px;">라스트 오더</div>
			<div class="form-input" style="flex: 1;">
				<select id="lastOrderHour" name="lastOrderHour">
					<option value="">시</option>
					<script>
					for(let i=0; i<=23; i++) { document.write('<option value="' + i + '">' + i.toString().padStart(2,'0') + '</option>'); }
					</script>
				</select> :
				<select id="lastOrderMin" name="lastOrderMin">
					<option value="">분</option>
					<option value="00">00</option>
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
					<option value="40">40</option>
					<option value="50">50</option>
				</select>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;">  <!-- 편의 시설 -->
			<div class="form-label" style="width: 200px;">편의 시설</div>
			<div class="form-input" style="flex: 1;">
				<label><input type="checkbox" name="amenOption" value="주차장" />주차장 있음</label>
				<label><input type="checkbox" name="amenOption" value="키즈존" />키즈존</label>
				<label><input type="checkbox" name="amenOption" value="노키즈존" />노키즈존</label>
				<label><input type="checkbox" name="amenOption" value="와이파이" />와이파이</label>
			</div>
		</div>
		
		<div id="ImagesContainer">
			<c:forEach var="image" items="${storeMap.imageList}" varStatus="status">
				<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;">
					<div class="form-label" style="width: 200px;">
						<label>
						<input type="radio" name="mainImageRadio" onchange="setMainImage(this)" 
						<c:if test="${image.fileType eq true}">checked</c:if>> 메인 이미지
						</label>
					</div>
					<div class="form-input" style="flex: 1;">
						<div style="margin-bottom: 15px;">
							<span style="font-weight: bold;">현재 이미지</span><br>
							<img src="${contextPath}/download?directoryName=store&fileName=${image.fileName}" alt="가게 이미지" style="max-width: 200px; margin-top: 5px;" />
						</div>
					</div>
					<div class="form-input" style="flex: 1;">
						<span style="font-weight: bold;">변경 이미지</span><br>
						<input type="file" name="imageFile" accept="image/*" onchange="validateImages(this, ${status.index})" />
						<div class="image-preview" id="preview${status.index}" style="margin-top: 10px;"></div>
						<input type="hidden" name="displayNo" value="${image.displayNo}">
					</div>
				</div>
			</c:forEach>
		</div>

		
		<div style="margin-top: 15px;">
			<input type="submit" value="정보 수정">
		</div>
	</div>