<%-- src/main/webapp/WEB-INF/views/reservation/customer/bookingConfirm.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>예약 완료</title>
    <link rel="stylesheet" href="[https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css](https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css)">
    <style>
        .container { max-width: 600px; margin-top: 50px; text-align: center; }
        .success-icon { font-size: 4em; color: #28a745; margin-bottom: 20px; }
        .detail-card { text-align: left; border: 1px solid #ddd; border-radius: 8px; padding: 20px; margin-top: 30px; background-color: #f8f9fa; }
    </style>
</head>
<body>
<div class="container">
    <div class="success-icon">&#10004;</div>
    <h2 class="mb-3">${message}</h2>
    <p class="text-muted">성공적으로 예약이 접수되었습니다. 매장에서 확인 후 최종 확정될 예정입니다.</p>

    <div class="detail-card">
        <h5>예약 상세 정보</h5>
        <c:choose>
            <c:when test="${not empty confirmedReservation}">
                <p><strong>매장 이름:</strong> ${store.storeName}</p>
                <p><strong>예약 번호:</strong> ${confirmedReservation.reservationId}</p>
                <p><strong>예약자 이름:</strong> ${confirmedReservation.customerName}</p>
                <p><strong>연락처:</strong> ${confirmedReservation.customerPhoneNumber}</p>
                <p><strong>예약 일시:</strong> ${confirmedReservation.reservationTime}</p>
                <p><strong>예약 인원:</strong> ${confirmedReservation.guestCount}명</p>
                <p><strong>예약 테이블:</strong> ${confirmedReservation.tableId}번 테이블</p>
                <p><strong>예약 상태:</strong> <span class="badge bg-warning text-dark">${confirmedReservation.status}</span></p>
                <c:if test="${not empty confirmedReservation.request}">
                    <p><strong>요청 사항:</strong> ${confirmedReservation.request}</p>
                </c:if>
            </c:when>
            <c:otherwise>
                <p>예약 정보를 불러올 수 없습니다.</p>
            </c:otherwise>
        </c:choose>
    </div>

    <hr class="mt-5">
    <p>
        <a href="${contextPath}/store/storeDetail?storeId=${store.storeId}" class="btn btn-info">매장 상세로 돌아가기</a>
        <a href="${contextPath}/" class="btn btn-secondary">메인으로 돌아가기</a>
    </p>
</div>
</body>
</html>