<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<c:forEach var="store" items="${storelist}">
	<tr>
		<td>
			<a href="${contextPath}/store/storeDetail.do?store_id=${store.store_id}">${store.store_name}</a>
		</td>
	<tr>
<c:forEach>