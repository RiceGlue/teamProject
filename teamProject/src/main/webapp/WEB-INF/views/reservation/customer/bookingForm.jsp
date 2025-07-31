<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%-- 기존 <%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %> 는 주석 처리하거나 제거하세요. --%>
<%-- src/main/webapp/WEB-INF/views/reservation/customer/bookingForm.jsp --%>
<%-- <%@ page contentType="text/html;charset=UTF-8" language="java" %> --%>
<%-- <%@ taglib prefix="c" uri="[http://java.sun.com/jsp/jstl/core](http://java.sun.com/jsp/jstl/core)" %> --%>
<%-- <%@ taglib prefix="form" uri="[http://www.springframework.org/tags/form](http://www.springframework.org/tags/form)" %> --%>
<html>
<head>
    <title>예약하기 - ${store.storeName}</title>
    <link rel="stylesheet" href="[https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css](https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css)">
    <style>
        .container { max-width: 600px; margin-top: 50px; }
        .form-group label { font-weight: bold; }
        .error-message { color: red; font-size: 0.9em; margin-top: 5px; }
    </style>
</head>
<body>
<div class="container">
    <h2 class="mb-4">${store.storeName} 예약하기</h2>
    <p class="text-muted">주소: ${store.address}</p>
    <hr>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger" role="alert">
                ${errorMessage}
        </div>
    </c:if>

    <form:form action="${contextPath}/reservation/customer/book" method="post" modelAttribute="reservationVO">
        <form:hidden path="storeId" value="${storeId}" /> <%-- Hidden 필드로 storeId 전달 --%>

        <div class="mb-3">
            <label for="reservationTime" class="form-label">예약 날짜 및 시간:</label>
            <%-- HTML5 datetime-local 타입 사용 --%>
            <form:input type="datetime-local" class="form-control" id="reservationTime" path="reservationTime" required="true" />
            <form:errors path="reservationTime" cssClass="error-message" />
            <small class="form-text text-muted">원하는 날짜와 시간을 선택해주세요.</small>
        </div>

        <div class="mb-3">
            <label for="guestCount" class="form-label">예약 인원:</label>
            <form:input type="number" class="form-control" id="guestCount" path="guestCount" min="1" max="10" required="true" />
            <form:errors path="guestCount" cssClass="error-message" />
            <small class="form-text text-muted">최소 1명, 최대 10명까지 예약 가능합니다.</small>
        </div>

        <div class="mb-3">
            <label for="tableId" class="form-label">테이블 선택:</label>
            <%-- TODO: 실제로는 store_tables 테이블과 reservation_settings를 활용하여 동적으로 예약 가능한 테이블 목록을 드롭다운으로 제공해야 합니다. --%>
            <%-- 현재는 임시로 입력 필드 제공 --%>
            <form:input type="number" class="form-control" id="tableId" path="tableId" placeholder="예약할 테이블 ID (예: 1)" required="true"/>
            <form:errors path="tableId" cssClass="error-message"/>
            <small class="form-text text-muted">예약할 테이블의 ID를 입력해주세요. (예: 1, 2, 3)</small>
        </div>

        <div class="mb-3">
            <label for="request" class="form-label">요청 사항 (선택 사항):</label>
            <form:textarea class="form-control" id="request" path="request" rows="3" placeholder="특별히 요청할 사항이 있다면 입력해주세요."></form:textarea>
        </div>

        <button type="submit" class="btn btn-primary mt-3">예약 신청하기</button>
        <a href="${contextPath}/store/storeDetail?storeId=${storeId}" class="btn btn-secondary mt-3">취소</a>
    </form:form>
</div>
</body>
</html>