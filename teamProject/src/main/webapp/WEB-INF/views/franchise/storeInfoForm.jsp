<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>
<style>
/* 	.tabs { display: flex; margin-top: 20px; padding: 0; list-style: none; overflow: hidden;} */
/* 	.tabs li { background-color: #3f3f3f; cursor: pointer; list-style: none; border-right: 1px solid #ddd; flex: 1; text-align: center; } */
/* 	.tabs li:last-child { border-right: none; } */
/* 	.tabs li.active { background-color: white; } */
/* 	.tabs li a { display: block; padding: 10px 0; color: white; text-decoration: none; transition: color 0.3s ease; } */
/* 	.tabs li.active a { color: black; } */
/* 	.tabs ul { background-color:#3f3f3f; } */
/* 	.tabs li:hover { background-color: white; color:black; } */
/* 	.tabs li a:hover { color:black; } */
/* 	.tab_content { padding: 20px; background-color: #fff; } */
/* 	.info_container { text-align:left; } */
</style>

<script>
	$(document).ready(function() {
	    // 탭 처리
	    $(".tab_content").hide();
	    $("ul.tabs li:first").addClass("active").show();
	    $(".tab_content:first").show();
	    $("ul.tabs li").click(function() {
	        $("ul.tabs li").removeClass("active");
	        $(this).addClass("active");
	        $(".tab_content").hide();
	        var activeTab = $(this).find("a").attr("href");
	        $(activeTab).fadeIn();
	        return false;
	    });
	
	});
	
	$(document).on("change", "input[type='file'][name='fileName[]']", function () {
	    const inputId = $(this).attr("id");

	    // id가 없는 경우는 무시
	    if (!inputId) return;

	    const fileName = this.files.length > 0 ? this.files[0].name : "선택된 파일 없음";
	    const spanId = inputId.replace("fileName", "showFileName");
	    $("#" + spanId).text(fileName);
	});


	
	let imgIdx = 1;

	function addImage() {
	    const subfileIdx = "fileName" + imgIdx;
	    const subfileNameIdx = "showFileName" + imgIdx;

	    const html =
	        '<tr>' +
	            '<td>서브 이미지</td>' +
	            '<td>' +
	                '<label style="cursor:pointer; background:#007bff; color:#fff; padding:5px 10px; border-radius:4px;">파일 선택' +
	                    '<input type="file" id="' + subfileIdx + '" name="fileName[]" accept="image/*" style="display:none;">' +
	                '</label>' +
	                '<span id="' + subfileNameIdx + '" style="margin-left:10px; font-size:14px; color:#333;">선택된 파일 없음</span>' +
	            '</td>' +
	        '</tr>';

	    $("#addImage").append(html);

	    // 이벤트 바인딩
	    $("#" + subfileIdx).on("change", function () {
	        const fileName = this.files.length > 0 ? this.files[0].name : "선택된 파일 없음";
	        $("#" + subfileNameIdx).text(fileName);
	    });

	    imgIdx++;
	}

	
	// ✅ 전역 스코프에 함수 정의
	function checkStoreInfo() {
	    function padTime(value) {
	        return value.toString().padStart(2, '0');
	    }
	
	    const phone = document.getElementById("storePhoneNumber").value.trim();
	    const desc = document.getElementById("description").value.trim();
	    const startHour = document.getElementById("startHour").value.trim();
	    const startMin = document.getElementById("startMin").value.trim();
	    const endHour = document.getElementById("endHour").value.trim();
	    const endMin = document.getElementById("endMin").value.trim();
	    const lastOrderHour = document.getElementById("lastOrderHour").value.trim();
	    const lastOrderMin = document.getElementById("lastOrderMin").value.trim();
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
	
	    const timeFields = [
	        { value: startHour, label: "운영 시작 시간 (시)" },
	        { value: startMin, label: "운영 시작 시간 (분)" },
	        { value: endHour, label: "운영 종료 시간 (시)" },
	        { value: endMin, label: "운영 종료 시간 (분)" },
	        { value: lastOrderHour, label: "라스트 오더 (시)" },
	        { value: lastOrderMin, label: "라스트 오더 (분)" },
	    ];
	    for (const field of timeFields) {
	        if (!/^\d+$/.test(field.value) || parseInt(field.value) < 0) {
	            alert(`${field.label}은 숫자로 입력해주세요.`);
	            return;
	        }
	    }
	
	    const startTime = parseInt(startHour) * 60 + parseInt(startMin);
	    const endTime = parseInt(endHour) * 60 + parseInt(endMin);
	    if (endTime <= startTime) {
	        alert("운영 종료 시간이 시작 시간보다 빠를 수 없습니다.");
	        return;
	    }
	
	    const lastOrderTime = parseInt(lastOrderHour) * 60 + parseInt(lastOrderMin);
	    if (lastOrderTime > endTime) {
	        alert("라스트 오더는 운영 종료 시간보다 늦을 수 없습니다.");
	        return;
	    }
	
	    alert("정보가 정상적으로 등록되었습니다.");
	    document.forms['storeInfo'].submit();
	}
