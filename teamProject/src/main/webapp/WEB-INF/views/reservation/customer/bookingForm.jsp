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
    <input type="hidden" name="reservationTime" id="selectedReservationTime" />
    <input type="hidden" name="tableId" id="selectedTableId" />
    <div class="mb-3">
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
        // JSP 변수인 contextPath를 JavaScript 변수로 저장
        var contextPath = '${contextPath}';

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

        // 날짜 선택 필드에 오늘 날짜를 설정하고 이벤트를 트리거하여 예약 슬롯을 불러옴
        $("#reservationDate").val(todayFormatted);
        fetchAvailableSlots(todayFormatted);

        function fetchAvailableSlots(date) {
            var storeId = $('[name="storeId"]').val();

            // storeId 값이 유효한지 확인
            if (!storeId) {
                console.error("storeId가 유효하지 않습니다.");
                return;
            }

            $.ajax({
                // AJAX 요청 URL을 JavaScript 변수를 사용하여 동적으로 생성
                url: contextPath + '/reservation/customer/available-slots',
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

                // 현재 시간을 가져와서 지난 시간대인지 체크
                const now = new Date();
                const reservationDate = $('#reservationDate').val();

                // 오늘 날짜인지 확인
                const isToday = reservationDate === now.getFullYear() + '-' + ('0' + (now.getMonth() + 1)).slice(-2) + '-' + ('0' + now.getDate()).slice(-2);
                const currentTimestamp = now.getTime(); // 정확한 시간 비교를 위해 타임스탬프 사용

                $.each(data, function(time, tables) {
                    // 예약 가능한 테이블 개수 계산
                    const availableTablesCount = tables.length;

                    // 예약 마감 또는 지난 시간대 여부 판단
                    let isUnavailable = false;

                    if (availableTablesCount === 0) {
                        isUnavailable = true; // 예약 테이블이 없으면 마감
                    }
                    // 오늘 날짜인 경우, 현재 시간보다 이전 시간대는 마감 처리
                    else if (isToday) {
                        const slotDateTime = new Date(reservationDate + 'T' + time + ':00'); // 초 단위 추가
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
                        timeButton.text(time + ' (예약 마감)'); // + 연산자로 문자열 연결
                    } else {
                         timeButton.addClass('btn btn-outline-secondary time-slot-btn');
                         timeButton.text(time + ' (' + availableTablesCount + '석)'); // + 연산자로 문자열 연결
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
                $('#reservation-times-area').hide();
                alert("선택하신 날짜에는 예약 가능한 시간이 없습니다.");
            }
        }

        // 시간 슬롯 버튼 클릭 이벤트 (기존과 동일)
        // '.unavailable' 클래스가 없는 버튼만 클릭 이벤트에 반응하도록 수정
        $('#time-slots-container').on('click', '.time-slot-btn:not(.unavailable)', function() {
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