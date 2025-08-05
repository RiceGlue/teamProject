<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <title>예약하기 - ${store.storeName}</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
    <style>
        .container { max-width: 800px; margin-top: 50px; }
        .form-group label { font-weight: bold; }
        .error-message { color: red; font-size: 0.9em; margin-top: 5px; }
        .time-slot-btn {
            width: 130px;
            margin: 5px;
            font-size: 0.9em;
            white-space: nowrap;
        }
        .time-slot-btn.selected {
            background-color: #0d6efd;
            color: white;
        }
        .table-select-area {
            display: none;
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
        .time-slot-btn.unavailable {
            background-color: #e9ecef;
            color: #6c757d;
            cursor: not-allowed;
            border-color: #e9ecef;
        }
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
        <input type="hidden" name="paymentId" id="paymentIdInput" />
        <input type="hidden" name="guestCount" value="${guestCount}" />

        <input type="hidden" id="storeNameHidden" value="${store.storeName}">

        <div class="mb-3">
            <label for="reservationDate" class="form-label">예약 날짜:</label>
            <input type="text" class="form-control" id="reservationDate" placeholder="날짜를 선택하세요" required="true" value="${currentDate}">
        </div>

        <div id="reservation-times-area" class="mb-3" style="display: none;">
            <label class="form-label">예약 시간대 및 테이블:</label>
            <div id="time-slots-container" class="d-flex flex-wrap"></div>
            <div id="table-selection-container"></div>
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
        const urlParams = new URLSearchParams(window.location.search);
        const preselectedDate = urlParams.get('reservationTime')?.split('T')[0] || '';
        const preselectedTime = urlParams.get('reservationTime')?.split('T')[1] || '';
        const preselectedTableId = urlParams.get('tableId') || '';

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
                    if (date === preselectedDate && preselectedTime && preselectedTableId) {
                        setTimeout(function() {
                            const timeButton = $('#time-slots-container button[data-time="' + preselectedTime + '"]');
                            if (timeButton.length) {
                                timeButton.addClass('selected');
                                var selectedTimeId = timeButton.data('time').replace(':', '');
                                $(`#table-area-${selectedTimeId}`).show();
                                const tableButton = $(`#table-selection-container button[data-table-id="${preselectedTableId}"]`);
                                if (tableButton.length) {
                                    tableButton.addClass('selected');
                                    $('#selectedReservationTime').val(preselectedDate + 'T' + preselectedTime);
                                    $('#selectedTableId').val(preselectedTableId);
                                }
                            }
                        }, 50);
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
     // bookForm.jsp의 <script> 태그 안
        function requestPay() {
            if (!$('#selectedReservationTime').val() || !$('#selectedTableId').val()) {
                alert('예약 날짜, 시간, 테이블을 모두 선택해주세요.');
                return;
            }

            const storeName = $('#storeNameHidden').val();
            const storeId = $('[name="storeId"]').val();

            // PortOne API에서 요구하는 새로운 파라미터 이름에 맞춰 변수명을 변경합니다.
            const paymentId = 'reservation_' + storeId + '_' + Date.now();
            const orderName = storeName + ' 예약 결제';
            const totalAmount = 1000; // 테스트용 금액

            console.log("--- PortOne Request Parameters (Updated) ---");
            console.log("orderName:", orderName);
            console.log("paymentId:", paymentId);
            console.log("totalAmount:", totalAmount);
            console.log("-----------------------------------");

            $('#paymentIdInput').val(paymentId);

            const { PortOne } = window;
            PortOne.requestPayment({
                storeId: 'store-b124e965-36a7-42f5-83bf-12be9a8633f5',

                // --- 이 부분을 수정합니다. `pg` 대신 `channelKey`를 사용합니다. ---
                // PortOne 관리자 페이지에서 발급받은 채널 키를 여기에 넣어주세요.
                channelKey: 'channel-key-11881682-d208-4707-8709-1ac268b64c31', // 예시: 'channel-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

                payMethod: 'CARD', // `CARD`는 `payMethod`에 사용되는 올바른 값입니다.

                // --- 이 부분을 수정합니다. `name`과 `amount`, `orderId` 대신 새로운 파라미터를 사용합니다. ---
                orderName: orderName,
                totalAmount: totalAmount,
                paymentId: paymentId,
                currency: 'CURRENCY_KRW', // 통화 코드 추가 (필수)

                customer: {
                    fullName: '테스터조원기',
                    phoneNumber: '010-7277-7829',
                    email: 'ksd0607@naver.com'
                },
                redirectUrl: window.location.href
            })
            .then(function(response) {
            	// 결제 요청이 성공적으로 시작되면, 바로 폼을 제출합니다.
                // 결제 성공 여부는 서버에서 redirectUrl로 돌아온 후 확인합니다.
                //alert('결제창이 열렸습니다. 결제를 완료해 주세요.');
                //$('#reservationForm').submit();

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