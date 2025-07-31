<%-- src/main/webapp/WEB-INF/views/reservation/owner/manageBookingList.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>${store.storeName} 예약 관리</title>
    <link rel="stylesheet" href="[https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css](https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css)">
    <style>
        .container { max-width: 900px; margin-top: 50px; }
        .reservation-card { border: 1px solid #ddd; border-radius: 8px; padding: 15px; margin-bottom: 15px; background-color: #f9f9f9; }
        .reservation-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
        .reservation-status { font-weight: bold; }
        /* 예약 상태별 뱃지 색상 */
        .badge-pending { background-color: #ffc107; color: #212529; } /* warning */
        .badge-confirmed { background-color: #28a745; color: #fff; } /* success */
        .badge-cancelled { background-color: #dc3545; color: #fff; } /* danger */
        .badge-completed { background-color: #007bff; color: #fff; } /* primary */
        .badge-no_show { background-color: #6c757d; color: #fff; } /* secondary */
    </style>
</head>
<body>
<div class="container">
    <h2 class="mb-4">${store.storeName} 예약 관리</h2>
    <p class="text-muted">매장 주소: ${store.address}</p>
    <hr>

    <c:if test="${not empty message}">
        <div class="alert alert-success" role="alert">
                ${message}
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger" role="alert">
                ${errorMessage}
        </div>
    </c:if>

    <c:choose>
        <c:when test="${not empty reservations}">
            <c:forEach var="res" items="${reservations}">
                <div class="reservation-card">
                    <div class="reservation-header">
                        <h5>예약 번호: ${res.reservationId}</h5>
                        <span class="badge
                            <c:choose>
                                <c:when test="${res.status eq 'PENDING'}">badge-pending</c:when>
                                <c:when test="${res.status eq 'CONFIRMED'}">badge-confirmed</c:when>
                                <c:when test="${res.status eq 'CANCELLED'}">badge-cancelled</c:when>
                                <c:when test="${res.status eq 'COMPLETED'}">badge-completed</c:when>
                                <c:when test="${res.status eq 'NO_SHOW'}">badge-no_show</c:when>
                                <c:otherwise>badge-secondary</c:otherwise>
                            </c:choose>">
                            ${res.status}
                        </span>
                    </div>
                    <%-- TODO: member_id를 통해 members 테이블에서 예약자 이름과 연락처를 조회하여 표시해야 합니다. --%>
                    <p><strong>예약자 ID:</strong> ${res.memberId}</p>
                    <p><strong>예약 일시:</strong> ${res.reservationTime}</p>
                    <p><strong>예약 인원:</strong> ${res.guestCount}명</p>
                    <p><strong>예약 테이블:</strong> ${res.tableId}번</p>
                    <p><strong>신청 시각:</strong> ${res.createdAt}</p>
                    <c:if test="${not empty res.cancelledReason}">
                        <p><strong>취소 사유:</strong> ${res.cancelledReason}</p>
                    </c:if>

                    <div class="mt-3">
                        <form action="${contextPath}/reservation/owner/updateStatus" method="post" style="display:inline-block;">
                            <input type="hidden" name="reservationId" value="${res.reservationId}">
                            <input type="hidden" name="storeId" value="${storeId}">
                            <button type="submit" name="status" value="CONFIRMED" class="btn btn-success btn-sm me-2"
                                    <c:if test="${res.status eq 'CONFIRMED'}">disabled</c:if>>
                                승인
                            </button>
                            <button type="submit" name="status" value="CANCELLED" class="btn btn-danger btn-sm me-2"
                                    <c:if test="${res.status eq 'CANCELLED'}">disabled</c:if>>
                                취소
                            </button>
                            <button type="submit" name="status" value="COMPLETED" class="btn btn-primary btn-sm me-2"
                                    <c:if test="${res.status eq 'COMPLETED'}">disabled</c:if>>
                                이용완료
                            </button>
                            <button type="submit" name="status" value="NO_SHOW" class="btn btn-secondary btn-sm"
                                    <c:if test="${res.status eq 'NO_SHOW'}">disabled</c:if>>
                                노쇼
                            </button>
                        </form>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div class="alert alert-info" role="alert">
                현재 매장의 예약이 없습니다.
            </div>
        </c:otherwise>
    </c:choose>

    <hr class="mt-5">
    <p>
        <a href="${contextPath}/store/storeDetail?storeId=${storeId}" class="btn btn-secondary">매장 상세로 돌아가기</a>
    </p>
</div>
</body>
</html>