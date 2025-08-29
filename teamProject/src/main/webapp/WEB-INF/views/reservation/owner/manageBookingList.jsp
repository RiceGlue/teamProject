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
        <c:forEach var="status" items="${['ALL','CONFIRMED','COMPLETED','CANCELLED','NO_SHOW']}">
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
        <c:forEach var="status" items="${['ALL','CONFIRMED','COMPLETED','CANCELLED','NO_SHOW']}">
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

    // 주어진 상태의 예약을 비동기적으로 가져오는 함수
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

    // 가져온 예약을 테이블에 추가하는 함수
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

            // res.reservationId가 유효한 경우에만 관리 버튼을 생성
            if (res.status === 'CONFIRMED' && res.reservationId) {
                manage = '<button class="btn btn-sm btn-primary status-update-btn" data-id="' + res.reservationId + '" data-status="COMPLETED">이용완료</button>' +
                         '<button class="btn btn-sm btn-secondary status-update-btn" data-id="' + res.reservationId + '" data-status="NO_SHOW">노쇼</button>' +
                         '<button class="btn btn-sm btn-danger status-update-btn" data-id="' + res.reservationId + '" data-status="CANCELLED">취소</button>';
            }

            html += '<tr>';
            html += '<td><span class="badge badge-' + res.status.toLowerCase() + '">' + res.status + '</span></td>';
            html += '<td>' + (res.reservationId || '-') + '</td>';
            html += '<td>' + (res.memberId || '-') + '</td>';
            html += '<td>' + time + '</td>';
            html += '<td>' + res.guestCount + '명</td>';
            html += '<td>' + (res.tablesName || 'N/A') + '</td>';
            html += '<td>' + created + '</td>';

            if (res.status === 'CANCELLED' || res.status === 'NO_SHOW') {
                html += '<td>' + (res.cancelledReason || '-') + '</td>';
            } else {
                html += '<td>' + manage + '</td>';
            }
            html += '</tr>';
        });

        tbody.append(html);
    }

    // 모든 상태 변경 버튼에 대한 통합 이벤트 핸들러
    $(document).on('click', '.status-update-btn', function(event) {
        event.preventDefault();

        const reservationId = $(this).attr('data-id');
        const status = $(this).attr('data-status');

        console.log("취소 요청을 위해 전달되는 reservationId:", reservationId);
        console.log("변경될 상태:", status);

        // reservationId가 비어있는지 다시 한번 확인
        if (!reservationId || reservationId.trim() === '') {
            alert("예약 ID를 찾을 수 없습니다. 페이지를 새로고침해주세요.");
            console.error("Reservation ID is undefined, null, or empty string. Value found:", reservationId);
            return;
        }

        if (!status) {
            alert("변경될 상태를 찾을 수 없습니다.");
            console.error("Status is undefined, null, or empty string. Value found:", status);
            return;
        }

        let confirmMsg = '';
        switch (status) {
            case 'COMPLETED':
                confirmMsg = '해당 예약을 이용완료 처리하시겠습니까?';
                break;
            case 'NO_SHOW':
                confirmMsg = '해당 예약을 노쇼 처리하시겠습니까?';
                break;
            case 'CANCELLED':
                confirmMsg = '해당 예약을 취소하시겠습니까?';
                break;
        }

        if (!confirm(confirmMsg)) {
            return;
        }

        let url = '';
        if (status === 'CANCELLED') {
            url = contextPath + '/reservation/owner/cancel';
        } else {
            url = contextPath + '/reservation/owner/updateStatus';
        }

        $.ajax({
            url: url,
            type: 'POST',
            data: { reservationId: reservationId, status: status },
            success: function(response) {
                alert("상태가 업데이트되었습니다.");
                location.reload();
            },
            error: function(xhr, status, error) {
                alert("상태 업데이트에 실패했습니다. 관리자에게 문의하세요.");
                console.error("AJAX Error:", status, error);
                console.error("Response Text:", xhr.responseText);
            }
        });
    });

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

    function getActiveTabStatus() {
        const active = $('#statusTabs .nav-link.active');
        const target = active.attr('data-bs-target');
        return target ? target.substring(1).toUpperCase() : 'ALL';
    }

    $(document).ready(function() {
        ['ALL','CONFIRMED','COMPLETED','CANCELLED','NO_SHOW'].forEach(function(s) {
            currentPage[s] = 0;
            hasMore[s] = true;
        });
        fetchReservations('ALL');
    });
</script>


</body>
</html>
