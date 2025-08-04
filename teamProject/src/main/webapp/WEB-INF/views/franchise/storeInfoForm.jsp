<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style>
	.tabs { display: flex; margin-top: 20px; padding: 0; list-style: none; overflow: hidden;}
	.tabs li { background-color: #3f3f3f; cursor: pointer; list-style: none; border-right: 1px solid #ddd; flex: 1; text-align: center; }
	.tabs li:last-child { border-right: none; }
	.tabs li.active { background-color: white; }
	.tabs li a { display: block; padding: 10px 0; color: white; text-decoration: none; transition: color 0.3s ease; }
	.tabs li.active a { color: black; }
	.tabs ul { background-color:#3f3f3f; }
	.tabs li:hover { background-color: white; color:black; }
	.tabs li a:hover { color:black; }
	.tab_content { padding: 20px; background-color: #fff; }
	.info_container { text-align:left; }
</style>

<script>
	$(document).ready(function() { //tab 실행
		//When page loads...
		$(".tab_content").hide(); //Hide all content
		$("ul.tabs li:first").addClass("active").show(); //Activate first tab
		$(".tab_content:first").show(); //Show first tab content

		//On Click Event
		$("ul.tabs li").click(function() {

			$("ul.tabs li").removeClass("active"); //Remove any "active" class
			$(this).addClass("active"); //Add "active" class to selected tab
			$(".tab_content").hide(); //Hide all tab content

			var activeTab = $(this).find("a").attr("href"); //Find the href attribute value to identify the active tab + content
			$(activeTab).fadeIn(); //Fade in the active ID content
			return false;
		});
	});
	
	function padTime(value) { return value.toString().padStart(2, '0'); }  //숫자 한자리수 입력시 두자릿수로 바꿔줌
	
	function addMenu() { //메뉴 추가 버튼
		$("#moreMenu").append(`
		  <tr><td>메뉴 이름 </td><td><input type="text" name="menuName"></td></tr>
		  <tr><td>메뉴 가격 </td><td><input type="text" name="price"></td></tr>
		  <tr><td>메뉴 설명 </td><td><textarea name="description" rows="2" cols="40"></textarea></td></tr>
		  <tr><td>메뉴 사진 </td><td><input type="file" mame="image_name" accept="image/*" /></td></tr>
		`);
	}

	var closed=[];	//휴일

	$("input[name=closedOption]:checked").each(function() {
		var closedOption = $(this).val()+",";
		dayOff.push(closedOption);
	})

	var amenities=[];	//편의시설 

	$("input[name=amenOption]:checked").each(function() {
		var amenOption = $(this).val()+",";
		amenities.push(amenOption);
	})
	
	const brakeTime =  //브레이크 타임
	 	padTime(document.getElementById("brakeStartHour").value) + " : " +
	  	padTime(document.getElementById("brakeStartMin").value) + " ~ " +
	  	padTime(document.getElementById("brakeEndHour").value) + " : " +
	  	padTime(document.getElementById("brakeEndMin").value);

	const operatingHours =  //운영 시간
		padTime(document.getElementById("startHour").value) + " : " +
		padTime(document.getElementById("startMin").value) + " ~ " +
		padTime(document.getElementById("endHour").value) + " : " +
		padTime(document.getElementById("endMin").value);
		
	const lastOrder =  //라스트 오더
		padTime(document.getElementById("lastOrderHour").value) + " : " +
		padTime(document.getElementById("lastOrderMin").value);
		

	function checkStoreInfo() {
	        // 필수 항목 검사
	        const phone = document.getElementById("storePhoneNumber").value.trim();
	        const desc = document.getElementById("description").value.trim();
	        const startHour = document.getElementById("startHour").value.trim();
	        const startMin = document.getElementById("startMin").value.trim();
	        const endHour = document.getElementById("endHour").value.trim();
	        const endMin = document.getElementById("endMin").value.trim();
	        const lastOrderHour = document.getElementById("lastOrderHour").value.trim();
	        const lastOrderMin = document.getElementById("lastOrderMin").value.trim();
	        const mainImage = document.getElementById("mainmIage").files[0];
		        // 전화번호 유효성 (숫자, 하이픈 허용)
	        const phonePattern = /^[0-9\-]+$/;
		    if (!phone || !phonePattern.test(phone)) {
	           	alert("유효한 전화번호를 입력해주세요. (숫자와 '-'만 허용)");
	           	return;
	        }
		    
		    if (!desc) {
	            alert("매장 소개를 입력해주세요.");
	            return;
	        }
		        // 운영 시간, 라스트 오더 숫자 검사
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
		        // 운영 시간 논리적 오류 방지
	        const startTime = parseInt(startHour) * 60 + parseInt(startMin);
	        const endTime = parseInt(endHour) * 60 + parseInt(endMin);
		    if (endTime <= startTime) {
	            alert("운영 종료 시간이 시작 시간보다 빠를 수 없습니다.");
	            return;
	        }
		        // 라스트 오더는 종료 시간보다 이르거나 같아야 함
	        const lastOrderTime = parseInt(lastOrderHour) * 60 + parseInt(lastOrderMin);
	        if (lastOrderTime > endTime) {
	            alert("라스트 오더는 운영 종료 시간보다 늦을 수 없습니다.");
	            return;
	        }
		        // 이미지 업로드 여부
		    if (!mainImage) {
		        alert("메인 이미지를 업로드해주세요.");
		        return;
		    }
		    alert("정보가 정상적으로 등록되었습니다.");
		    form.submit();
		}
</script>


<h1>정보 등록</h1>

<div class="tab_container">
	<div class="tab_container" id="container">
		<ul class="tabs">
			<li><a href="#tab1">가게 정보</a></li>
			<li><a href="#tab2">메뉴 등록</a></li>
		</ul>
		<div class="tab_container">
			<div class="tab_content" id="tab1">
				<form action="${contextPath}/franchise/addStoreInfo?storeId=${storeId}" method="post" name="storeInfo" enctype="multipart/form-data">
					<input type="hidden" id="storeId" value="${storeId}" />
					<input type="hidden" id="storeName" value="${storeName}" />
					<h3 style="text-align:center">가게 정보 등록</h3>
					<table class="info_container">
						<colgroup>
							<col style="width: 200px;">
							<col style="width: 500px;">
						</colgroup>
						<tr>
							<td width=200 >가게 유형</td>
							<td width=500>
								<select id="storeType">
									<option value="한식" selected>한식 
									<option value="양식">양식
									<option value="일식">일식
									<option value="중식">중식
									<option value="분식">분식
									<option value="세계음식">세계음식
									<option value="카페/베이커리">카페/베이커리
								</select>
							</td>
						</tr>	
						<tr>
							<td width=200 >운영 방식</td>
							<td width=500>
								<select id="operationType">
									<option value="ALL" selected>모두
									<option value="WAITING_ONLY">웨이팅만
									<option value="RESERVATION_ONLY">예약만
								</select>
							</td>
						</tr>	
						<tr >
							<td>매장 전화번호</td>
							<td><input id="storePhoneNumber" type="text" maxLength="15" /></td>
						</tr>
						<tr>
							<td>매장 소개 </td>
							<td><textarea id="description" rows="2" cols="40"></textarea></td>
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
								<label><input type="checkbox" name="closedOption"  value="일요일" /> 일요일</label>
							</td>
						</tr>
						<tr>
							<td>운영시간<small>(24시간제로 입력)</small></td>
							<td><input type="text" id="startHour" size="4"> : <input type="text" id="startMin" size="4"> ~ <input type="text" id="endHour" size="4"> : <input type="text" id="endMin" size="4"></td>
						</tr>
						<tr>
							<td>브레이크 타임</td>
							<td>
								<input id="brakeStartHour" type="text" size="4" /> : <input id="brakeStartMin" type="text" size="4" /> ~ <input id="brakeEndHour" type="text" size="4" /> : <input id="brakeEndMin" type="text" size="4" />
							</td>
						</tr>
						<tr>
							<td>라스트 오더</td>
							<td>
								<input id="lastOrderHour" type="text" size="4" /> : <input id="lastOrderMin" type="text" size="4" />
							</td>
						</tr>
						<tr>
							<td>편의 시설 </td>
							<td>
								<label><input type="checkbox" name="amenOption" value="주차장" />주차장 있음</label>
								<label><input type="checkbox" name="amenOption" value="키즈존" />키즈존</label>
								<label><input type="checkbox" name="amenOption" value="노키즈존" />노키즈존</label>
								<label><input type="checkbox" name="amenOption" value="와이파이" />와이파이</label>	
							</td>
						</tr>
						<tr>
							<td>메인 이미지</td>
							<td><input type="file" id="mainmIage" accept="image/*" /></td>
						</tr>
						<tr>
							<td><input type="button" onClick="checkStoreInfo()" value="정보 등록"></td>
						</tr>
					</table>
				</form>	
			</div>
			
			
			<div class="tab_content" id="tab2">
				<form action="${contextPath}/franchisor/addMenuInfo?storeId=${storeId}" method="post" enctype="multipart/form-data">
					<h3 style="text-align:center">메뉴 등록</h3>
					<table class="info_container">
						<colgroup>
							<col style="width:200px;">
							<col style="width: 500px;">
						</colgroup>
						<tbody>
							<tr>
								<td>메뉴 이름 </td>
								<td><input type="text" name="menu_name"></td>
							</tr>
							<tr>
								<td>메뉴 가격 </td>
								<td><input type="text" name="price" ></td>
							</tr>
							<tr>
								<td>메뉴 설명 </td>
								<td><textarea name="description" rows="2" cols="40"></textarea></td>
							</tr>
							<tr>
								<td>메뉴 사진 </td>
								<td><input type="file" name="image_name" accept="image/*" /></td>
							</tr>
							<tr>
								<td>메뉴 이름 </td>
								<td><input type="text" name="menu_name"></td>
							</tr>
							<tr>
								<td>메뉴 가격 </td>
								<td><input type="text" name="price" ></td>
							</tr>
							<tr>
								<td>메뉴 설명 </td>
								<td><textarea name="description" rows="2" cols="40"></textarea></td>
							</tr>
							<tr>
								<td>메뉴 사진 </td>
								<td><input type="file" name="image_name" accept="image/*" /></td>
							</tr>
							<tr>
								<td>메뉴 이름 </td>
								<td><input type="text" name="menu_name"></td>
							</tr>
							<tr>
								<td>메뉴 가격 </td>
								<td><input type="text" name="price" ></td>
							</tr>
							<tr>
								<td>메뉴 설명 </td>
								<td><textarea name="description" rows="2" cols="40"></textarea></td>
							</tr>
							<tr>
								<td>메뉴 사진 </td>
								<td><input type="file" name="image_name" accept="image/*" /></td>
							</tr>
						</tbody>
						<tbody id="moreMenu" class="menu_container" ></tbody>
					</table>
					<input type="button" value="메뉴 추가" onClick="addMenu()">
					<input type="button" onClick="checkMenu()" value="메뉴 등록" >
				</form>
			</div>
		</div>
	</div>
</div>	
