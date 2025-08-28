<%-- src/main/webapp/WEB-INF/views/reservation/owner/manageBookingList.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>${store.storeName} 예약 관리</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .container-fluid {
            max-width: 1200px;
            margin-top: 50px;
        }
        .badge {
            font-weight: bold;
        }
        /* 예약 상태별 뱃지 색상 */
        .badge-pending { background-color: #ffc107; color: #212529; } /* warning */
        .badge-confirmed { background-color: #28a745; color: #fff; } /* success */
        .badge-cancelled { background-color: #dc3545; color: #fff; } /* danger */
        .badge-completed { background-color: #007bff; color: #fff; } /* primary */
        .badge-no_show { background-color: #6c757d; color: #fff; } /* secondary */
        .table-responsive {
            margin-top: 20px;
        }
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
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="all-tab" data-bs-toggle="tab" data-bs-target="#all" type="button" role="tab" aria-controls="all" aria-selected="true">전체</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="pending-tab" data-bs-toggle="tab" data-bs-target="#pending" type="button" role="tab" aria-controls="pending" aria-selected="false">대기중</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="confirmed-tab" data-bs-toggle="tab" data-bs-target="#confirmed" type="button" role="tab" aria-controls="confirmed" aria-selected="false">승인됨</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="completed-tab" data-bs-toggle="tab" data-bs-target="#completed" type="button" role="tab" aria-controls="completed" aria-selected="false">이용완료</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="cancelled-tab" data-bs-toggle="tab" data-bs-target="#cancelled" type="button" role="tab" aria-controls="cancelled" aria-selected="false">취소</button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="no_show-tab" data-bs-toggle="tab" data-bs-target="#no_show" type="button" role="tab" aria-controls="no_show" aria-selected="false">노쇼</button>
        </li>
    </ul>

    <div class="tab-content mt-3" id="statusTabContent">
        <div class="tab-pane fade show active" id="all" role="tabpanel" aria-labelledby="all-tab">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>상태</th>
                            <th>예약 번호</th>
                            <th>예약자 ID</th>
                            <th>예약 일시</th>
                            <th>예약 인원</th>
                            <th>테이블</th>
                            <th>신청 시각</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody id="all-table-body">
                        <%-- ⭐ JSTL로 초기 데이터 렌더링하는 대신, Ajax로 처리하도록 비워둠 --%>
                    </tbody>
                </table>
                <div id="all-loading-spinner" class="text-center d-none">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="tab-pane fade" id="pending" role="tabpanel" aria-labelledby="pending-tab">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>상태</th><th>예약 번호</th><th>예약자 ID</th><th>예약 일시</th><th>예약 인원</th><th>테이블</th><th>신청 시각</th><th>관리</th>
                        </tr>
                    </thead>
                    <tbody id="pending-table-body"></tbody>
                </table>
                <div id="pending-loading-spinner" class="text-center d-none">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="tab-pane fade" id="confirmed" role="tabpanel" aria-labelledby="confirmed-tab">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>상태</th><th>예약 번호</th><th>예약자 ID</th><th>예약 일시</th><th>예약 인원</th><th>테이블</th><th>신청 시각</th><th>관리</th>
                        </tr>
                    </thead>
                    <tbody id="confirmed-table-body"></tbody>
                </table>
                <div id="confirmed-loading-spinner" class="text-center d-none">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="tab-pane fade" id="completed" role="tabpanel" aria-labelledby="completed-tab">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>상태</th><th>예약 번호</th><th>예약자 ID</th><th>예약 일시</th><th>예약 인원</th><th>테이블</th><th>신청 시각</th><th>관리</th>
                        </tr>
</thead>
                    <tbody id="completed-table-body"></tbody>
                </table>
                <div id="completed-loading-spinner" class="text-center d-none">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="tab-pane fade" id="cancelled" role="tabpanel" aria-labelledby="cancelled-tab">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>상태</th><th>예약 번호</th><th>예약자 ID</th><th>예약 일시</th><th>예약 인원</th><th>테이블</th><th>신청 시각</th><th>취소 사유</th>
                        </tr>
                    </thead>
                    <tbody id="cancelled-table-body"></tbody>
                </table>
                <div id="cancelled-loading-spinner" class="text-center d-none">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
        </div>
        <div class="tab-pane fade" id="no_show" role="tabpanel" aria-labelledby="no_show-tab">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>상태</th><th>예약 번호</th><th>예약자 ID</th><th>예약 일시</th><th>예약 인원</th><th>테이블</th><th>신청 시각</th><th>취소 사유</th>
                        </tr>
                    </thead>
                    <tbody id="no_show-table-body"></tbody>
                </table>
                <div id="no_show-loading-spinner" class="text-center d-none">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <hr class="mt-5">
    <p>
        <a href="${contextPath}/store/storeDetail?storeId=${storeId}" class="btn btn-secondary">매장 상세로 돌아가기</a>
    </p>
</div>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // 전역 변수 설정
    let currentPage = {};
    const pageSize = 10;
    let isLoading = false;
    let hasMore = {};
    const storeId = "${storeId}";
    const contextPath = "${pageContext.request.contextPath}";

    // 현재 활성화된 탭의 상태를 가져오는 함수
    function getActiveTabStatus() {
        const activeTab = $('#statusTabs .nav-link.active');
        if (activeTab.length > 0) {
            return activeTab.attr('id').replace('-tab', '').toUpperCase();
        }
        // ⭐ active 탭이 없으면 기본값으로 'ALL'을 반환
        return 'ALL';
    }

 // 예약 데이터를 테이블에 추가하는 함수
    function addReservationsToTable(reservations, status) {
        const tbodyId = `#${status.toLowerCase()}-table-body`;
        const tbody = $(tbodyId);

        // ⭐ tbody 요소가 존재하는지 다시 한번 확인
        if (tbody.length === 0) {
            console.error(`Error: The element with ID ${tbodyId} does not exist.`);
            isLoading = false;
            // 로딩 스피너 숨기기
            $(`#${status.toLowerCase()}-loading-spinner`).css('display', 'none');
            return;
        }

        if (currentPage[status] === 0) {
            tbody.empty();
        }

        if (reservations.length === 0 && currentPage[status] === 0) {
            hasMore[status] = false;
            $(`#${status.toLowerCase()}-loading-spinner`).css('display', 'none');
            const colspan = (status === 'CANCELLED' || status === 'NO_SHOW' || status === 'ALL') ? 8 : 8;
            tbody.html(`<tr><td colspan="${colspan}" style="text-align:center;">현재 매장의 예약이 없습니다.</td></tr>`);
            return;
        }

        let htmlContent = '';
        reservations.forEach(res => {
            // ⭐ 이 변수들이 null 또는 undefined인지 확인
            const reservationStatus = res.status;
            const reservationId = res.reservationId;
            const memberId = res.memberId;
            const guestCount = res.guestCount;
            const tablesName = res.tablesName;
            const cancelledReason = res.cancelledReason;

            let reservationTimeFormatted = 'N/A';
            let createdAtFormatted = 'N/A';

            try {
                if (res.reservationTime) {
                    reservationTimeFormatted = new Date(res.reservationTime).toLocaleString('ko-KR', {
                        year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit'
                    });
                }
                if (res.createdAt) {
                    createdAtFormatted = new Date(res.createdAt).toLocaleString('ko-KR', {
                        year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit'
                    });
                }
            } catch (e) {
                console.error('Date parsing error for reservation:', res, e);
            }

            let manageButtonsHtml = '';
            if (reservationStatus === 'PENDING') {
                manageButtonsHtml = `
                    <form action="${contextPath}/reservation/owner/updateStatus" method="post" style="display:inline-block;">
                        <input type="hidden" name="reservationId" value="${reservationId}">
                        <input type="hidden" name="storeId" value="${storeId}">
                        <button type="submit" name="status" value="CONFIRMED">승인</button>
                        <button type="submit" name="status" value="CANCELLED">취소</button>
                    </form>
                `;
            } else if (reservationStatus === 'CONFIRMED') {
                manageButtonsHtml = `
                    <form action="${contextPath}/reservation/owner/updateStatus" method="post" style="display:inline-block;">
                        <input type="hidden" name="reservationId" value="${reservationId}">
                        <input type="hidden" name="storeId" value="${storeId}">
                        <button type="submit" name="status" value="COMPLETED">이용완료</button>
                        <button type="submit" name="status" value="NO_SHOW">노쇼</button>
                    </form>
                `;
            }

            let rowHtml = `
                <tr>
                    <td>${reservationStatus || '-'}</td>
                    <td>${reservationId || '-'}</td>
                    <td>${memberId || '-'}</td>
                    <td>${reservationTimeFormatted || '-'}</td>
                    <td>${guestCount || '-'}명</td>
                    <td>${tablesName || 'N/A'}</td>
                    <td>${createdAtFormatted || '-'}</td>
            `;

            if (status === 'CANCELLED' || status === 'NO_SHOW') {
                rowHtml += `<td>${cancelledReason || '-'}</td>`;
            } else {
                rowHtml += `<td>${manageButtonsHtml}</td>`;
            }
            rowHtml += `</tr>`;
            htmlContent += rowHtml;
        });

        tbody.append(htmlContent);
        isLoading = false;
        $(`#${status.toLowerCase()}-loading-spinner`).css('display', 'none');
    }

    // 데이터를 불러오는 AJAX 함수
    function fetchReservations() {
        if (isLoading) {
            return;
        }

        const status = getActiveTabStatus();

        if (typeof hasMore[status] === 'undefined') {
            hasMore[status] = true;
        }

        if (!hasMore[status]) {
            return;
        }

        isLoading = true;
        $(`#${status.toLowerCase()}-loading-spinner`).removeClass('d-none');

        if (typeof currentPage[status] === 'undefined') {
            currentPage[status] = 0;
        }

        $.ajax({
            url: `${contextPath}/reservation/owner/api/reservations`,
            type: 'GET',
            data: {
                storeId: storeId,
                status: status,
                page: currentPage[status],
                size: pageSize
            },
            success: function(reservations) {
                console.log('Ajax success. Received reservations:', reservations);
                addReservationsToTable(reservations, status);
                currentPage[status]++;
            },
            error: function(error) {
                console.error('Error fetching data:', error);
            },
            complete: function() {
                isLoading = false;
                $(`#${status.toLowerCase()}-loading-spinner`).addClass('d-none');
            }
        });
    }

    // 탭 전환 이벤트 리스너
    $('#statusTabs button[data-bs-toggle="tab"]').on('shown.bs.tab', function(e) {
        const status = getActiveTabStatus();

        currentPage[status] = 0;
        hasMore[status] = true;

        $('.tab-content .table tbody').not(`#${status.toLowerCase()}-table-body`).empty();

        fetchReservations();
    });

    // 스크롤 이벤트 리스너
    $(window).on('scroll', function() {
        const scrollHeight = $(document).height();
        const scrollPosition = $(window).height() + $(window).scrollTop();
        if (scrollPosition > scrollHeight - 100) {
            fetchReservations();
        }
    });

    // 페이지 로드 시 초기 데이터 로드 (Ajax로 통일)
    $(document).ready(function() {
        fetchReservations();
    });
</script>
</body>
</html>