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
            width: 100%;
            margin: 5px 0;
            font-size: 0.9em;
            white-space: nowrap;
        }
        .time-slot-btn.selected {
            background-color: #0d6efd;
            color: white;
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
        .side-by-side-container {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
        }
        .time-slot-column, .table-select-column {
            flex: 1;
        }
        .table-select-column {
             padding: 10px;
             background-color: #f8f9fa;
             border-radius: 5px;
        }
        /* ⭐⭐⭐ 시간 슬롯을 2열 그리드로 표시하도록 수정 ⭐⭐⭐ */
        #time-slots-container {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
        }
        .time-slot-btn {
            width: auto; /* 그리드에 맞춰 너비 자동 조절 */
            margin: 0; /* 그리드 갭으로 여백 처리 */
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

    <form id="reservationForm">
        <input type="hidden" name="storeId" value="${storeId}" />
        <input type="hidden" name="reservationTimeStr" id="selectedReservationTime" value="${selectedReservationTime}" />
        <input type="hidden" name="tableIds" id="selectedTableIds" />
        <input type="hidden" name="paymentId" id="paymentIdInput" />
        <input type="hidden" id="storeNameHidden" value="${store.storeName}">

        <div class="mb-3">
            <label for="reservationDate" class="form-label">예약 날짜:</label>
            <input type="text" class="form-control" id="reservationDate" placeholder="날짜를 선택하세요" required="true" value="${currentDate}">
        </div>

        <div class="mb-3">
            <label for="guestCount" class="form-label">예약 인원:</label>
            <input type="number" class="form-control" id="guestCount" name="guestCount" min="1" max="10" required="true" value="${guestCount}" />
            <small class="form-text text-muted">최소 1명, 최대 10명까지 예약 가능합니다.</small>
        </div>

        <div id="reservation-times-area" class="mb-3" style="display: none;">
            <label class="form-label">예약 시간대 및 테이블:</label>
            <div class="side-by-side-container">
                <div class="time-slot-column">
                    <!-- ⭐⭐⭐ flex-column 클래스 제거, CSS 그리드로 레이아웃 처리 ⭐⭐⭐ -->
                    <div id="time-slots-container"></div>
                </div>
                <div class="table-select-column">
                    <div id="table-selection-container">
                        <p class="text-muted">시간을 선택하면 예약 가능한 테이블 목록이 표시됩니다.</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="mb-3">
            <label for="request" class="form-label">요청 사항 (선택 사항):</label>
            <textarea class="form-control" id="request" name="request" rows="3" placeholder="특별히 요청할 사항이 있다면 입력해주세요."></textarea>
        </div>

        <button type="button" id="payment-button" class="btn btn-primary mt-3">예약 신청하기</button>
        <a href="${pageContext.request.contextPath}/store/storeDetail?storeId=${storeId}" class="btn btn-secondary mt-3">취소</a>
    </form>
</div>

<script src="https://cdn.portone.io/v2/browser-sdk.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    $(function() {
        const contextPath = '${pageContext.request.contextPath}';
        const urlParams = new URLSearchParams(window.location.search);
        const preselectedDate = urlParams.get('reservationTime')?.split('T')[0] || '';
        const preselectedTime = urlParams.get('reservationTime')?.split('T')[1] || '';
        const preselectedTableId = urlParams.get('tableId') || '';

        let availableSlotsData = {};

        $("#reservationDate").datepicker({
            dateFormat: 'yy-mm-dd',
            minDate: 0,
            onSelect: function(dateText, inst) {
                fetchAvailableSlots(dateText);
            }
        });

        $('#guestCount').on('input', function() {
            const selectedDate = $('#reservationDate').val();
            if (selectedDate) {
                fetchAvailableSlots(selectedDate);
            }
        });

        function fetchAvailableSlots(date) {
            var storeId = $('[name="storeId"]').val();
            if (!storeId) {
                console.error("storeId가 유효하지 않습니다.");
                return;
            }
            $.ajax({
                url: '${pageContext.request.contextPath}/reservation/customer/available-slots',
                type: 'GET',
                data: { storeId: storeId, date: date },
                success: function(data) {
                    availableSlotsData = data;
                    updateTimeSlots(data);
                    if (date === preselectedDate && preselectedTime && preselectedTableId) {
                        setTimeout(function() {
                            const timeButton = $('#time-slots-container button[data-time="' + preselectedTime + '"]');
                            if (timeButton.length) {
                                timeButton.addClass('selected');
                                displayTablesForTime(preselectedTime, preselectedTableId);
                                $('#selectedReservationTime').val(preselectedDate + 'T' + preselectedTime);
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
            timeSlotsContainer.empty();
            $('#table-selection-container').empty().html('<p class="text-muted">시간을 선택하면 예약 가능한 테이블 목록이 표시됩니다.</p>');
            $('#reservation-times-area').show();

            const guestCount = parseInt($('#guestCount').val(), 10) || 1;

            if (data && Object.keys(data).length > 0) {
                const now = new Date();
                const reservationDate = $('#reservationDate').val();
                const isToday = reservationDate === now.getFullYear() + '-' + ('0' + (now.getMonth() + 1)).slice(-2) + '-' + ('0' + now.getDate()).slice(-2);
                const currentTimestamp = now.getTime();

                $.each(data, function(time, tables) {
                    const totalAvailableCapacity = tables.reduce((sum, table) => sum + table.capacity, 0);

                    let isUnavailable = false;
                    let unavailableReason = '';
                    if (isToday) {
                        const slotDateTime = new Date(reservationDate + 'T' + time + ':00');
                        if (slotDateTime.getTime() < currentTimestamp) {
                            isUnavailable = true;
                            unavailableReason = '예약 마감';
                        }
                    }

                    if (!isUnavailable && totalAvailableCapacity < guestCount) {
                        isUnavailable = true;
                        unavailableReason = '예약 불가';
                    }

                    var timeButton = $('<button>')
                        .attr('type', 'button')
                        .attr('data-time', time);
                    if (isUnavailable) {
                        timeButton.removeClass('btn-outline-secondary').addClass('btn time-slot-btn unavailable');
                        timeButton.prop('disabled', true);
                        timeButton.text(time + ' (' + unavailableReason + ')');
                    } else {
                         timeButton.addClass('btn btn-outline-secondary time-slot-btn');
                         timeButton.text(time + ' (최대 ' + totalAvailableCapacity + '인)');
                    }
                    timeSlotsContainer.append(timeButton);
                });
            } else {
                alert("선택하신 날짜에는 예약 가능한 시간이 없습니다.");
            }
        }

        function displayTablesForTime(selectedTime, preselectedTableId) {
            const tableSelectionContainer = $('#table-selection-container');
            tableSelectionContainer.empty();
            $('#selectedTableIds').val('');

            const tables = availableSlotsData[selectedTime] || [];

            if (tables && tables.length > 0) {
                 $.each(tables, function(index, table) {
                    // ⭐⭐⭐ 여기를 수정합니다. table.tableName 대신 table.tableInfo를 사용합니다. ⭐⭐⭐
                    var buttonText = '테이블 ' + table.tableId + ' (최대 ' + table.capacity + '인)';
                    if (table.tableInfo) {
                        buttonText = table.tableInfo + ' (최대 ' + table.capacity + '인)';
                    }
                    var tableButton = $('<button>')
                        .addClass('btn btn-outline-success table-slot-btn')
                        .attr('type', 'button')
                        .attr('data-table-id', table.tableId)
                        .attr('data-capacity', table.capacity)
                        .text(buttonText);

                    if (preselectedTableId && String(preselectedTableId) === String(table.tableId)) {
                        tableButton.addClass('selected');
                        $('#selectedTableIds').val(table.tableId);
                    }

                    tableSelectionContainer.append(tableButton);
                 });
                 tableSelectionContainer.append('<p id="selected-capacity-info" class="mt-2 text-primary">테이블 좌석: ' + updateSelectedCapacity() + '명 / 예약 인원: ' + ($('#guestCount').val() || 1) + '명</p>');
            } else {
                tableSelectionContainer.html('<p class="text-muted">예약 가능한 테이블이 없습니다.</p>');
            }
        }

        function updateSelectedCapacity() {
            let totalCapacity = 0;
            $('.table-slot-btn.selected').each(function() {
                totalCapacity += parseInt($(this).data('capacity'), 10);
            });
            $('#selected-capacity-info').text('테이블 좌석: ' + totalCapacity + '명 / 예약 인원: ' + ($('#guestCount').val() || 1) + '명');
            return totalCapacity;
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

            var selectedTime = $(this).data('time');
            var date = $('#reservationDate').val();
            var reservationDateTime = date + 'T' + selectedTime;
            $('#selectedReservationTime').val(reservationDateTime);

            displayTablesForTime(selectedTime);
        });

        $('#table-selection-container').on('click', '.table-slot-btn', function() {
            $(this).toggleClass('selected');

            const selectedTableIds = $('.table-slot-btn.selected').map(function() {
                return $(this).data('table-id');
            }).get().join(',');
            $('#selectedTableIds').val(selectedTableIds);

            updateSelectedCapacity();
        });

        $('#payment-button').on('click', function(e) {
            const selectedTime = $('#selectedReservationTime').val();
            const selectedTableIds = $('#selectedTableIds').val();
            const guestCount = parseInt($('#guestCount').val(), 10) || 1;
            const totalCapacity = updateSelectedCapacity();

            if (!selectedTime || !selectedTableIds) {
                alert('예약 날짜, 시간, 테이블을 모두 선택해주세요.');
                return;
            }
            if (guestCount < 1) {
                alert('예약 인원은 1명 이상이어야 합니다.');
                return;
            }
            if (totalCapacity < guestCount) {
                alert('선택한 테이블의 총 인원수가 예약 인원보다 적습니다. 테이블을 더 추가해주세요.');
                return;
            }

        	//결제 요청을 먼저 시작합니다.
            requestPay();
            //saveTempReservationAndRequestPay();
        });

        function saveFinalReservation(paymentId) {
            const storeId = $('[name="storeId"]').val();
            const tableIdsArray = $('#selectedTableIds').val().split(',');

            const formData = {
                storeId: storeId,
                reservationTimeStr: $('#selectedReservationTime').val(),
                tableIds: tableIdsArray,
                guestCount: $('#guestCount').val(),
                request: $('#request').val(),
                amount: 1000,
                paymentId: paymentId
            };

            $.ajax({
                url: '${pageContext.request.contextPath}/reservation/customer/book-final',
                type: 'POST',
                data: formData,
                success: function(response) {
                    if (response === "success") {
                        console.log("최종 예약 정보 저장 성공.");
                        alert("예약이 최종 확정되었습니다.");
                        const storeId = $('[name="storeId"]').val();
                        window.location.href = `${contextPath}/reservation/customer/bookingConfirm?storeId=${storeId}`;
                    } else {
                        alert("예약 정보를 저장하는 데 실패했습니다. 관리자에게 문의해주세요.");
                    }
                },
                error: function(xhr, status, error) {
                    console.error("최종 예약 정보 저장 오류: ", error);
                    alert("결제는 성공했으나, 예약 처리 중 오류가 발생했습니다. 관리자에게 문의해주세요.");
                }
            });
        }


        function saveTempReservationAndRequestPay() {
            const storeId = $('[name="storeId"]').val();
            const transactionId = 'reservation_' + storeId + '_' + Date.now();
            const totalAmount = 1000;
            const paymentMethod = 'CARD';

            const tableIdsArray = $('#selectedTableIds').val().split(',');

            const formData = {
                storeId: storeId,
                reservationTimeStr: $('#selectedReservationTime').val(),
                tableIds: tableIdsArray,
                guestCount: $('#guestCount').val(),
                request: $('#request').val(),
                amount: totalAmount,
                paymentMethod: paymentMethod,
                transactionId: transactionId
            };

            $.ajax({
                url: '${pageContext.request.contextPath}/reservation/customer/book-temp',
                type: 'POST',
                data: formData,
                success: function(response) {
                    if (response === "success") {
                        console.log("임시 예약 정보 저장 성공. 결제 시작.");
                        requestPay(transactionId, totalAmount);
                    } else {
                        alert("예약 정보를 저장하는 데 실패했습니다. 다시 시도해주세요.");
                    }
                },
                error: function(xhr, status, error) {
                    console.error("임시 예약 정보 저장 오류: ", error);
                    alert("예약 정보를 저장하는 중 오류가 발생했습니다.");
                }
            });
        }

        async function requestPay(transactionId, totalAmount) {
            const storeName = $('#storeNameHidden').val();
            const orderName = storeName + ' 예약 결제';
            const { PortOne } = window;

            try {
                const paymentResponse = await PortOne.requestPayment({
                    storeId: 'store-b124e965-36a7-42f5-83bf-12be9a8633f5',
                    channelKey: 'channel-key-11881682-d208-4707-8709-1ac268b64c31',
                    payMethod: 'CARD',
                    orderName: orderName,
                    totalAmount: totalAmount,
                    paymentId: transactionId,
                    currency: 'CURRENCY_KRW',
                    customer: {
                        fullName: '테스터조원기',
                        phoneNumber: '010-7277-7829',
                        email: 'ksd0607@naver.com'
                    }
                });

                if (paymentResponse.code !== undefined) {
                    console.error("결제 실패 (code 존재):", paymentResponse.message);
                    return alert(paymentResponse.message);
                }

                console.log("결제 성공. paymentId:", paymentResponse.paymentId);

                const pollStatus = () => {
                    return new Promise((resolve, reject) => {
                        const intervalId = setInterval(() => {
                        	$.ajax({
                        	    url: '${pageContext.request.contextPath}/reservation/customer/api/payment-status',
                        	    type: "GET",
                        	    data: { transactionId: paymentResponse.paymentId },
                        	    success: function(response) {
                        	        if (response === "success") {
                        	            console.log("폴링 응답: success. 웹훅 처리 완료.");
                        	            clearInterval(intervalId);
                        	            resolve();
                        	        } else {
                        	            console.log("폴링 응답: pending. 웹훅 대기 중...");
                        	        }
                        	    },
                        	    error: function(xhr, status, error) {
                        	        console.error("폴링 중 오류 발생:", error);
                        	        clearInterval(intervalId);
                        	        reject(new Error("폴링 중 서버 오류가 발생했습니다."));
                        	    }
                        	});
                        }, 3000);
                    });
                };

                try {
                    await pollStatus();
                    alert("결제가 완료되었습니다. 예약이 확정되었습니다.");
                    const storeId = $('[name="storeId"]').val();
                    window.location.href = `${contextPath}/reservation/customer/bookingConfirm?storeId=${storeId}`;
                } catch (error) {
                    console.error("결제 완료 처리 실패 (폴링 오류):", error);
                    alert("결제는 성공했으나, 예약 처리 중 오류가 발생했습니다. 관리자에게 문의해주세요.");
                }

            } catch (error) {
                console.error("PortOne 결제 요청 중 오류 발생 또는 취소:", error);
                alert(`결제가 취소되었거나 실패했습니다. ${error.message || ''}`);
            }
        }
    });
</script>
</body>
</html>
