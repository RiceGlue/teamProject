<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 기존 JSTL fmt 태그는 이제 필요 없습니다. --%>
<%-- <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> --%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<style>
    .promotion-detail-container {
        padding: 20px;
        max-width: 800px;
        margin: 0 auto;
    }
    .promotion-image {
        max-width: 100%;
        height: auto;
        border-radius: 8px;
        margin-bottom: 20px;
    }
</style>

<div class="promotion-detail-container">
    <c:if test="${not empty promotion}">
        <h2>${promotion.title}</h2>

        <p>
            기간:
            <%-- 💡 JSP에서 LocalDate의 포맷팅 메서드를 직접 사용합니다. --%>
            ${promotion.startDate}
            ~
            ${promotion.endDate}
        </p>

        <%-- ${promotion.imagePath}는 /images/promotions/ 폴더에 존재해야 합니다. --%>
        <img src="${contextPath}/images/promotions/${promotion.imagePath}" alt="${promotion.title}" class="promotion-image">

        <p>${promotion.content}</p>
    </c:if>
    <c:if test="${empty promotion}">
        <p>해당 프로모션을 찾을 수 없습니다.</p>
    </c:if>

    <button onclick="history.back()">목록으로 돌아가기</button>
</div>
