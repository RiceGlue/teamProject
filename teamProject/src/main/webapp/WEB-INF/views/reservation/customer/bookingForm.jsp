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
            width: 100px;
            margin: 5px;
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
    <input type="hidden" name="reservationTime" id="selectedReservationTime" />
    <input type="hidden" name="tableId" id="selectedTableId" /> <div class="mb-3">
        <label for="reservationDate" class="form-label">예약 날짜:</label>
        <input type="text" class="form-control" id="reservationDate" placeholder="날짜를 선택하세요" required="true">
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
        <input type="number" class="form-control" id="guestCount" name="guestCount" min="1" max="10" required="true" />
        <small class="form-text text-muted">최소 1명, 최대 10명까지 예약 가능합니다.</small>
    </div>

    <div class="mb-3">
        <label for="request" class="form-label">요청 사항 (선택 사항):</label>
        <textarea class="form-control" id="request" name="request" rows="3" placeholder="특별히 요청할 사항이 있다면 입력해주세요."></textarea>
    </div>

    <button type="submit" class="btn btn-primary mt-3">예약 신청하기</button>
    <a href="${contextPath}/store/storeDetail?storeId=${storeId}" class="btn btn-secondary mt-3">취소</a>
</form>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    $(function() {
        // jQuery UI Datepicker 초기화
        $("#reservationDate").datepicker({
            dateFormat: 'yy-mm-dd',
            minDate: 0, // 오늘 날짜부터 선택 가능
            onSelect: function(dateText, inst) {
                fetchAvailableSlots(dateText);
            }
        });

        // 페이지 로드 시 오늘 날짜의 예약 현황을 불러옴
        var today = new Date();
        var todayFormatted = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
        $("#reservationDate").val(todayFormatted);
        fetchAvailableSlots(todayFormatted);

        function fetchAvailableSlots(date) {
            var storeId = $('[name="storeId"]').val();
            $.ajax({
                url: '${contextPath}/reservation/customer/available-slots',
                type: 'GET',
                data: {
                    storeId: storeId,
                    date: date
                },
                success: function(data) {
                    updateTimeSlots(data);
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

            if (data && Object.keys(data).length > 0) {
                $('#reservation-times-area').show();

                $.each(data, function(time, tables) {
                    var timeButton = $('<button>')
                        .addClass('btn btn-outline-secondary time-slot-btn')
                        .attr('type', 'button')
                        .attr('data-time', time)
                        .text(time);

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
                $('#reservation-times-area').hide();
                alert("선택하신 날짜에는 예약 가능한 시간이 없습니다.");
            }
        }

        // 시간 슬롯 버튼 클릭 이벤트 (기존과 동일)
        $('#time-slots-container').on('click', '.time-slot-btn', function() {
            $('.time-slot-btn').removeClass('selected');
            $(this).addClass('selected');

            $('.table-select-area').hide();
            var selectedTime = $(this).data('time').replace(':', '');
            $('#table-area-' + selectedTime).show();

            // 시간 선택 시 모든 테이블 선택 및 폼 필드 초기화
            $('.table-slot-btn').removeClass('selected');
            $('#selectedReservationTime').val('');
            $('#selectedTableId').val(''); // 단일 테이블 선택 필드 초기화
        });

        // ★★ 테이블 슬롯 버튼 클릭 이벤트 (단일 선택으로 원복) ★★
        $('#table-selection-container').on('click', '.table-slot-btn', function() {
            var selectedTime = $('.time-slot-btn.selected').data('time');
            if (!selectedTime) {
                alert('먼저 시간을 선택해주세요.');
                return;
            }

            // 다른 테이블 선택 해제
            $('.table-slot-btn').not(this).removeClass('selected');

            $(this).toggleClass('selected'); // 선택 클래스 토글

            var tableId = $(this).hasClass('selected') ? $(this).data('table-id') : '';

            $('#selectedTableId').val(tableId);

            var date = $('#reservationDate').val();
            var reservationDateTime = date + 'T' + selectedTime;
            $('#selectedReservationTime').val(reservationDateTime);
        });

        // 폼 제출 시 유효성 검사 (단일 선택으로 원복)
        $('#reservationForm').on('submit', function(e) {
            if (!$('#selectedReservationTime').val() || !$('#selectedTableId').val()) {
                e.preventDefault();
                alert('예약 날짜, 시간, 테이블을 모두 선택해주세요.');
            }
        });
    });
</script>
</body>
</html>