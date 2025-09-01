<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="header.jsp" %>
<c:set var="contextPath"  value="${pageContext.request.contextPath}"  />

<!-- 본문 include -->
<jsp:include page="/WEB-INF/views/${body}" />

<!-- 새로 만든 채팅창 파일을 여기에 포함시킵니다. -->
<jsp:include page="../common/chat.jsp" />

<%@ include file="footer.jsp" %>