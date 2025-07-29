<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<h1>${region}
<c:forEach var="store" items="${storelist}">
	<tr>
		<td>
			<a href="${contextPath}/store/storeDetail.do?store_id=${store.store_id}">${store.storeName}</a>
		</td>
	</tr>
</c:forEach>