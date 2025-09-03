<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<c:if test="${param.success eq 'true'}">
    <script>alert("등록 완료!");</script>
</c:if>
<c:if test="${param.error eq 'true'}">
    <script>alert("등록 실패!");</script>
</c:if>

<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script>
    // Daum 우편번호 찾기 함수
    function sample4_execDaumPostcode() {
        new daum.Postcode({
            oncomplete: function(data) {
                var roadAddr = data.roadAddress;
                var extraRoadAddr = '';

                if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
                    extraRoadAddr += data.bname;
                }
                if(data.buildingName !== '' && data.apartment === 'Y'){
                   extraRoadAddr += (extraRoadAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                }
                if(extraRoadAddr !== ''){
                    extraRoadAddr = ' (' + extraRoadAddr + ')';
                }

                document.getElementById('postcode').value = data.zonecode;
                document.getElementById("roadAddress").value = roadAddr;
                document.getElementById("jibunAddress").value = data.jibunAddress;
                
                if(roadAddr !== ''){
                    document.getElementById("extraAddress").value = extraRoadAddr;
                } else {
                    document.getElementById("extraAddress").value = '';
                }

                var guideTextBox = document.getElementById("guide");
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
    
    let imgIdx = 1; // 첫 번째 이미지의 displayNo가 0이므로, 동적 추가는 1부터 시작하는 것이 맞습니다.
    
    function addImage() {
        const fileNameIdx = "fileName" + imgIdx;
        const showFileNameIdx = "showFileName" + imgIdx;
        
        const html =
            '<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">'+
            '<div class="form-label" style="width: 200px;">이미지</div>'+
            '<div class="form-input" style="flex: 1;"><div>'+
            '<label><input type="radio" name="mainImageRadio" onchange="setMainImage(this)">메인 이미지</label>'+
            '<input type="hidden" name="fileType" value="false">'+
            '<input type="hidden" name="displayNo" value="'+imgIdx+'"></div>'+
            // input type="file" 직접 노출
            '<input type="file" id="'+fileNameIdx+'" name="fileName" accept="image/*" onchange="handleFileChange(this);">'+
            // 파일명 표시를 위한 span은 유지
            '<span id="'+showFileNameIdx+'" style="margin-left:10px; font-size:14px; color:#333;">선택된 파일 없음</span>'+
            '</div><div class="image-preview" style="max-width:200px;"></div></div>';

        $("#ImagesContainer").append(html);
        imgIdx++;
    }
    
    function setMainImage(radio) {
        // 모든 mainImageRadio 버튼의 fileType을 false로 설정
        document.querySelectorAll('input[name="mainImageRadio"]').forEach(r => {
            const row = r.closest('.form-row');
            const fileTypeInput = row.querySelector('input[type="hidden"][name="fileType"]');
            if (fileTypeInput) {
                fileTypeInput.value = 'false';
            }
        });

        // 선택된 라디오 버튼이 있는 행의 fileType만 true로 설정
        const selectedRow = radio.closest('.form-row');
        const selectedFileTypeInput = selectedRow.querySelector('input[type="hidden"][name="fileType"]');
        if (selectedFileTypeInput) {
            selectedFileTypeInput.value = 'true';
        }
    }

    // 파일 변경 및 유효성 검사 통합 함수
    function handleFileChange(input) {
        const file = input.files[0];
        // span 태그를 다시 찾도록 수정 (input 바로 옆에 있는 span)
        const span = input.closest('.form-input').querySelector('#showFileName' + input.id.replace('fileName', ''));

        if (!file) {
            if (span) span.textContent = '선택된 파일 없음';
            const imagePreviewDiv = input.closest('.form-row').querySelector('.image-preview');
            if (imagePreviewDiv) {
                imagePreviewDiv.innerHTML = ''; // 파일이 없으면 미리보기 제거
            }
            return;
        }

        const maxFiles = 20;
        const maxSizeInBytes = 2 * 1024 * 1024;

        if (file.type && !file.type.startsWith("image/")) {
            alert("이미지 파일만 업로드할 수 있습니다.");
            resetInput(input);
            return;
        }

        if (file.size > maxSizeInBytes) {
            alert(`각 파일 크기는 최대 2MB 이하여야 합니다. (${file.name})`);
            resetInput(input);
            return;
        }
        
        if (span) span.textContent = file.name;

        // 이미지 미리보기
        const reader = new FileReader();
        reader.onload = function (e) {
            const imagePreviewDiv = input.closest('.form-row').querySelector('.image-preview');
            if (imagePreviewDiv) {
                imagePreviewDiv.innerHTML = '';
                const img = document.createElement('img');
                img.src = e.target.result;
                img.style.maxWidth = '200px';
                img.style.maxHeight = '150px'; // 높이 제한 추가
                img.style.objectFit = 'contain'; // 비율 유지하며 채우기
                img.style.display = 'block';
                img.style.marginTop = '5px'; // 미리보기와 파일명 사이 간격
                imagePreviewDiv.appendChild(img);
            }
        };
        reader.readAsDataURL(file);
    }
    
    function resetInput(input) {
        input.value = '';
        const span = input.closest('.form-input').querySelector('#showFileName' + input.id.replace('fileName', ''));
        if (span) span.textContent = '선택된 파일 없음';
        const imagePreviewDiv = input.closest('.form-row').querySelector('.image-preview');
        if (imagePreviewDiv) {
            imagePreviewDiv.innerHTML = '';
        }
    }
    
    function checkStoreInfo(){
        // 기존 유효성 검사 로직은 그대로 유지
        const localNumber = document.getElementById('localNumber').value.trim(); 
        const number1 = document.getElementById('number1').value.trim();
        const number2 = document.getElementById('number2').value.trim();
        
        if (!localNumber) {
            alert('지역번호를 선택해주세요.');
            return false;
        }
        if (!number1 || !/^\d+$/.test(number1)) {
            alert('전화번호 가운데 번호를 숫자로 입력해주세요.');
            return false;
        }
        if (!number2 || !/^\d+$/.test(number2)) {
            alert('전화번호 마지막 번호를 숫자로 입력해주세요.');
            return false;
        }
        
        const closedOptions = [...document.querySelectorAll('input[name="closedOption"]:checked')].map(el => el.value);
        const closed = closedOptions.join(', ');
        
        const startHour = document.getElementById('startHour').value;
        const startMin = document.getElementById('startMin').value;
        const endHour = document.getElementById('endHour').value;
        const endMin = document.getElementById('endMin').value;
        
        if (!startHour || !startMin || !endHour || !endMin) {
            alert('영업시간을 모두 선택해주세요.');
            return false;
        }
        const operatingTime = startHour.padStart(2, '0') + " : " + startMin.padStart(2, '0') + " ~ " + endHour.padStart(2, '0') + " : " + endMin.padStart(2, '0');
        
        const breakStartHour = document.getElementById('breakStartHour').value;
        const breakStartMin = document.getElementById('breakStartMin').value;
        const breakEndHour = document.getElementById('breakEndHour').value;
        const breakEndMin = document.getElementById('breakEndMin').value;
        
        let breakTime = '';
        if (breakStartHour && breakStartMin && breakEndHour && breakEndMin) {
            breakTime = breakStartHour.padStart(2, '0') + " : " + breakStartMin.padStart(2, '0') + " ~ " + breakEndHour.padStart(2, '0') + " : " + breakEndMin.padStart(2, '0');
        }
        
        const lastOrderHour = document.getElementById('lastOrderHour').value;
        const lastOrderMin = document.getElementById('lastOrderMin').value;
        
        let lastOrder = '';
        if (lastOrderHour && lastOrderMin) {
            lastOrder = lastOrderHour.padStart(2, '0') + " : " + lastOrderMin.padStart(2, '0');
        }
        
        const amenOptions = [...document.querySelectorAll('input[name="amenOption"]:checked')].map(el => el.value);
        const amenities = amenOptions.join(', ');
        
        const files = document.querySelectorAll('input[name="fileName"]');
        let hasFile = false;
        files.forEach(input => {
            if (input.files.length > 0) hasFile = true;
        });
        if (!hasFile) {
            alert('최소 한 개 이상의 이미지를 선택해주세요.');
            return false;
        }
        
        setHiddenInput('closed', closed);
        setHiddenInput('operatingTime', operatingTime);
        setHiddenInput('breakTime', breakTime);
        setHiddenInput('lastOrder', lastOrder);
        setHiddenInput('amenities', amenities);
        
        return true;
    }
    
    function setHiddenInput(name, value){
        let input = document.querySelector(`input[name="${name}"]`);
        if (!input) {
            input = document.createElement('input');
            input.type = 'hidden';
            input.name = name;
            document.forms['storeInfo'].appendChild(input);
        }        
        input.value = value;
    }

</script>

<h1>정보 등록</h1>

<form action="${contextPath}/franchise/addStoreInfo" method="post" name="storeInfo" enctype="multipart/form-data" onsubmit="return checkStoreInfo()">
    <input type="hidden" id="ownerId" name="ownerId" value="${ownerId}" />
    
    <div class="info_container" style="max-width: 700px;">
    
        <div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
            <div class="form-label" style="width: 200px;">상호명</div>
            <div class="form-input" style="flex: 1;">
                <input id="storeName" name="storeName" type="text" maxLength="15" />
            </div>
        </div>
        
        <div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
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
        
        <div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
            <div class="form-label" style="width: 200px;">주소</div>
            <div class="form-input" style="flex: 1;">
                <input type="text" id="postcode" name="postcode" placeholder="우편번호">
                <input type="button" onclick="sample4_execDaumPostcode()" value="우편번호 찾기"><br>
                <input type="text" id="roadAddress" name="roadAddress" placeholder="도로명주소">
                <input type="text" id="jibunAddress" name="jibunAddress" placeholder="지번주소">
                <span id="guide" style="color:#999;display:none"></span>
                <input type="text" id="detailAddress" name="detailAddress" placeholder="상세주소">
                <input type="text" id="extraAddress" name="extraAddress" placeholder="참고항목">
            </div>
        </div>
        
        <div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
            <div class="form-label" style="width: 200px;">운영 방식</div>
            <div class="form-input" style="flex: 1;">
                <select id="operationType" name="operationType">
                    <option value="ALL" selected>모두</option>
                    <option value="WAITING_ONLY">웨이팅만</option>
                    <option value="RESERVATION_ONLY">예약만</option>
                </select>
            </div>
        </div>
        
        <div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
            <div class="form-label" style="width: 200px;">매장 전화번호</div>
            <div class="form-input" style="flex: 1;">
                <select id="localNumber" name="localNumber">
                    <option value="02" selected>02</option>
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
                </select>-<input type="text" id="number1" name="number1" size="4">-<input type="text" id="number2" name="number2" size="4">
            </div>
        </div>
        
        <div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;">
            <div class="form-label" style="width: 200px;">매장 소개</div>
            <div class="form-input" style="flex: 1;">
                <textarea id="description" name="description" rows="2" cols="40"></textarea>
            </div>
        </div>
        
        <div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;">
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
        
        <div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
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
        
        <div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
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
        
        <div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
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
        
        <div class="form-row" style="display: flex; margin-bottom: 10px; align-items: flex-start;">
            <div class="form-label" style="width: 200px;">편의 시설</div>
            <div class="form-input" style="flex: 1;">
                <label><input type="checkbox" name="amenOption" value="주차장" />주차장</label>
                <label><input type="checkbox" name="amenOption" value="키즈존" />키즈존</label>
                <label><input type="checkbox" name="amenOption" value="노키즈존" />노키즈존</label>
                <label><input type="checkbox" name="amenOption" value="와이파이" />와이파이</label>
            </div>
        </div>
        
       <div id="ImagesContainer">
    <div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
        <div class="form-label" style="width: 200px;">이미지</div>
        <div class="form-input" style="flex: 1;">
            <div>
                <label><input type="radio" name="mainImageRadio" onchange="setMainImage(this)" checked>메인 이미지</label>
                <input type="hidden" name="fileType" value="true">
                <input type="hidden" name="displayNo" value="0">
            </div>
            <input type="file" id="fileName0" name="fileName" accept="image/*" onchange="handleFileChange(this);" >
            <span id="showFileName0" style="margin-left:10px; font-size:14px; color:#333;">선택된 파일 없음</span>
        </div>
        <div class="image-preview" style="max-width: 200px;"></div>
    </div>
</div>

        <div style="margin-top: 15px;">
            <input type="button" value="이미지추가" onClick="addImage()">
            <input type="submit" value="정보 등록">
        </div>
    </div>
</form>