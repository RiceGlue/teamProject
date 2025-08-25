<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>


<!-- 컨트롤러에서 보낸 성공 메시지(msg)가 있을 경우, alert 창을 띄웁니다. -->
<c:if test="${not empty msg}">
    <script>
        // 페이지 로드가 완료된 후 alert를 띄워 안정성을 높입니다.
        window.onload = function() {
            alert("${msg}");
        };



    </script>
</c:if>

<script type="text/javascript">
function checkReviewStatus(status, type, storeId, id) {
    let isReviewable = false;
    let alertMessage = '';
    const contextPath = '${contextPath}';

    // 웨이팅 상태 체크
    if (type === 'waiting') {
        if (status === 'SEATED') {
            isReviewable = true;
        } else {
            alertMessage = '입장 완료된 웨이팅만 리뷰를 남길 수 있습니다.';
        }
    }
    // 예약 상태 체크
    else if (type === 'reservation') {
        // 이 상태 값은 시스템에 맞게 조정해야 합니다.
        // 'COMPLETED'나 'USED' 등 실제 예약 완료 상태
        if (status === 'COMPLETED' || status === 'USED') {
            isReviewable = true;
        } else {
            alertMessage = '이용 완료된 예약만 리뷰를 남길 수 있습니다.';
        }
    }

    if (isReviewable) {
        // 리뷰 가능한 상태이면 해당 페이지로 이동
        if (type === 'waiting') {
            window.location.href = contextPath + '/review/reviewForm?memberId=${memberInfo.memberId}&storeId=' + storeId + '&waitingId=' + id;
        } else if (type === 'reservation') {
            window.location.href = contextPath + '/review/reviewForm?memberId=${memberInfo.memberId}&storeId=' + storeId + '&reservationId=' + id;
        }
    } else {
        // 리뷰 불가능한 상태이면 알림창 표시
        alert(alertMessage);
    }
}
</script>

<style>
    /* 가로 스크롤을 위한 스타일 */
    .scroll-container {
        overflow-x: auto;
        white-space: nowrap;
        padding-bottom: 15px;
        position: relative;
    }
    .scroll-item {
        display: inline-block;
        width: 220px; /* 각 아이템의 너비 */
        margin-right: 15px;
        white-space: normal;
        vertical-align: top;
    }
    /* 스크롤바 숨기기 (선택 사항) */
    .scroll-container::-webkit-scrollbar {
/*         display: none; */
    }
    .profile-img {
        width: 150px;
        height: 150px;
        object-fit: cover; /* 이미지가 원 안에서 잘리지 않고 꽉 차도록 설정 */
    }
/*     /* 오른쪽 끝에 어둡게 만드는 그라데이션 효과 추가 */ */
/*     .scroll-container::after { */
/*         content: ""; */
/*         position: absolute; */
/*         top: 0; */
/*         right: 0; /* 이 속성은 컨테이너의 오른쪽 끝에 위치시킵니다. */ */
/*         width: 50px; */
/*         height: 100%; */
/*         background: linear-gradient(to right, rgba(255, 255, 255, 0), rgba(0, 0, 0, 0.1)); */
/*         pointer-events: none; */
/*         z-index: 1; /* z-index를 추가하여 콘텐츠 위에 겹쳐지도록 합니다. */ */
/*     } */
</style>

