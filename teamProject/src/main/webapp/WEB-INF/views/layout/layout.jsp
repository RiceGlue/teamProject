<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="header.jsp" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}"  />

<!-- 본문 include -->
<jsp:include page="/WEB-INF/views/${body}" />

	<div class="fixed-div">
		<h2>실시간<br>문의</h2>
	</div>

<%@ include file="footer.jsp" %>