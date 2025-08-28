<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
	<h1 class="h3 mb-4">대시보드 홈</h1>

	<div class="row">
		<c:choose>
			<c:when test="${empty stores}">
				<div class="col-12">
					<div class="card border-0 rounded-3 shadow-sm">
						<div class="card-body p-4 text-center">
							<h4 class="card-title mb-3">등록된 매장이 없습니다.</h4>
							<p class="text-muted">지금 바로 새로운 매장을 등록하고 관리하세요!</p>
							<a href="/owner/store/new" class="btn btn-primary mt-3"> <i
								class="bi bi-plus-circle me-2"></i>새 매장 등록하기
							</a>
						</div>
					</div>
				</div>
			</c:when>
			<c:otherwise>
				<c:forEach var="store" items="${stores}">
					<div class="col-lg-6 mb-4">
						<div class="card border-0 rounded-3 shadow-sm"
							data-store-id="${store.storeId}">
							<div class="card-body p-4">
								<h4 class="card-title mb-4">${store.storeName}
									(${store.roadAddress})</h4>
								<div class="row g-3 text-center">
									<div class="col-4">
										<a href="/reservation/owner/manageList?storeId=${store.storeId}"
											class="d-block p-3 rounded-3 text-decoration-none bg-light">
											<%-- <div class="fs-2 fw-bold text-primary">${reservationCounts[store.storeId]}</div>
											<div class="small text-muted">오늘의 예약</div> --%>

											<div class="fs-2 fw-bold text-primary">${todayConfirmedCounts[store.storeId]} / ${totalConfirmedCounts[store.storeId]}</div>
											<div class="small text-muted">오늘 확정 예약 / 총 확정 예약</div>
										</a>
									</div>
									<div class="col-4">
										<a href="/waiting/owner/settings?storeId=${store.storeId}"
											class="d-block p-3 rounded-3 text-decoration-none bg-light">
											<div class="fs-2 fw-bold text-danger realtime-waiting-count">${waitingCounts[store.storeId]}</div>
											<div class="small text-muted">실시간 웨이팅</div>
										</a>
									</div>
									<div class="col-4">
										<a href="#"
											class="d-block p-3 rounded-3 text-decoration-none bg-light">
											<div class="fs-2 fw-bold text-success">0</div>
											<div class="small text-muted">새 리뷰</div>
										</a>
									</div>
								</div>
							</div>
						</div>
					</div>
				</c:forEach>
			</c:otherwise>
		</c:choose>
	</div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
	$(document).ready(
			function() {
				// 실시간 웨이팅 수를 업데이트하는 함수
				function updateRealtimeWaitingCounts() {
					$.ajax({
						url : '/owner/api/realtimeWaitingCounts',
						type : 'GET',
						dataType : 'json',
						success : function(data) {
							// 서버로부터 받은 데이터를 기반으로 각 매장의 웨이팅 수 업데이트
							for ( var storeId in data) {
								if (data.hasOwnProperty(storeId)) {
									var count = data[storeId];
									// data-store-id 속성을 가진 div를 찾고 그 안의 클래스를 가진 div의 텍스트를 변경
									$('[data-store-id="' + storeId + '"]')
											.find('.realtime-waiting-count')
											.text(count);
								}
							}
						},
						error : function(xhr, status, error) {
							console.error("실시간 웨이팅 수 업데이트 실패:", error);
						}
					});
				}

				// **페이지 로딩 시점에 한 번 실행**
				updateRealtimeWaitingCounts();

				// 5초마다 함수 반복 실행
				setInterval(updateRealtimeWaitingCounts, 5000);
			});
</script>