<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>예약하기 - ${store.storeName}</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
    <style>
        .container { max-width: 800px; margin-top: 50px; }
        .form-group label { font-weight: bold; }
        .error-message { color: red; font-size: 0.9em; margin-top: 5px; }

        /* 새로운 스타일 추가 */
        .time-slot-btn {
            width: 130px; /* 버튼 너비 확장 */
            margin: 5px;
            font-size: 0.9em;
            white-space: nowrap;
        }
        .time-slot-btn.selected {
            background-color: #0d6efd;
            color: white;
        }
        .table-select-area {
            display: none; /* 초기에는 숨김 */
            padding: 10px;
            background-color: #f8f9fa;
            border-radius: 5px;
            margin-top: 10px;
        }
        .table-slot-btn {
            margin: 5px;
        }
        .table-slot-btn.selected {
            background-color: #198754;
            color: white;
        }
        /* 예약 불가 시간대 스타일 */
        .time-slot-btn.unavailable {
            background-color: #e9ecef; /* 연한 회색 */
            color: #6c757d; /* 짙은 회색 글씨 */
            cursor: not-allowed;
            border-color: #e9ecef;
        }
        /* 선택 시 테두리 색상 유지 */
        .time-slot-btn.selected {
            border-color: #0d6efd;
        }
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

    <form action="${contextPath}/reservation/customer/book" method="post" id="reservationForm">
    <input type="hidden" name="storeId" value="${storeId}" />
    <input type="hidden" name="reservationTimeStr" id="selectedReservationTime" value="${selectedReservationTime}" />
    <input type="hidden" name="tableId" id="selectedTableId" value="${selectedTableId}" />
    <input type="hidden" name="paymentId" id="paymentIdInput" /> <div class="mb-3">
        <label for="reservationDate" class="form-label">예약 날짜:</label>
        <input type="text" class="form-control" id="reservationDate" placeholder="날짜를 선택하세요" required="true" value="${currentDate}">
    </div>

    <div id="reservation-times-area" class="mb-3" style="display: none;">
        <label class="form-label">예약 시간대 및 테이블:</label>
        <div id="time-slots-container" class="d-flex flex-wrap">
            </div>

        <div id="table-selection-container">
            </div>
    </div>

    <div class="mb-3 mt-4">
        <label for="guestCount" class="form-label">예약 인원:</label>
        <input type="number" class="form-control" id="guestCount" name="guestCount" min="1" max="10" required="true" value="${guestCount}" />
        <small class="form-text text-muted">최소 1명, 최대 10명까지 예약 가능합니다.</small>
    </div>

    <div class="mb-3">
        <label for="request" class="form-label">요청 사항 (선택 사항):</label>
        <textarea class="form-control" id="request" name="request" rows="3" placeholder="특별히 요청할 사항이 있다면 입력해주세요."></textarea>
    </div>

    <button type="button" id="payment-button" class="btn btn-primary mt-3">예약 신청하기</button>
    <a href="${contextPath}/store/storeDetail?storeId=${storeId}" class="btn btn-secondary mt-3">취소</a>
</form>
</div>

