<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${param.success eq 'true'}">
    <script>alert("수정 완료!");</script>
</c:if>
<c:if test="${param.error eq 'true'}">
    <script>alert("수정 실패!");</script>
</c:if>

<script>

</script>


<h1>메뉴 수정</h1>
<input type="hidden" id="storeId" name="storeId" value="${storeId}">
	
<c:forEach var="menu" items="${menuList}" varStatus="status">
	<div class="info_container" style="max-width: 700px;">
		<input type="text" id="displayNo${status.index}" name="displayNo" placeholder="${menu.displayNo}" />
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
			<div class="form-label" style="width: 200px;">메뉴 이름</div>
			<div class="form-input" style="flex: 1;">
				<input id="menuName${status.index}" name="menuName" type="text" maxLength="15" placeholder="${menu.menuName}" />
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
			<div class="form-label" style="width: 200px;">메뉴 가격</div>
			<div class="form-input" style="flex: 1;">
				<input id="price${status.index}" name="price" type="text" maxLength="15" placeholder="${menu.price}" />
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
			<div class="form-label" style="width: 200px;">메뉴 설명</div>
			<div class="form-input" style="flex: 1;">
				<textarea id="description${status.index}" name="description" rows="2" cols="40">${menu.description}</textarea>
			</div>
		</div>
		
		<div class="form-row" style="display: flex; margin-bottom: 10px; align-items: center;">
			<div class="form-label" style="width: 200px;">메뉴 이미지</div>
			<div class="form-input" style="flex: 1;">
				<img src="${menu.fileName}" alt="${menu.menuName}" style="max-width: 200px;" />
				<span style="color: gray;">이미지 없음</span>
			</div>
		</div>
	</div>
</c:forEach>
