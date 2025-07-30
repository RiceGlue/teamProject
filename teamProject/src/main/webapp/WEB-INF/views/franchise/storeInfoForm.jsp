<%@ page contentType="text/html;charset=UTF-8" language="java" %>

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
	
	function padTime(value) { //숫자 한자리수 입력시 두자릿수로 바꿔줌
	  return value.toString().padStart(2, '0');
	}
	
	function addMenu() { //메뉴 추가 버튼
		$("#moreMenu").append(`
		  <tr><td>메뉴 이름 </td><td><input type="text" name="menuName"></td></tr>
		  <tr><td>메뉴 가격 </td><td><input type="text" name="price"></td></tr>
		  <tr><td>메뉴 설명 </td><td><textarea name="description" rows="2" cols="40"></textarea></td></tr>
		  <tr><td>메뉴 사진 </td><td><input type="file" mame="image_name" accept="image/*" /></td></tr>
		`);
	}
	
	function addDay() { //요일별 영업시간 설정
	  $("#moreDay").append(`
	  <tr>
	  <td><select name="openDayList"><option value="월" selected>월</option><option value="화">화</option><option value="수">수</option><option value="목">목</option><option value="금">금</option><option value="토">토</option><option value="일">일</option></select></td>
	  <td><input name="startHourValue" type="text" size="4" /> : <input name="startMinValue" type="text" size="4" /> ~ <input name="endHourValue" type="text" size="4" /> : <input name="endMinValue" type="text" size="4" /></td>
	  </tr>
	  `);
	}
	
	var dayOff=[];	//휴일

	$("input[name=dayOffOption]:checked").each(function() {
		var dayOffOption = $(this).val();
		dayOff.push(dayOffOption);
	})

	var amenities=[];	//편의시설 

	$("input[name=amenOption]:checked").each(function() {
		var amenOption = $(this).val();
		amenities.push(amenOption);
	})
	
	var openDay = [];
	
	for(let i = 0; i < document.getElementsByName("startHourValue").length; i++) {
	  openDay[i] = document.getElementsByName("openDayList")[i]?.value || "";
	}


	const brakeTime = 
	  padTime(document.getElementById("#brakeStartHour").value) + " : " +
	  padTime(document.getElementById("#brakeStartMin").value) + " ~ " +
	  padTime(document.getElementById("#brakeEndHour").value) + " : " +
	  padTime(document.getElementById("#brakeEndMin").value);

	var startHour = [];
	var startMin = [];
	var endHour = [];
	var endMin = [];
	
	for(let i = 0; i < document.getElementsByName("startHourValue").length ; i++) {
		startHour[i] = document.getElementsByName("startHourValue")[i]?.value || "";
		startMin[i] = document.getElementsByName("startMinValue")[i]?.value || "";
		endHour[i] = document.getElementsByName("endHourValue")[i]?.value || "";
		endMin[i] = document.getElementsByName("endMinValue")[i]?.value || "";
	}

<!--	function checkStoreInfo() {-->
<!--		var form = document.storeInfo;	-->
<!--		var store_phone_number = form.storePhoneNumber.value;-->
		
		
<!--		form.submit();-->
<!--	}-->

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
				<form action="${contextPath}/franchisor/addStoreInfo.do?storeId=${storeId}" method="post" name="storeInfo" enctype="multipart/form-data">
					<input type="hidden" id="storeId" value="${storeId}" />
					<input type="hidden" id="storeName" value="${storeName}" />
					<h3>가게 정보 등록</h3>
					<table>
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
							<td >전화번호</td>
							<td><input id="storePhoneNumber" type="text" maxLength="15" /></td>
						</tr>
						<tr>
							<td>매장 소개 </td>
							<td><textarea id="description" rows="2" cols="40"></textarea></td>
						</tr>
						<tr>
							<td>정기 휴무<small>(복수 선택 가능)</small></td>
							<td>
								<label><input type="checkbox" name="dayOffOption" value="mon" /> 월요일</label>
								<label><input type="checkbox" name="dayOffOption" value="tue" /> 화요일</label>
								<label><input type="checkbox" name="dayOffOption" value="wed" /> 수요일</label>
								<label><input type="checkbox" name="dayOffOption" value="thu" /> 목요일</label>
								<label><input type="checkbox" name="dayOffOption" value="fri" /> 금요일</label>
								<label><input type="checkbox" name="dayOffOption" value="sat" /> 토요일</label>
								<label><input type="checkbox" name="dayOffOption"  value="sun" /> 일요일</label>
							</td>
						</tr>
						<tr>
							<td >운영시간<small>(24시간제로 입력)</small></td>
							<td>
								<table>
									<thead>
										<tr>
											<td>
												<select name="openDayList">
													<option value="월" selected>월
													<option value="화">화
													<option value="수">수
													<option value="목">목
													<option value="금">금
													<option value="토">토
													<option value="일">일
												</select>
											</td>
											<td>
												<input name="startHourValue" type="text" size="4" /> :
												<input name="startMinValue" type="text" size="4" /> ~
												<input name="endHourValue" type="text" size="4" /> :
												<input name="endMinValue" type="text" size="4" />
											</td>
										</tr>
									</thead>
									<tbody id="moreDay"></tbody>
								</table>
								<input type="button" value="요일 추가" onClick="addDay()" >
							</td>
						</tr>
						<tr>
							<td>브레이크 타임</td>
							<td>
								<input id="brakeStartHour" type="text" size="4" /> :
								<input id="brakeStartMin" type="text" size="4" /> ~
								<input id="brakeEndHour" type="text" size="4" /> :
								<input id="brakeEndMin" type="text" size="4" />
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
							<td><input type="button" onClick="submit" value="정보 등록"></td>
						</tr>
					</table>
				</form>	
			</div>
			
			
			<div class="tab_content" id="tab2">
				<form action="${contextPath}/franchisor/addMenuInfo.do?storeId=${storeId}" method="post" enctype="multipart/form-data">
					<h3>메뉴 등록</h3>
					<table>
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
								<td><input type="file" mame="image_name" accept="image/*" /></td>
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
								<td><input type="file" mame="image_name" accept="image/*" /></td>
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
								<td><input type="file" mame="image_name" accept="image/*" /></td>
							</tr>
						</tbody>
						<tbody id="moreMenu"></tbody>
					</table>
					<input type="button" value="메뉴 추가" onClick="addMenu()">
					<input type="button" onClick="checkMenu()" value="메뉴 등록" >
				</form>
			</div>
		</div>
	</div>
</div>	
		