<script src="https://cdn.portone.io/v2/browser-sdk.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    $(function() {
        var contextPath = '${contextPath}';
        var preselectedDate = '${currentDate}';
        var preselectedTime = '${selectedReservationTime}'.split('T')[1];
        var preselectedTableId = '${selectedTableId}';

        $("#reservationDate").datepicker({
            dateFormat: 'yy-mm-dd',
            minDate: 0,
            onSelect: function(dateText, inst) {
                fetchAvailableSlots(dateText);
            }
        });

        function fetchAvailableSlots(date) {
            var storeId = $('[name="storeId"]').val();
            if (!storeId) {
                console.error("storeId가 유효하지 않습니다.");
                return;
            }

            $.ajax({
                url: contextPath + '/reservation/customer/available-slots',
                type: 'GET',
                data: { storeId: storeId, date: date },
                success: function(data) {
                    updateTimeSlots(data);
                    if (date === preselectedDate && preselectedTime) {
                        const timeButton = $(`#time-slots-container button[data-time="${preselectedTime}"]`);
                        if(timeButton.length) {
                             timeButton.trigger('click');
                        }
                        const tableButton = $(`#table-selection-container button[data-table-id="${preselectedTableId}"]`);
                        if(tableButton.length) {
                            tableButton.trigger('click');
                        }
                    }
                },
                error: function(xhr, status, error) {
                    console.error("Failed to fetch available slots: ", error);
                    $('#reservation-times-area').hide();
                    alert("예약 정보를 불러오는 데 실패했습니다. 다시 시도해주세요.");
                }
            });
        }

        function updateTimeSlots(data) {
            var timeSlotsContainer = $('#time-slots-container');
            var tableSelectionContainer = $('#table-selection-container');
            timeSlotsContainer.empty();
            tableSelectionContainer.empty();
            $('#reservation-times-area').show();

            if (data && Object.keys(data).length > 0) {
                const now = new Date();
                const reservationDate = $('#reservationDate').val();
                const isToday = reservationDate === now.getFullYear() + '-' + ('0' + (now.getMonth() + 1)).slice(-2) + '-' + ('0' + now.getDate()).slice(-2);
                const currentTimestamp = now.getTime();

                $.each(data, function(time, tables) {
                    const availableTablesCount = tables.length;
                    let isUnavailable = false;

                    if (availableTablesCount === 0) {
                        isUnavailable = true;
                    } else if (isToday) {
                        const slotDateTime = new Date(reservationDate + 'T' + time + ':00');
                        if (slotDateTime.getTime() < currentTimestamp) {
                            isUnavailable = true;
                        }
                    }

                    var timeButton = $('<button>')
                        .attr('type', 'button')
                        .attr('data-time', time);

                    if (isUnavailable) {
                        timeButton.removeClass('btn-outline-secondary').addClass('btn time-slot-btn unavailable');
                        timeButton.prop('disabled', true);
                        timeButton.text(time + ' (예약 마감)');
                    } else {
                         timeButton.addClass('btn btn-outline-secondary time-slot-btn');
                         timeButton.text(time + ' (' + availableTablesCount + '석)');
                    }
                    timeSlotsContainer.append(timeButton);

                    var tableArea = $('<div>')
                        .addClass('table-select-area')
                        .attr('id', 'table-area-' + time.replace(':', ''));

                    if (tables && tables.length > 0) {
                         $.each(tables, function(index, table) {
                            var tableButton = $('<button>')
                                .addClass('btn btn-outline-success table-slot-btn')
                                .attr('type', 'button')
                                .attr('data-table-id', table.tableId)
                                .attr('data-time', time)
                                .text(table.tableName + ' (' + table.capacity + '인석)');
                            tableArea.append(tableButton);
                         });
                    } else {
                        tableArea.html('<p class="text-muted">예약 가능한 테이블이 없습니다.</p>');
                    }
                    tableSelectionContainer.append(tableArea);
                });

            } else {
                alert("선택하신 날짜에는 예약 가능한 시간이 없습니다.");
            }
        }

        if (preselectedDate) {
            $("#reservationDate").val(preselectedDate);
            fetchAvailableSlots(preselectedDate);
        } else {
             var today = new Date();
             var todayFormatted = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
             $("#reservationDate").val(todayFormatted);
             fetchAvailableSlots(todayFormatted);
        }

        $('#time-slots-container').on('click', '.time-slot-btn:not(.unavailable)', function() {
            $('.time-slot-btn').removeClass('selected');
            $(this).addClass('selected');
            $('.table-select-area').hide();
            var selectedTime = $(this).data('time').replace(':', '');
            $('#table-area-' + selectedTime).show();

            $('.table-slot-btn').removeClass('selected');
            $('#selectedTableId').val('');

            var date = $('#reservationDate').val();
            var reservationDateTime = date + 'T' + $(this).data('time');
            $('#selectedReservationTime').val(reservationDateTime);
        });

        $('#table-selection-container').on('click', '.table-slot-btn', function() {
            var selectedTime = $('.time-slot-btn.selected').data('time');
            if (!selectedTime) {
                alert('먼저 시간을 선택해주세요.');
                return;
            }
            $('.table-slot-btn').not(this).removeClass('selected');
            $(this).toggleClass('selected');

            var tableId = $(this).hasClass('selected') ? $(this).data('table-id') : '';
            $('#selectedTableId').val(tableId);
        });

        $('#payment-button').on('click', function(e) {
            if (!$('#selectedReservationTime').val() || !$('#selectedTableId').val()) {
                alert('예약 날짜, 시간, 테이블을 모두 선택해주세요.');
                return;
            }
            requestPay();
        });

     // PortOne을 사용하여 결제를 요청하는 함수 (수정된 버전)
        function requestPay() {
            if (!$('#selectedReservationTime').val() || !$('#selectedTableId').val()) {
                alert('예약 날짜, 시간, 테이블을 모두 선택해주세요.');
                return;
            }

            const { PortOne } = window;
            const storeName = '${store.storeName}';
            const storeId = $('[name="storeId"]').val();
            const orderId = `reservation_${storeId}_${Date.now()}`;

            $('#paymentIdInput').val(orderId);

            PortOne.requestPayment({
                // 1. 가맹점 식별코드: 포트원 대시보드에서 발급받은 실제 값 사용
                // 이미지의 storeId가 'store-b124e965...'라면 해당 값 사용
                storeId: 'store-b124e965-36a7-42f5-83bf-12be9a8633f5',

                // 2. PG사 정보
                // 연동 정보 스크린샷에 나온 PG Provider 'inicis_v2'를 기반으로
                // pg 파라미터는 'inicis'로만 지정합니다.
                pg: 'inicis',
                payMethod: 'card', // 필수 파라미터: 결제 수단 (예: 'card')

                // 3. 결제 정보
                name: `${storeName} 예약 결제`,
                amount: 100, // 테스트 금액 100원
                orderId: orderId,

                // 4. 고객 정보
                customer: {
                    fullName: '테스터조원기',
                    phoneNumber: '010-7277-7829',
                    email: 'ksd0607@naver.com'
                },

                // 5. 콜백 및 리다이렉션 설정
                redirectUrl: window.location.href
            })
            .then(function(response) {
                if (response.code === '0000') {
                    alert('결제에 성공했습니다.');
                    $('#reservationForm').submit();
                } else {
                    alert(`결제에 실패했습니다. 에러 메시지: ${response.message}`);
                }
            })
            .catch(function(error) {
                alert(`결제 요청 중 오류가 발생했습니다: ${error.message}`);
            });
        }
    });
</script>
</body>
</html>