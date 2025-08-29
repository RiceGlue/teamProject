<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <title>예약 완료</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        .container { max-width: 800px; margin-top: 50px; }
        .card-header { font-weight: bold; font-size: 1.2em; }
        .card-body p { margin-bottom: 0.5rem; }
    </style>
</head>
<body>
<div class="container">
    <div class="card shadow-sm">
        <c:if test="${not empty confirmedReservation}">
            <!-- 예약 정보가 있을 때만 성공 메시지 표시 -->
            <div class="card-header bg-success text-white text-center">
                <h4 class="mb-0">✅ 예약이 성공적으로 완료되었습니다!</h4>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <!-- 에러 메시지가 있을 때만 경고 헤더 표시 -->
            <div class="card-header bg-danger text-white text-center">
                <h4 class="mb-0">❌ 예약 정보를 불러오는 데 실패했습니다.</h4>
            </div>
        </c:if>

        <div class="card-body p-4">
            <c:choose>
                <c:when test="${not empty confirmedReservation}">
                    <!-- 예약 정보가 있을 때만 상세 정보 표시 -->
                    <h5 class="card-title mt-3">예약 상세 정보</h5>
                    <hr>
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong>매장 이름:</strong> ${store.storeName}</p>
                            <p><strong>매장 주소:</strong> ${store.roadAddress}</p>
                            <p><strong>예약 번호:</strong> <span id="reservationIdDisplay">${confirmedReservation.reservationId}</span></p>
                            <c:if test="${not empty paymentId}">
                                <p><strong>결제 ID:</strong> ${paymentId}</p>
                            </c:if>
                            <c:if test="${not empty transactionId}">
                                <p><strong>거래 ID:</strong> ${transactionId}</p>
                            </c:if>
                        </div>
                        <div class="col-md-6">
                            <p><strong>예약 날짜:</strong>
                            	<fmt:formatDate value="${reservationDate}" pattern="yyyy년 MM월 dd일"/>
                            </p>
                            <p><strong>예약 시간:</strong>
                                <fmt:formatDate value="${reservationDate}" pattern="a h시 mm분"/>
                            </p>
                            <p><strong>예약 인원:</strong> ${confirmedReservation.guestCount}명</p>

                            <p>
							    <strong>테이블:</strong>
							    <c:choose>
							        <c:when test="${not empty tableNames}">
							            ${tableNames}
							        </c:when>
							        <c:otherwise>
							            지정되지 않음
							        </c:otherwise>
							    </c:choose>
							</p>
                        </div>
                    </div>
<%--                     <c:if test="${not empty confirmedReservation.request}"> --%>
<!--                         <h5 class="mt-4">요청 사항</h5> -->
<%--                         <p class="border p-2 rounded bg-light">${confirmedReservation.request}</p> --%>
<%--                     </c:if> --%>
                </c:when>
                <c:otherwise>
                    <!-- 예약 정보가 없을 때만 에러 메시지 표시 -->
                    <div class="alert alert-warning mt-3" role="alert">
                        예약 정보를 불러오는 데 실패했습니다. 예약 번호로 확인해주세요.
                        <c:if test="${not empty param.reservationId}">
                             <p class="mt-2">예약 번호: ${param.reservationId}</p>
                        </c:if>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
        <div class="card-footer text-center">
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">홈으로 돌아가기</a>
        </div>
        <%-- 예약 취소 버튼 추가 --%>
		<div class="mt-4 text-center">
		    <button id="cancelReservationBtn" class="btn btn-danger">예약 취소</button>
		</div>
    </div>
</div>

<!-- 부트스트랩 JS 번들 -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<!-- 스크립트를 body 태그의 끝에 배치하여 모든 HTML 요소가 로드된 후에 실행되도록 함 -->
<script>
    document.getElementById('cancelReservationBtn').addEventListener('click', function() {
        const reservationId = document.getElementById('reservationIdDisplay').textContent;

        if (!reservationId) {
            alert('예약 번호를 찾을 수 없습니다.');
            return;
        }

        if (confirm("정말 예약을 취소하시겠습니까? 취소 시 결제가 환불됩니다.")) {

            // 변경된 부분: FormData 객체를 사용하여 body를 구성
            const formData = new FormData();
            formData.append('reservationId', reservationId);

            fetch('/reservation/customer/cancel-reservation', {
                method: 'POST',
                // Content-Type 헤더를 명시적으로 설정하지 않아도 됩니다.
                // fetch가 FormData를 감지하고 자동으로 'multipart/form-data'로 설정합니다.
                body: formData
            })
            .then(response => {
                if (!response.ok) {
                    // HTTP 에러 상태(400, 500 등)인 경우
                    throw new Error('네트워크 응답이 올바르지 않습니다.');
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    alert(data.message);
                    window.location.reload();
                } else {
                    alert("예약 취소 실패: " + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('예약 취소 중 오류가 발생했습니다. 다시 시도해주세요.');
            });
        }
    });
</script>
</body>
</html>