</script>


<h1>정보 등록</h1>

<form action="${contextPath}/franchise/addStoreInfo" method="post" name="storeInfo" enctype="multipart/form-data">
	<input type="hidden" id="storeId" name="storeId" value="${storeId}" />
	<input type="hidden" id="storeName" name="storeName" value="${storeName}" />
	
	<table class="info_container">
		<colgroup>
			<col style="width: 200px;">
			<col style="width: 500px;">
		</colgroup>
		<tbody>
			<tr>
				<td>가게 유형</td>
				<td>
					<select id="storeType" name="storeType">
					<option value="한식" selected>한식</option>
					<option value="양식">양식</option>
					<option value="일식">일식</option>
					<option value="중식">중식</option>
					<option value="분식">분식</option>
					<option value="세계음식">세계음식</option>
					<option value="카페/베이커리">카페/베이커리</option>
					</select>
				</td>
			</tr>
			<tr>
				<td>운영 방식</td>
				<td>
					<select id="operationType" name="operationType">
						<option value="ALL" selected>모두</option>
						<option value="WAITING_ONLY">웨이팅만</option>
						<option value="RESERVATION_ONLY">예약만</option>
					</select>
				</td>
			</tr>
			<tr>
				<td>매장 전화번호</td>
				<td><input id="storePhoneNumber" name="storePhoneNumber" type="text" maxLength="15" /></td>
			</tr>
			<tr>
				<td>매장 소개</td>
				<td><textarea id="description" name="description" rows="2" cols="40"></textarea></td>
			</tr>
			<tr>
				<td>정기 휴무<small>(복수 선택 가능)</small></td>
				<td>
					<label><input type="checkbox" name="closedOption" value="월요일" /> 월요일</label>
					<label><input type="checkbox" name="closedOption" value="화요일" /> 화요일</label>
					<label><input type="checkbox" name="closedOption" value="수요일" /> 수요일</label>
					<label><input type="checkbox" name="closedOption" value="목요일" /> 목요일</label>
					<label><input type="checkbox" name="closedOption" value="금요일" /> 금요일</label>
					<label><input type="checkbox" name="closedOption" value="토요일" /> 토요일</label>
					<label><input type="checkbox" name="closedOption" value="일요일" /> 일요일</label>
				</td>
			</tr>
			<tr>
				<td>운영시간<small>(24시간제로 입력)</small></td>
				<td><input type="text" id="startHour" size="4">:<input type="text" id="startMin" size="4"> ~ <input type="text" id="endHour" size="4">:<input type="text" id="endMin" size="4"></td>
			</tr>
			<tr>
				<td>브레이크 타임</td>
				<td><input id="breakStartHour" type="text" size="4" />:<input id="breakStartMin" type="text" size="4" /> ~ <input id="breakEndHour" type="text" size="4" />:<input id="breakEndMin" type="text" size="4" /></td>
			</tr>
			<tr>
				<td>라스트 오더</td>
				<td><input id="lastOrderHour" type="text" size="4" />:<input id="lastOrderMin" type="text" size="4" /></td>
			</tr>
			<tr>
				<td>편의 시설</td>
				<td>
					<label><input type="checkbox" name="amenOption" value="주차장" />주차장 있음</label>
					<label><input type="checkbox" name="amenOption" value="키즈존" />키즈존</label>
					<label><input type="checkbox" name="amenOption" value="노키즈존" />노키즈존</label>
					<label><input type="checkbox" name="amenOption" value="와이파이" />와이파이</label>
				</td>
			</tr>
			<tr>
				<td>메인 이미지</td>
				<td>
					<input type="file" id="fileName0" name="fileName[]" accept="image/*">
					<label for="fileName0" style="cursor:pointer; background:#007bff; color:#fff; padding:5px 10px; border-radius:4px;">파일 선택</label>
					<span id="showFileName0" style="margin-left:10px; font-size:14px; color:#333;">선택된 파일 없음</span>
				</td>
			</tr>

		</tbody>
		<tbody id="addImage"></tbody>
		
	</table>
	<input type="button" value="이미지 추가" onClick="addImage()">
	<input type="button" onClick="checkStoreInfo()" value="정보 등록">
</form>
