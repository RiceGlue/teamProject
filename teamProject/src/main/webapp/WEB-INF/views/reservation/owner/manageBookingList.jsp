<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>${store.storeName} 예약 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .container-fluid { max-width: 1200px; margin-top: 50px; }
        .badge { font-weight: bold; }
        .badge-pending { background-color: #ffc107; color: #212529; }
        .badge-confirmed { background-color: #28a745; color: #fff; }
        .badge-cancelled { background-color: #dc3545; color: #fff; }
        .badge-completed { background-color: #007bff; color: #fff; }
        .badge-no_show { background-color: #6c757d; color: #fff; }
        .table-responsive { margin-top: 20px; }
    </style>
</head>
<body>
<div class="container-fluid">
    <h2 class="mb-4">${store.storeName} 예약 관리</h2>
    <p class="text-muted">매장 주소: ${store.roadAddress}</p>
    <hr>
    <c:if test="${not empty message}">
        <div class="alert alert-success" role="alert">${message}</div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger" role="alert">${errorMessage}</div>
    </c:if>

    <ul class="nav nav-tabs" id="statusTabs" role="tablist">
        <c:forEach var="status" items="${['ALL','PENDING','CONFIRMED','COMPLETED','CANCELLED','NO_SHOW']}">
            <li class="nav-item" role="presentation">
                <button class="nav-link ${status == 'ALL' ? 'active' : ''}"
                        id="${status.toLowerCase()}-tab"
                        data-bs-toggle="tab"
                        data-bs-target="#${status.toLowerCase()}"
                        type="button" role="tab"
                        aria-controls="${status.toLowerCase()}"
                        aria-selected="${status == 'ALL'}">
                    <c:choose>
                        <c:when test="${status == 'ALL'}">전체</c:when>
                        <c:when test="${status == 'PENDING'}">대기중</c:when>
                        <c:when test="${status == 'CONFIRMED'}">승인됨</c:when>
                        <c:when test="${status == 'COMPLETED'}">이용완료</c:when>
                        <c:when test="${status == 'CANCELLED'}">취소</c:when>
                        <c:when test="${status == 'NO_SHOW'}">노쇼</c:when>
                    </c:choose>
                </button>
            </li>
        </c:forEach>
    </ul>

    <div class="tab-content mt-3" id="statusTabContent">
        <c:forEach var="status" items="${['ALL','PENDING','CONFIRMED','COMPLETED','CANCELLED','NO_SHOW']}">
            <div class="tab-pane fade ${status == 'ALL' ? 'show active' : ''}"
                 id="${status.toLowerCase()}"
                 role="tabpanel"
                 aria-labelledby="${status.toLowerCase()}-tab">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                        <tr>
                            <th>상태</th><th>예약 번호</th><th>예약자 ID</th><th>예약 일시</th>
                            <th>예약 인원</th><th>테이블</th><th>신청 시각</th>
                            <c:choose>
                                <c:when test="${status == 'CANCELLED' || status == 'NO_SHOW'}">
                                    <th>취소 사유</th>
                                </c:when>
                                <c:otherwise>
                                    <th>관리</th>
                                </c:otherwise>
                            </c:choose>
                        </tr>
                        </thead>
                        <tbody id="${status.toLowerCase()}-table-body"></tbody>
                    </table>
                    <div id="${status.toLowerCase()}-loading-spinner" class="text-center d-none">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <hr class="mt-5">
    <p><a href="${contextPath}/store/storeDetail?storeId=${storeId}" class="btn btn-secondary">매장 상세로 돌아가기</a></p>
</div>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let currentPage = {}, hasMore = {}, isLoading = false;
    const pageSize = 10;
    const storeId = "${storeId}";
    const contextPath = "${pageContext.request.contextPath}";

    function fetchReservations(status) {
        const safeStatus = (status && typeof status === 'string' && status.trim() !== '') ? status : 'ALL';

        if (isLoading || hasMore[safeStatus] === false) {
            return;
        }

        isLoading = true;
        $(`#${safeStatus.toLowerCase()}-loading-spinner`).removeClass('d-none');

        if (typeof currentPage[safeStatus] === 'undefined') {
            currentPage[safeStatus] = 0;
        }

        $.ajax({
            url: contextPath + '/reservation/owner/api/reservations',
            type: 'GET',
            data: {
                storeId: storeId,
                status: safeStatus,
                page: currentPage[safeStatus],
                size: pageSize
            },
            success: function(reservations) {
                if (reservations.length < pageSize) {
                    hasMore[safeStatus] = false;
                }
                addReservationsToTable(reservations, safeStatus);
                currentPage[safeStatus]++;
            },
            error: function() {
                alert("데이터를 불러오는 중 오류가 발생했습니다.");
            },
            complete: function() {
                isLoading = false;
                $(`#${safeStatus.toLowerCase()}-loading-spinner`).addClass('d-none');
            }
        });
    }

    function addReservationsToTable(reservations, status) {
        const tbodyId = '#' + status.toLowerCase() + '-table-body';
        const tbody = $(tbodyId);

        if (tbody.length === 0) {
            console.error('Error: The element with ID ' + tbodyId + ' does not exist.');
            return;
        }

        if (currentPage[status] === 0) {
            tbody.empty();
        }

        if (reservations.length === 0 && currentPage[status] === 0) {
            hasMore[status] = false;
            tbody.html('<tr><td colspan="8" class="text-center">현재 매장의 예약이 없습니다.</td></tr>');
            return;
        }

        let html = '';
        reservations.forEach(function(res) {
            const time = new Date(res.reservationTime).toLocaleString('ko-KR');
            const created = new Date(res.createdAt).toLocaleString('ko-KR');
            let manage = '';

            if (res.status === 'PENDING') {
                manage = '<form method="post" action="' + contextPath + '/reservation/owner/updateStatus" style="display:inline-block;">'
                    + '<input type="hidden" name="reservationId" value="' + res.reservationId + '">'
                    + '<input type="hidden" name="storeId" value="' + storeId + '">'
                    + '<button class="btn btn-sm btn-success" name="status" value="CONFIRMED">승인</button>'
                    + '<button class="btn btn-sm btn-danger" name="status" value="CANCELLED">취소</button>'
                    + '</form>';
            } else if (res.status === 'CONFIRMED') {
                manage = '<form method="post" action="' + contextPath + '/reservation/owner/updateStatus" style="display:inline-block;">'
                    + '<input type="hidden" name="reservationId" value="' + res.reservationId + '">'
                    + '<input type="hidden" name="storeId" value="' + storeId + '">'
                    + '<button class="btn btn-sm btn-primary" name="status" value="COMPLETED">이용완료</button>'
                    + '<button class="btn btn-sm btn-secondary" name="status" value="NO_SHOW">노쇼</button>'
                    + '</form>';
            }

            html += '<tr>';
            html += '<td><span class="badge badge-' + res.status.toLowerCase() + '">' + res.status + '</span></td>';
            html += '<td>' + res.reservationId + '</td>';
            html += '<td>' + (res.memberId || '-') + '</td>';
            html += '<td>' + time + '</td>';
            html += '<td>' + res.guestCount + '명</td>';
            html += '<td>' + (res.tablesName || 'N/A') + '</td>';
            html += '<td>' + created + '</td>';

            if (status === 'CANCELLED' || status === 'NO_SHOW') {
                html += '<td>' + (res.cancelledReason || '-') + '</td>';
            } else {
                html += '<td>' + manage + '</td>';
            }
            html += '</tr>';
        });

        tbody.append(html);
    }

    function getActiveTabStatus() {
        const active = $('#statusTabs .nav-link.active');
        const target = active.attr('data-bs-target');
        return target ? target.substring(1).toUpperCase() : 'ALL';
    }

    $('#statusTabs button[data-bs-toggle="tab"]').on('shown.bs.tab', function(e) {
        const status = $(e.target).attr('data-bs-target').substring(1).toUpperCase();
        if (typeof currentPage[status] === 'undefined') currentPage[status] = 0;
        if (typeof hasMore[status] === 'undefined') hasMore[status] = true;

        $(`#${status.toLowerCase()}-table-body`).empty();
        fetchReservations(status);
    });

    $(window).on('scroll', function() {
        if ($(window).scrollTop() + $(window).height() > $(document).height() - 100) {
            const status = getActiveTabStatus();
            fetchReservations(status);
        }
    });

    $(document).ready(function() {
        ['ALL','PENDING','CONFIRMED','COMPLETED','CANCELLED','NO_SHOW'].forEach(function(s) {
            currentPage[s] = 0;
            hasMore[s] = true;
        });
        fetchReservations('ALL');
    });
</script>
</body>
</html>