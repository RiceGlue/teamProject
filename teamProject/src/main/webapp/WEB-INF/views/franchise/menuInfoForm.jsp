<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<script>
	$(document).ready(function() {
		// 파일 선택 시 파일명 표시
		$("#fileName").on("change", function() {
			const fileName = this.files.length > 0 ? this.files[0].name : '선택된 파일 없음';
			$("#showFileName").text(fileName);
		});
	
		document.getElementById('fileName0').addEventListener('change', function () {
			document.getElementById('showFileName0').textContent = this.files[0]?.name || '선택된 파일 없음';
		});
		document.getElementById('fileName1').addEventListener('change', function () {
			document.getElementById('showFileName1').textContent = this.files[0]?.name || '선택된 파일 없음';
		});
		document.getElementById('fileName2').addEventListener('change', function () {
			document.getElementById('showFileName2').textContent = this.files[0]?.name || '선택된 파일 없음';
		});

	});
	
	let menuIdx = 3;
	
	function addMenu() {
		const menuNameIdx = `menuName${menuIdx}`;
		const priceIdx = `price${menuIdx}`;
		const desIdx = `description${menuIdx}`;
		const fileIdx = `fileName${menuIdx}`;
		const fileNameIdx = `showFileName${menuIdx}`;
		
		$("#moreMenu").append(`
			<tr><td>메뉴 이름 </td><td><input type="text" name="menuName" id="${menuNameIdx}"></td></tr>
			<tr><td>메뉴 가격 </td><td><input type="text" name="price" id="${priceIdx}"></td></tr>
			<tr><td>메뉴 설명 </td><td><textarea name="description" id="${desIdx}" rows="2" cols="40"></textarea></td></tr>
			<tr><td>메뉴 사진 </td><input type="file" id="${fileIdx}" name="fileName" accept="image/*"><label for="${fileIdx}" style="cursor:pointer; background:#007bff; color:#fff; padding:5px 10px; border-radius:4px;">파일 선택</label><span id="${fileNameIdx}" style="margin-left:10px; font-size:14px; color:#333;">선택된 파일 없음</span></tr>
		`);
		
		document.getElementById(fileIdx).addEventListener('change', function() {
			const fileName = this.files.length > 0 ? this.files[0].name : '선택된 파일 없음';
			document.getElementById(fileNameIdx).textContent = fileName;
		});
		
		menuIdx++;
	}
	
	
</script>

<h1>정보 등록</h1>
<form action="${contextPath}/franchisor/addMenuInfo" method="post" enctype="multipart/form-data">
	<input type="hidden" id="storeId" name="storeId" value="${storeId }">
	<table class="info_container">
		<colgroup>
			<col style="width:200px;">
			<col style="width: 500px;">
		</colgroup>
		<tbody>
			<tr>
				<td>메뉴 이름 </td>
				<td><input type="text" name="menuName" id="menuName0"></td>
			</tr>
			<tr>
				<td>메뉴 가격 </td>
				<td><input type="text" name="price" id="price0"></td>
			</tr>
			<tr>
				<td>메뉴 설명 </td>
				<td><textarea name="description" id="description0" rows="2" cols="40"></textarea></td>
			</tr>
			<tr>
				<td>메뉴 사진 </td>
				<td>
					<input type="file" id="fileName0" name="fileName" accept="image/*">
					<label for="fileName0" style="cursor:pointer; background:#007bff; color:#fff; padding:5px 10px; border-radius:4px;">파일 선택</label>
					<span id="showFileName0" style="margin-left:10px; font-size:14px; color:#333;">선택된 파일 없음</span>
				</td>
			</tr>
			<tr>
				<td>메뉴 이름 </td>
				<td><input type="text" name="menuName" id="menuName1"></td>
			</tr>
			<tr>
				<td>메뉴 가격 </td>
				<td><input type="text" name="price" id="price1"></td>
			</tr>
			<tr>
				<td>메뉴 설명 </td>
				<td><textarea name="description" id="description1" rows="2" cols="40"></textarea></td>
			</tr>
			<tr>
				<td>메뉴 사진 </td>
				<td>
					<input type="file" id="fileName1" name="fileName" accept="image/*">
					<label for="fileName1" style="cursor:pointer; background:#007bff; color:#fff; padding:5px 10px; border-radius:4px;">파일 선택</label>
					<span id="showFileName1" style="margin-left:10px; font-size:14px; color:#333;">선택된 파일 없음</span>
				</td>
			</tr>
			<tr>
				<td>메뉴 이름 </td>
				<td><input type="text" name="menuName" id="menuName2"></td>
			</tr>
			<tr>
				<td>메뉴 가격 </td>
				<td><input type="text" name="price" id="price2"></td>
			</tr>
			<tr>
				<td>메뉴 설명 </td>
				<td><textarea name="description" id="description2" rows="2" cols="40"></textarea></td>
			</tr>
			<tr>
				<td>메뉴 사진 </td>
				<td>
					<input type="file" id="fileName2" name="fileName" accept="image/*">
					<label for="fileName2" style="cursor:pointer; background:#007bff; color:#fff; padding:5px 10px; border-radius:4px;">파일 선택</label>
					<span id="showFileName2" style="margin-left:10px; font-size:14px; color:#333;">선택된 파일 없음</span>
				</td>
			</tr>
		</tbody>
		
		<tbody id="moreMenu" class="menu_container"></tbody>
	</table>
	<input type="button" value="메뉴 추가" onClick="addMenu()">
	<input type="button" onClick="checkMenu()" value="메뉴 등록">
</form>

