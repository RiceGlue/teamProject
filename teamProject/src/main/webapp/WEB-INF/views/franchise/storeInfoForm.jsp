<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<script>
	$(document).ready(function() {

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

</script>

<script>
	function checkStoreInfo() {
		var form = document.storeInfo;
		var store_phone_number = form.store_phone_number.value;
<!--		var mon_start_hour = form.mon_start_hour.value;-->
<!--		var mon_start_min = form.mon_start_min.value;-->
<!--		var mon_end_hour = form.mon_end_hour.value;-->
<!--		var mon_end_min = form.mon_end_min.value;-->
<!--		var tue_start_hour = form.tue_start_hour.value;-->
<!--		var tue_start_min = form.tue_start_min.value;-->
<!--		var tue_end_hour = form.tue_end_hour.value;-->
<!--		var tue_end_min = form.tue_end_min.value;-->
<!--		var wed_start_hour = form.wed_start_hour.value;-->
<!--		var wed_start_min = form.wed_start_min.value;-->
<!--		var wed_end_hour = form.wed_end_hour.value;-->
<!--		var wed_end_min = form.wed_end_min.value;-->
<!--		var thu_start_hour = form.thu_start_hour.value;-->
<!--		var thu_start_min = form.thu_start_min.value;-->
<!--		var thu_end_hour = form.thu_end_hour.value;-->
<!--		var thu_end_min = form.thu_end_min.value;-->
		
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
				<form action="${contextPath}/franchisor/addStoreInfo.do?storeId=${storeId}" method="post" name="storeInfo">
					<h3>가게 정보 등록</h3>
				<table>
					<tr>
						<td width=200 >가게 유형</td>
						<td width=500><select name="store_type">
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
							<select name="operation_type">
								<option value="모두" selected>모두
								<option value="웨이팅만">웨이팅만
								<option value="예약만">예약만
							</select>
						</td>
					</tr>	
					<tr >
						<td >전화번호</td>
						<td><input name="store_phone_number" type="text" maxLength="15" /></td>
					</tr>
					<tr>
						<td>매장 소개 </td>
						<td><textarea name="description" rows="2" cols="40"></textarea></td>
					</tr>
					<tr>
						<td >운영시간<small>(24시간제로 입력)</small></td>
						<td>
							<table>
								<tr>
									<td>월요일</td>
									<td>
										<input name="mon_start_hour" type="text" size="4" /> :
										<input name="mon_start_min" type="text" size="4" /> ~
										<input name="mon_end_hour" type="text" size="4" /> :
										<input name="mon_end_min" type="text" size="4" />
									</td>
								</tr>
								<tr>
									<td>화요일</td>
									<td>
										<input name="tue_start_hour" type="text" size="4" /> :
										<input name="tue_start_min" type="text" size="4" /> ~
										<input name="tue_end_hour" type="text" size="4" /> :
										<input name="tue_end_min" type="text" size="4" />
									</td>
								</tr>
								<tr>
									<td>수요일</td>
									<td>
										<input name="wed_start_hour" type="text" size="4" /> :
										<input name="wed_start_min" type="text" size="4" /> ~
										<input name="wed_end_hour" type="text" size="4" /> :
										<input name="wed_end_min" type="text" size="4" />
									</td>
								</tr>
								<tr>
									<td>목요일</td>
									<td>
										<input name="thu_start_hour" type="text" size="4" /> :
										<input name="thu_start_min" type="text" size="4" /> ~
										<input name="thu_end_hour" type="text" size="4" /> :
										<input name="thu_end_min" type="text" size="4" />
									</td>
								</tr>
								<tr>
									<td>금요일</td>
									<td>
										<input name="fri_start_hour" type="text" size="4" /> :
										<input name="fri_start_min" type="text" size="4" /> ~
										<input name="fri_end_hour" type="text" size="4" /> :
										<input name="fri_end_min" type="text" size="4" />
									</td>
								</tr>
								<tr>
									<td>토요일</td>
									<td>
										<input name="sat_start_hour" type="text" size="4" /> :
										<input name="sat_start_min" type="text" size="4" /> ~
										<input name="sat_end_hour" type="text" size="4" /> :
										<input name="sat_end_min" type="text" size="4" />
									</td>
								</tr>
								<tr>
									<td>일요일</td>
									<td>
										<input name="sun_start_hour" type="text" size="4" /> :
										<input name="sun_start_min" type="text" size="4" /> ~
										<input name="sun_end_hour" type="text" size="4" /> :
										<input name="sun_end_min" type="text" size="4" />
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td>브레이크 타임</td>
						<td>
							<input name="brake_start_hour" type="text" size="4" /> :
							<input name="brake_start_min" type="text" size="4" /> ~
							<input name="brake_end_hour" type="text" size="4" /> :
							<input name="brake_end_min" type="text" size="4" />
						</td>
					</tr>
					<tr>
						<td>정기 휴무<small>(복수 선택 가능)</small></td>
						<td>
							<label><input type="checkbox" name="day_off" value="mon" /> 월요일</label>
							<label><input type="checkbox" name="day_off" value="tue" /> 화요일</label>
							<label><input type="checkbox" name="day_off" value="wed" /> 수요일</label>
							<label><input type="checkbox" name="day_off" value="thu" /> 목요일</label>
							<label><input type="checkbox" name="day_off" value="fri" /> 금요일</label>
							<label><input type="checkbox" name="day_off" value="sat" /> 토요일</label>
							<label><input type="checkbox" name="day_off" value="sun" /> 일요일</label>
						</td>
					</tr>
					<tr>
						<td>편의 시설 </td>
						<td>
							<label><input type="checkbox" name="amenities" value="주차장" />주차장 있음</label>
							<label><input type="checkbox" name="amenities" value="키즈존" />키즈존</label>
							<label><input type="checkbox" name="amenities" value="노키즈존" />노키즈존</label>
							<label><input type="checkbox" name="amenities" value="와이파이" />와이파이</label>	
						</td>
					</tr>
					<tr>
						<td>메인 이미지</td>
						<td><input type="button" value="파일 추가" onClick="fn_addFile()" /></td>
						<td><div id="d_file"></div></td>
					</tr>
					<tr>
						<td><input type="button" onClick="checkStoreInfo()" value="정보 등록"></td>
					</tr>
				</table>
				</form>	
			</div>
			<div class="tab_content" id="tab2">
				<form action="${contextPath}/franchisor/addMenuInfo.do?store_id=${store_id}" method="post" enctype="multipart/form-data">
					<h3>메뉴 등록</h3>
					<table>
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
						<tr></tr>
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
						<tr></tr>
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
						<tr></tr>
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
						<tr></tr>
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
							<td><input type="button" onClick="checkMenu()" value="메뉴 등록" ></td>
						</tr>
					</table>
				</form>
			</div>
		</div>
	</div>
</div>	
		