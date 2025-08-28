<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="store" value="${storeMap.storeInfo }" />

<c:if test="${param.success eq 'true'}">
    <script>alert("수정 완료");</script>
</c:if>
<c:if test="${param.error eq 'true'}">
    <script>alert("수정 실패");</script>
</c:if>

<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script>
function sample4_execDaumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
            // 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

            // 도로명 주소의 노출 규칙에 따라 주소를 표시한다.
            // 내려오는 변수가 값이 없는 경우엔 공백('')값을 가지므로, 이를 참고하여 분기 한다.
            var roadAddr = data.roadAddress; // 도로명 주소 변수
            var extraRoadAddr = ''; // 참고 항목 변수

            // 법정동명이 있을 경우 추가한다. (법정리는 제외)
            // 법정동의 경우 마지막 문자가 "동/로/가"로 끝난다.
            if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
                extraRoadAddr += data.bname;
            }
            // 건물명이 있고, 공동주택일 경우 추가한다.
            if(data.buildingName !== '' && data.apartment === 'Y'){
               extraRoadAddr += (extraRoadAddr !== '' ? ', ' + data.buildingName : data.buildingName);
            }
            // 표시할 참고항목이 있을 경우, 괄호까지 추가한 최종 문자열을 만든다.
            if(extraRoadAddr !== ''){
                extraRoadAddr = ' (' + extraRoadAddr + ')';
            }

            // 우편번호와 주소 정보를 해당 필드에 넣는다.
            document.getElementById('postcode').value = data.zonecode;
            document.getElementById("roadAddress").value = roadAddr;
            document.getElementById("jibunAddress").value = data.jibunAddress;
            
            // 참고항목 문자열이 있을 경우 해당 필드에 넣는다.
            if(roadAddr !== ''){
                document.getElementById("extraAddress").value = extraRoadAddr;
            } else {
                document.getElementById("extraAddress").value = '';
            }

            var guideTextBox = document.getElementById("guide");
            // 사용자가 '선택 안함'을 클릭한 경우, 예상 주소라는 표시를 해준다.
            if(data.autoRoadAddress) {
                var expRoadAddr = data.autoRoadAddress + extraRoadAddr;
                guideTextBox.innerHTML = '(예상 도로명 주소 : ' + expRoadAddr + ')';
                guideTextBox.style.display = 'block';

            } else if(data.autoJibunAddress) {
                var expJibunAddr = data.autoJibunAddress;
                guideTextBox.innerHTML = '(예상 지번 주소 : ' + expJibunAddr + ')';
                guideTextBox.style.display = 'block';
            } else {
                guideTextBox.innerHTML = '';
                guideTextBox.style.display = 'none';
            }
        }
    }).open();
}
    let imageIndex = ${storeMap.imageList.size()};
    console.log(imageIndex);

    function addImage() {
	    const fileNameIdx = "fileName" + imageIndex;
	    const previewIdx = "preview" + imageIndex;
	
	    const html =
		    '<div style="margin-bottom: 10px;">' +
		    '<div style="margin-bottom: 10px;">' +
		    '<label><input type="radio" name="mainImageRadio" onchange="setMainImage(this)"> 메인</label>' +
		    '</div>' +
		    '<div style="display: flex; width: 100%;">' +
		    '<div class="form-input" style="flex: 1;">' +
		    '<input type="hidden" name="originalFileName" value="">'+
		    '<span style="font-weight: bold;">신규 이미지</span><br>' +
		    '<input type="file" name="fileName" id="' + fileNameIdx + '" accept="image/*" onchange="validateImages(this, ' + imageIndex + ')" />' +
		    '<div class="image-preview" id="' + previewIdx + '" style="margin-top: 10px;"></div>' +
		    '<input type="hidden" name="displayNo" value="' + imageIndex + '">' +
		    '</div>' +
		    '</div>' +
		    '</div>';
	
	    $("#addImage").append(html);
	    imageIndex++;
    }

	
	function setMainImage(radio) {
    	const allRows = document.querySelectorAll('#ImagesContainer .form-row');
    	allRows.forEach(row => {
    		const fileTypeInput = row.querySelector('input[type="hidden"][name="fileType"]');
    		if (fileTypeInput) {
    			fileTypeInput.value = 'false'; // 일단 모두 false
    		}
    	});

    	// 선택된 라디오 버튼이 있는 row의 fileType만 true로
    	const selectedRow = radio.closest('.form-row');
    	const selectedFileTypeInput = selectedRow.querySelector('input[type="hidden"][name="fileType"]');
    	if (selectedFileTypeInput) {
    		selectedFileTypeInput.value = 'true';
    	}
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
    
	function checkStoreInfo(){
		
		//매장 전화번호 유효성
		const localNumber=document.getElementById('localNumber').value.trim(); 
		const number1=document.getElementById('number1').value.trim();
		const number2=document.getElementById('number2').value.trim();
		
		if(!localNumber){
			alert('지역번호를 선택해주세요.');
			return false;
		}
		if(!number1||!/^\d+$/.test(number1)){
			alert('전화번호 가운데 번호를 숫자로 입력해주세요.');
			return false;
		}
		if(!number2||!/^\d+$/.test(number2)){
			alert('전화번호 마지막 번호를 숫자로 입력해주세요.');
			return false;
		}
		
		//정기휴무 유효썽
		const closedOptions=[...document.querySelectorAll('input[name="closedOption"]:checked')].map(el=>el.value);
		const closed=closedOptions.join(', ');
		console.log('정기 휴무:',closed);
		
		//영업시간 유효성
		const startHour=document.getElementById('startHour').value;
		const startMin=document.getElementById('startMin').value;
		const endHour=document.getElementById('endHour').value;
		const endMin=document.getElementById('endMin').value;
		
		if(!startHour||!startMin||!endHour||!endMin){
			alert('영업시간을 모두 선택해주세요.');
			return false;
		}
		const operatingTime = startHour.padStart(2, '0') + " : " + startMin.padStart(2, '0') + " ~ " + endHour.padStart(2, '0') + " : " + endMin.padStart(2, '0');
		console.log('영업시간:',operatingTime);
		
		//브레이크 타임 유효성
		const breakStartHour=document.getElementById('breakStartHour').value;
		const breakStartMin=document.getElementById('breakStartMin').value;
		const breakEndHour=document.getElementById('breakEndHour').value;
		const breakEndMin=document.getElementById('breakEndMin').value;
		
		let breakTime='';
		if(breakStartHour&&breakStartMin&&breakEndHour&&breakEndMin){
			breakTime= breakStartHour.padStart(2,'0')+" : "+breakStartMin.padStart(2,'0')+" ~ "+breakEndHour.padStart(2,'0')+" : "+breakEndMin.padStart(2,'0');
		}
		console.log('브레이크 타임:',breakTime);
		
		//라스트 오더 유효성
		const lastOrderHour=document.getElementById('lastOrderHour').value;
		const lastOrderMin=document.getElementById('lastOrderMin').value;
		
		let lastOrder='';
		if(lastOrderHour&&lastOrderMin){
			lastOrder = lastOrderHour.padStart(2, '0') + " : " + lastOrderMin.padStart(2, '0');
		}
		console.log('라스트 오더:',lastOrder);
		
		//편의시설 유효성
		const amenOptions=[...document.querySelectorAll('input[name="amenOption"]:checked')].map(el=>el.value);
		const amenities=amenOptions.join(', ');
		console.log('편의시설:',amenities);
		
		//이미지 파일 유효성
		const files=document.querySelectorAll('input[name="fileName"]');
		let hasFile=false;
		files.forEach(input=>{
			if(input.files.length>0)hasFile=true;
		});
		
		setHiddenInput('closed',closed);
		setHiddenInput('operatingTime',operatingTime);
		setHiddenInput('breakTime',breakTime);
		setHiddenInput('lastOrder',lastOrder);
		setHiddenInput('amenities',amenities);
		
		return true;
	}
	
	function setHiddenInput(name,value){
		let input=document.querySelector(`input[name="${name}"]`);
		if(!input){
			input=document.createElement('input');
			input.type='hidden';
			input.name=name;
			document.forms['storeInfo'].appendChild(input);
		}		
		input.value=value;
	}

</script>

<form action="${contextPath}/franchise/modifyStoreInfo" method="post" name="storeInfo" enctype="multipart/form-data" onsubmit="return checkStoreInfo()">
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
				<input type="text" id="postcode" name="postcode" value="${store.postcode }">
				<input type="button" onclick="sample4_execDaumPostcode()" value="우편번호 찾기"><br>
				<input type="text" id="roadAddress" name="roadAddress" value="${store.roadAddress }">
				<input type="text" id="jibunAddress" name="jibunAddress" value="${store.jibunAddress }">
				<span id="guide" style="color:#999;display:none"></span>
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
				<label>
					<input type="checkbox" name="closedOption" value="월요일"
				    <c:if test="${storeMap.closedList != null && storeMap.closedList.contains('월요일')}">checked</c:if> />월요일
				</label>
				<label>
					<input type="checkbox" name="closedOption" value="화요일"
				    <c:if test="${storeMap.closedList != null && storeMap.closedList.contains('화요일')}">checked</c:if> />화요일
				</label>
				<label>
					<input type="checkbox" name="closedOption" value="수요일"
				    <c:if test="${storeMap.closedList != null && storeMap.closedList.contains('수요일')}">checked</c:if> />수요일
				</label>
				<label>
					<input type="checkbox" name="closedOption" value="목요일"
				    <c:if test="${storeMap.closedList != null && storeMap.closedList.contains('목요일')}">checked</c:if> />목요일
				</label>
				<label>
					<input type="checkbox" name="closedOption" value="금요일"
				    <c:if test="${storeMap.closedList != null && storeMap.closedList.contains('금요일')}">checked</c:if> />금요일
				</label>
				<label>
					<input type="checkbox" name="closedOption" value="토요일"
				    <c:if test="${storeMap.closedList != null && storeMap.closedList.contains('토요일')}">checked</c:if> />토요일
				</label>
				<label>
					<input type="checkbox" name="closedOption" value="일요일"
				    <c:if test="${storeMap.closedList != null && storeMap.closedList.contains('일요일')}">checked</c:if> />일요일
				</label>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">  <!--  운영 시간 -->
			<div class="form-label" style="width: 200px;">영업시간 <small>(24시간제로 입력)</small></div>
			<div class="form-input" style="flex: 1;">
				<select id="startHour" name="startHour">
					<option value="">시</option>
						<c:forEach var="i" begin="0" end="23">
							<option value="${i}"
								<c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[0] != null && storeMap.operatingTimeList[0]== i.toString()}">selected</c:if>>${i}
							</option>
						</c:forEach>
				</select> :
				<select id="startMin" name="startMin">
					<option value="">분</option>
					<option value="00" <c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[1]=='00'}">selected</c:if>>00</option>
					<option value="10" <c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[1]== '10'}">selected</c:if>>10</option>
					<option value="20" <c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[1]== '20'}">selected</c:if>>20</option>
					<option value="30" <c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[1]== '30'}">selected</c:if>>30</option>
					<option value="40" <c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[1]== '40'}">selected</c:if>>40</option>
					<option value="50" <c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[1]== '50'}">selected</c:if>>50</option>
				</select> ~
				<select id="endHour" name="endHour">
					<option value="">시</option>
						<c:forEach var="i" begin="0" end="23">
							<option value="${i}"
								<c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[2] != null && storeMap.operatingTimeList[2]== i.toString()}">selected</c:if>>${i}
							</option>
						</c:forEach>
				</select> :
				<select id="endMin" name="endMin">
					<option value="">분</option>
					<option value="00" <c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[3]=='00'}">selected</c:if>>00</option>
					<option value="10" <c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[3]== '10'}">selected</c:if>>10</option>
					<option value="20" <c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[3]== '20'}">selected</c:if>>20</option>
					<option value="30" <c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[3]== '30'}">selected</c:if>>30</option>
					<option value="40" <c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[3]== '40'}">selected</c:if>>40</option>
					<option value="50" <c:if test="${storeMap.operatingTimeList != null && storeMap.operatingTimeList[3]== '50'}">selected</c:if>>50</option>
				</select>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">  <!-- 브레이크 타임 -->
			<div class="form-label" style="width: 200px;">브레이크 타임</div>
			<div class="form-input" style="flex: 1;">
				<select id="breakStartHour" name="breakStartHour">
					<option value="">시</option>
						<c:forEach var="i" begin="0" end="23">
							<option value="${i}"
								<c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[0] != null && storeMap.breakTimeList[0]== i.toString()}">selected</c:if>>${i}
							</option>
						</c:forEach>
				</select> :
				<select id="breakStartMin" name="breakStartMin">
					<option value="">분</option>
					<option value="00" <c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[1]=='00'}">selected</c:if>>00</option>
					<option value="10" <c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[1]== '10'}">selected</c:if>>10</option>
					<option value="20" <c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[1]== '20'}">selected</c:if>>20</option>
					<option value="30" <c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[1]== '30'}">selected</c:if>>30</option>
					<option value="40" <c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[1]== '40'}">selected</c:if>>40</option>
					<option value="50" <c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[1]== '50'}">selected</c:if>>50</option>
				</select> ~
				<select id="breakEndHour" name="breakEndHour">
					<option value="">시</option>
						<c:forEach var="i" begin="0" end="23">
							<option value="${i}"
								<c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[2] != null && storeMap.breakTimeList[2]== i.toString()}">selected</c:if>>${i}
							</option>
						</c:forEach>
				</select> :
				<select id="breakEndMin" name="breakEndMin">
					<option value="">분</option>
					<option value="00" <c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[3]=='00'}">selected</c:if>>00</option>
					<option value="10" <c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[3]== '10'}">selected</c:if>>10</option>
					<option value="20" <c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[3]== '20'}">selected</c:if>>20</option>
					<option value="30" <c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[3]== '30'}">selected</c:if>>30</option>
					<option value="40" <c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[3]== '40'}">selected</c:if>>40</option>
					<option value="50" <c:if test="${storeMap.breakTimeList != null && storeMap.breakTimeList[3]== '50'}">selected</c:if>>50</option>
				</select>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;"> <!-- 라스트 오더 -->
			<div class="form-label" style="width: 200px;">라스트 오더</div>
			<div class="form-input" style="flex: 1;">
				<select id="lastOrderHour" name="lastOrderHour">
					<option value="">시</option>
						<c:forEach var="i" begin="0" end="23">
							<option value="${i}"
								<c:if test="${storeMap.lastOrderList != null && storeMap.lastOrderList[0] != null && storeMap.lastOrderList[0]== i.toString()}">selected</c:if>>${i}
							</option>
						</c:forEach>
				</select> :
				<select id="lastOrderMin" name="lastOrderMin">
					<option value="">분</option>
					<option value="00" <c:if test="${storeMap.lastOrderList != null && storeMap.lastOrderList[1]=='00'}">selected</c:if>>00</option>
					<option value="10" <c:if test="${storeMap.lastOrderList != null && storeMap.lastOrderList[1]== '10'}">selected</c:if>>10</option>
					<option value="20" <c:if test="${storeMap.lastOrderList != null && storeMap.lastOrderList[1]== '20'}">selected</c:if>>20</option>
					<option value="30" <c:if test="${storeMap.lastOrderList != null && storeMap.lastOrderList[1]== '30'}">selected</c:if>>30</option>
					<option value="40" <c:if test="${storeMap.lastOrderList != null && storeMap.lastOrderList[1]== '40'}">selected</c:if>>40</option>
					<option value="50" <c:if test="${storeMap.lastOrderList != null && storeMap.lastOrderList[1]== '50'}">selected</c:if>>50</option>
				</select>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;">  <!-- 편의 시설 -->
			<div class="form-label" style="width: 200px;">편의 시설</div>
			<div class="form-input" style="flex: 1;">
				<label>
					<input type="checkbox" name="amenOption" value="주차장"
				    <c:if test="${storeMap.amenitiesList != null && storeMap.amenitiesList.contains('주차장')}">checked</c:if> />주차장
				</label>
				<label>
					<input type="checkbox" name="amenOption" value="키즈존"
				    <c:if test="${storeMap.amenitiesList != null && storeMap.amenitiesList.contains('키즈존')}">checked</c:if> />키즈존
				</label>
				<label>
					<input type="checkbox" name="amenOption" value="노키즈존"
				    <c:if test="${storeMap.amenitiesList != null && storeMap.amenitiesList.contains('노키즈존')}">checked</c:if> />노키즈존
				</label>
				<label>
					<input type="checkbox" name="amenOption" value="와이파이"
				    <c:if test="${storeMap.amenitiesList != null && storeMap.amenitiesList.contains('와이파이')}">checked</c:if> />와이파이
				</label>
			</div>
		</div>
		<div id="ImagesContainer">
			<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;">
				<div class="form-label" style="width: 200px; float:left;">이미지</div>
				<div id="addImage" style="float:right; width:calc(100%-210px);">
					<c:forEach var="image" items="${storeMap.imageList}" varStatus="status">
						<input type="hidden" name="imageId" value="${image.imageId }" >
						<div style="margin-bottom: 10px;">
							<input type="hidden" name="fileType" value="${image.fileType}" />
							<label><input type="radio" name="mainImageRadio" onchange="setMainImage(this)" <c:if test="${image.fileType}">checked</c:if>> 메인</label>
						</div>
						
						<div style="display: flex; width: 100%;">
							<div class="form-input" style="flex: 1;">
								<input type="hidden" name="originalFileName" id="originalFileName${status.index}" value="${image.fileName}">
								
								<span style="font-weight: bold;">현재 이미지</span><br>
								<div style="margin:35px;"></div>
								<img src="${contextPath}/images/store/${image.fileName}" alt="${image.fileName}" style="max-width: 200px;" />
							</div>
							
							<div class="form-input" style="flex: 1;">
								<span style="font-weight: bold;">변경 이미지</span><br>
								<input type="file" name="fileName" id="fileName${status.index}" accept="image/*" onchange="validateImages(this, ${status.index})" />
								<div class="image-preview" id="preview${status.index}" style="margin-top: 10px;"></div>
								<input type="hidden" name="displayNo" id="displayNo${status.index}" value="${image.displayNo}">
							</div>
						</div>
					</c:forEach>
				</div>
			</div>
		</div>
		<div style="margin-top: 15px;">
			<input type="button" onclick="addImage()" value="신규 이미지 추가 ">
			<input type="submit" value="정보 수정">
		</div>
	</div>
</form>