<div class="container my-5">

    <%-- 프로필 섹션 --%>
    <div class="row mb-5 align-items-center">
        <div class="col-auto"> <%-- col-md-2 대신 col-auto로 변경하여 이미지 크기에 맞게 조절 --%>
            <c:choose>
                <c:when test="${not empty memberInfo.profileImageUrl}">
                    <img src="${contextPath}${memberInfo.profileImageUrl}" class="img-fluid rounded-circle profile-img" alt="프로필 이미지">
                </c:when>
                <c:otherwise>
                    <img src="${contextPath}/images/default_profile.png" class="img-fluid rounded-circle profile-img" alt="기본 프로필 이미지">
                </c:otherwise>
            </c:choose>
        </div>
        <%-- (수정) 버튼을 아래로 내리고 오른쪽 정렬하기 위해 구조 변경 --%>
        <div class="col">
            <div>
                <h2 class="mb-1">@${memberInfo.memberName}</h2>
                <div class="mb-2">
                    <span>매너온도</span>
                    <span class="fw-bold text-primary">${memberInfo.mannerTemperature}°C</span>
                    <div class="progress" style="height: 10px;">
                        <div class="progress-bar bg-primary" role="progressbar" style="width: ${memberInfo.mannerTemperature}%;" aria-valuenow="${memberInfo.mannerTemperature}" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>
            </div>
            <div class="text-end mt-2">
                <a href="${contextPath}/member/edit-profile" class="btn btn-outline-secondary">프로필 수정</a>
            </div>
        </div>
    </div>

    <%-- 웨이팅 정보 섹션 --%>
    <div class="mb-5">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4><i class="bi bi-clock-history"></i> 나의 웨이팅 정보</h4>
            <a href="#" class="text-decoration-none">&gt;&gt; 더보기</a>
        </div>
        <div class="scroll-container">
	        <c:choose>
	            <c:when test="${not empty waitings}">
	                <c:forEach var="waiting" items="${waitings}">
	                    <div class="card scroll-item">
	                        <div class="card-body">
	                            <h5 class="card-title">${waiting.storeName}</h5>
	                            <p class="card-text">
	                                대기번호: <span class="fw-bold text-danger">${waiting.waitingNumber}번</span>
	                            </p>
	                            <p class="card-text">
	                                <small class="text-muted">내 앞 대기: ${waiting.aheadCount}팀</small>
	                            </p>
	                            <p class="card-text">
	                                <small class="text-muted">상태: ${waiting.status}</small>
	                            </p>
	                            <!-- <a href="#" class="btn btn-sm btn-primary">상세보기</a> -->
	                            <%-- <a href="${contextPath}/review/reviewForm?memberId=${memberInfo.memberId}&storeId=${waiting.storeId}&waitingId=${waiting.waitingId}" class="btn btn-sm btn-primary">리뷰쓰기</a> --%>
	                            <a href="javascript:void(0);" onclick="checkReviewStatus('${waiting.status}', 'waiting', '${waiting.storeId}', '${waiting.waitingId}');"
	                               class="btn btn-sm btn-primary">
	                               리뷰쓰기
                            	</a>
	                        </div>
	                    </div>
	                </c:forEach>
	            </c:when>
	            <c:otherwise>
	                <div class="card scroll-item">
	                    <div class="card-body text-center">
	                        <p class="card-text text-muted">웨이팅 정보가 없습니다.</p>
	                    </div>
	                </div>
	            </c:otherwise>
	        </c:choose>
	    </div>
    </div>

    <%-- 나의 위시리스트 섹션 --%>
    <div class="mb-5">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4><i class="bi bi-heart-fill"></i> 나의 위시리스트</h4>
            <a href="#" class="text-decoration-none">&gt;&gt; 더보기</a>
        </div>
        <div class="scroll-container">
            <%-- TODO: DB에서 실제 위시리스트 목록을 가져와 c:forEach로 반복 --%>
            <c:choose>
                <c:when test="${not empty wishlists}">
                    <c:forEach var="wishlist" items="${wishlists}">
                        <div class="card scroll-item">
                            <img src="${contextPath}/download?directoryName=store&fileName=${wishlist.storeFileName}" class="card-img-top" alt="${wishlist.storeName} 이미지">
                            <div class="card-body">
                                <h6 class="card-title">${wishlist.storeName}</h6>
                                <p class="card-text"><small class="text-muted">${wishlist.address}</small></p>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="card scroll-item">
                        <div class="card-body text-center">
                            <p class="card-text text-muted">위시리스트 정보가 없습니다.</p>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <%-- 예약 정보 섹션 --%>
    <div>
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4><i class="bi bi-calendar-check"></i> 나의 예약 정보</h4>
            <a href="#" class="text-decoration-none">&gt;&gt; 더보기</a>
        </div>
        <div class="scroll-container">
	        <c:choose>
	            <c:when test="${not empty reservations}">
	                <c:forEach var="reservation" items="${reservations}">
	                    <div class="card scroll-item">
	                        <div class="card-body">
	                            <%-- TODO: ReservationVO에 가게 이름이 없다면 storeId를 표시합니다. --%>
	                            <%-- <h5 class="card-title">가게 ID: ${reservation.storeId}</h5> --%>
								<h5 class="card-title">${reservation.storeName}</h5>
	                            <p class="card-text">
	                                예약 시간:
	                                <strong>
	                                    <%-- Date 객체인 reservationDate를 사용하여 포맷팅 --%>
	                                    <fmt:formatDate value="${reservation.reservationDate}" pattern="yyyy년 MM월 dd일 HH:mm"/>
	                                </strong>
	                            </p>
	                            <p class="card-text">
	                                예약 인원: <strong>${reservation.guestCount}명</strong>
	                            </p>
	                            <p class="card-text">
	                                상태: <strong>${reservation.status}</strong>
	                            </p>
	                            <a href="${contextPath}/reservation/customer/bookingConfirm?reservationId=${reservation.reservationId}" class="btn btn-sm btn-primary">상세보기</a>
	                            <%-- <a href="${contextPath}/review/reviewForm?memberId=${memberInfo.memberId}&storeId=${reservation.storeId}&reservationId=${reservation.reservationId}" class="btn btn-sm btn-primary">리뷰쓰기</a> --%>
	                            <a href="javascript:void(0);"
		                           onclick="checkReviewStatus('${reservation.status}', 'reservation', '${reservation.storeId}', '${reservation.reservationId}');"
		                           class="btn btn-sm btn-primary">
		                           리뷰쓰기
	                            </a>
	                        </div>
	                    </div>
	                </c:forEach>
	            </c:when>
	            <c:otherwise>
	                <div class="card scroll-item">
	                    <div class="card-body text-center">
	                        <p class="card-text text-muted">예약 정보가 없습니다.</p>
	                    </div>
	                </div>
	            </c:otherwise>
	        </c:choose>
	    </div>
<!--         <div class="scroll-container"> -->
<%--             TODO: DB에서 실제 예약 목록을 가져와 c:forEach로 반복 --%>
<%--             <c:forEach var="i" begin="1" end="5"> --%>
<!--                 <div class="card scroll-item"> -->
<!--                     <div class="card-body"> -->
<%--                         <h5 class="card-title">예약한 가게 ${i}</h5> --%>
<!--                         <p class="card-text">예약 시간: <strong>17:00</strong></p> -->
<!--                         <p class="card-text">예약 인원: <strong>2명</strong></p> -->
<!--                         <a href="#" class="btn btn-sm btn-primary">상세보기</a> -->
<%--                         <a href="${contextPath }/review/reviewForm?memberId=${memberInfo.memberId}&storeId=1&reservationId=22" class="btn btn-sm btn-primary">리뷰쓰기</a> --%>
<!--                     </div> -->
<!--                 </div> -->
<%--             </c:forEach> --%>
<!--         </div> -->
    </div>

</div>
