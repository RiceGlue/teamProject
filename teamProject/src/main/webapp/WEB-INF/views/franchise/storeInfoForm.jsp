<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script>
	$(document).on("change", "input[type='file'][name='fileName[]']", function () {
	    const inputId = $(this).attr("id");

	    // id가 없는 경우는 무시
	    if (!inputId) return;

	    const fileName = this.files.length > 0 ? this.files[0].name : "선택된 파일 없음";
	    const spanId = inputId.replace("fileName", "showFileName");
	    $("#" + spanId).text(fileName);
	});
	
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
	
	
	function validateImages(input) {
	    const files = input.files;
	    const maxFiles = 20;              // 최대 파일 개수
	    const maxSizeInBytes = 2 * 1024 * 1024; // 최대 파일 크기 2MB
	    const maxResolution = 500;       // 최대 해상도 500x500 픽셀

	    if (files.length > maxFiles) {
	        alert(`최대 ${maxFiles}개까지만 업로드할 수 있습니다.`);
	        resetInput(input);
	        return;
	    }

	    let checkedCount = 0;
	    let errorMessage = null;

	    for (let i = 0; i < files.length; i++) {
	        const file = files[i];

	        // 이미지 파일 여부 체크
	        if (!file.type.startsWith("image/")) {
	            errorMessage = "이미지 파일만 업로드할 수 있습니다.";
	            break;
	        }

	        // 파일 크기 체크
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

	    // 해상도 검사 (비동기 작업이라 Promise로 처리)
	    const promises = [];

	    for (let i = 0; i < files.length; i++) {
	        promises.push(checkImageResolution(files[i], maxResolution));
	    }

	    Promise.all(promises)
	        .then(results => {
	            // results 배열 안에 true/false가 들어있음
	            if (results.includes(false)) {
	                alert(`모든 이미지의 해상도는 최대 ${maxResolution}x${maxResolution} 픽셀을 초과할 수 없습니다.`);
	                resetInput(input);
	                
	                return;
	            }

	            // 여기서 미리보기 또는 업로드 준비 가능
	            // 예시: 첫번째 이미지 미리보기
	            const reader = new FileReader();
	            reader.onload = function(e) {
	                document.getElementById('preview').src = e.target.result;
	            };
	            reader.readAsDataURL(files[0]);
	        });
	}

	// 해상도 검사 함수: Promise 반환
	function checkImageResolution(file, maxResolution) {
	    return new Promise((resolve, reject) => {
	        const reader = new FileReader();
	        reader.onload = function(e) {
	            const img = new Image();
	            img.onload = function() {
	                if (img.width > maxResolution || img.height > maxResolution) {
	                    resolve(false);
	                } else {
	                    resolve(true);
	                }
	            };
	            img.onerror = () => resolve(false);
	            img.src = e.target.result;
	        };
	        reader.onerror = () => resolve(false);
	        reader.readAsDataURL(file);
	    });
	}

	function resetInput(input) {
	    input.value = '';
	    // 기본 이미지 또는 이전 프로필 이미지로 초기화
	    const currentImage = '${(not empty memberInfo.profileImageUrl) ? contextPath.concat(memberInfo.profileImageUrl) : contextPath.concat("/images/default_profile.png")}';
	    document.getElementById('preview').src = currentImage;
	}
	
	
	// ✅ 전역 스코프에 함수 정의
	function checkStoreInfo() {
	    function padTime(value) {
	        return value.toString().padStart(2, '0');
	    }
		const storeName = document.getElementById("storeName").value.trim();
	    const phone = document.getElementById("storePhoneNumber").value.trim();
	    const desc = document.getElementById("description").value.trim();
	    const fileName = document.getElementById("fileName").files[0];
	
	    if (!fileName) {
	        alert("메인 이미지를 업로드해주세요.");
	        return;
	    }
	
	    const phonePattern = /^[0-9\-]+$/;
	    if (!phone || !phonePattern.test(phone)) {
	        alert("유효한 전화번호를 입력해주세요. (숫자와 '-'만 허용)");
	        return;
	    }
	
	    if (!desc) {
	        alert("매장 소개를 입력해주세요.");
	        return;
	    }
	    
	    const startHour = $("#startHour").val().trim();
	    const startMin = $("#startMin").val().trim();
	    const endHour = $("#endHour").val().trim();
	    const endMin = $("#endMin").val().trim();

	    const breakStartHour = $("#breakStartHour").val().trim();
	    const breakStartMin = $("#breakStartMin").val().trim();
	    const breakEndHour = $("#breakEndHour").val().trim();
	    const breakEndMin = $("#breakEndMin").val().trim();

	    const lastOrderHour = $("#lastOrderHour").val().trim();
	    const lastOrderMin = $("#lastOrderMin").val().trim();

	    const operatingTime = padTime(startHour) + ":" + padTime(startMin) + " ~ " + padTime(endHour) + ":" + padTime(endMin);
	    const breakTime = padTime(breakStartHour) + ":" + padTime(breakStartMin) + " ~ " + padTime(breakEndHour) + ":" + padTime(breakEndMin);
	    const lastOrder = padTime(lastOrderHour) + ":" + padTime(lastOrderMin);

	    // hidden input으로 추가 (서버로 전송할 값)
	    if (!document.getElementById("operatingTime")) {
	        $('<input>').attr({
	            type: 'hidden',
	            id: 'operatingTime',
	            name: 'operatingTime',
	            value: operatingTime
	        }).appendTo('form[name="storeInfo"]');
	    }

	    if (!document.getElementById("breakTime")) {
	        $('<input>').attr({
	            type: 'hidden',
	            id: 'breakTime',
	            name: 'breakTime',
	            value: breakTime
	        }).appendTo('form[name="storeInfo"]');
	    }

	    if (!document.getElementById("lastOrder")) {
	        $('<input>').attr({
	            type: 'hidden',
	            id: 'lastOrder',
	            name: 'lastOrder',
	            value: lastOrder
	        }).appendTo('form[name="storeInfo"]');
	    }

	    alert("정보가 정상적으로 등록되었습니다.");
	    document.forms['storeInfo'].submit();
	}
</script>


<h1>정보 등록</h1>

<form action="${contextPath}/franchise/addStoreInfo" method="post" name="storeInfo" enctype="multipart/form-data">
	<input type="hidden" id="ownerId" name="ownerId" value="${ownerId}" />
	
	<div class="info_container" style="max-width: 700px;">
	
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;"> <!-- 매장 전화번호 -->
			<div class="form-label" style="width: 200px;">상호명</div>
			<div class="form-input" style="flex: 1;">
				<input id="storeName" name="storeName" type="text" maxLength="15" />
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;"> <!-- 유형 -->
			<div class="form-label" style="width: 200px;">유형</div>
			<div class="form-input" style="flex: 1;">
				<select id="storeType" name="storeType">
					<option value="한식" selected>한식</option>
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
				<input type="text" id="zipcode" placeholder="우편번호">
				<input type="button" onclick="sample6_execDaumPostcode()" value="우편번호 찾기"><br>
				<input type="text" id="address" placeholder="주소"><br>
				<input type="text" id="detailAddress" placeholder="상세주소">
				<input type="text" id="extraAddress" placeholder="참고항목">
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;"> <!-- 운영 방식 -->
			<div class="form-label" style="width: 200px;">운영 방식</div>
			<div class="form-input" style="flex: 1;">
				<select id="operationType" name="operationType">
					<option value="ALL" selected>모두</option>
					<option value="WAITING_ONLY">웨이팅만</option>
					<option value="RESERVATION_ONLY">예약만</option>
				</select>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;"> <!-- 매장 전화번호 -->
			<div class="form-label" style="width: 200px;">매장 전화번호</div>
			<div class="form-input" style="flex: 1;">
				<input id="storePhoneNumber" name="storePhoneNumber" type="text" maxLength="15" />
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;"> <!-- 매장 소개 -->
			<div class="form-label" style="width: 200px;">매장 소개</div>
			<div class="form-input" style="flex: 1;">
				<textarea id="description" name="description" rows="2" cols="40"></textarea>
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
			<div class="form-label" style="width: 200px;">운영시간<small>(24시간제로 입력)</small></div>
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
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
			<div class="form-label" style="width: 200px;">메인 이미지</div>
			<div class="form-input" style="flex: 1;">
				<input type="file" id="fileName" name="fileName" accept="image/*" multiple onchange="validateImages(this);" >
				<label for="fileName" style="cursor:pointer; background:#007bff; color:#fff; padding:5px 10px; border-radius:4px; margin-left: 10px;">파일 선택</label>
				<span id="showFileName" style="margin-left:10px; font-size:14px; color:#333;">선택된 파일 없음</span>
				<br />
			</div>
			<div class="image-preview" style="max-width:200px;">
				<img id="preview" src="" style="max-width: 200px; display: block;" />
			</div>
		</div>
		
		<div style="margin-top: 15px;">
			<input type="button" onClick="checkStoreInfo()" value="정보 등록">
		</div>
	</div>
</form>