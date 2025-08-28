<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">

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
const memberId = '${memberInfo.memberId}' ;
const contextPath = '${pageContext.request.contextPath}';

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

//위시리스트 상태 확인 함수 (AJAX)
function checkWishlistStatus(storeId, btnElement) {
    if (!memberId || memberId === 'null' || memberId === 'undefined' || memberId.trim() === '') return;

    $.ajax({
        url: `${contextPath}/wishlist/isWishlisted`,
        type: 'GET',
        data: { memberId: memberId, storeId: storeId },
        success: function(response) {
            if (response === true) {
                $(btnElement).addClass('active');
            } else {
                $(btnElement).removeClass('active');
            }
        },
        error: function(error) {
            console.error('위시리스트 상태 확인 중 오류:', error);
        }
    });
}

// 위시리스트 추가/제거 토글 함수 (AJAX)
function toggleWishlist(storeId, btnElement) {
    if (!memberId || memberId.trim() === '') {
        if (confirm('로그인 후 이용해주세요. 로그인 페이지로 이동하시겠습니까?')) {
            window.location.href = contextPath + '/member/login';
        }
        return;
    }

    const isWishlisted = $(btnElement).hasClass('active');
    const url = isWishlisted ? `${contextPath}/wishlist/remove` : `${contextPath}/wishlist/add`;
    const type = isWishlisted ? 'DELETE' : 'POST';
    const confirmMsg = isWishlisted ? "위시리스트에서 삭제하시겠습니까?" : "위시리스트에 추가하시겠습니까?";
    const successMsg = isWishlisted ? "위시리스트에서 삭제되었습니다." : "위시리스트에 추가되었습니다.";
    const newClass = isWishlisted ? 'removeClass' : 'addClass';

    if (confirm(confirmMsg)) {
        $.ajax({
            url: url,
            type: type,
            data: { memberId, storeId },
            success: function(response) {
                alert(successMsg);
                $(btnElement)[newClass]('active');
            },
            error: function(xhr) {
                alert(xhr.responseText || "오류가 발생했습니다.");
            }
        });
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
	.card-img-top { width:150px; }
	.wishlist-btn{background:none;border:none;cursor:pointer;font-size:24px;color:#ccc;transition:color 0.3s ease;}
	.wishlist-btn.active{color:#ff6347;}
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
								<h5><a href="${contextPath}/store/storeDetail?storeId=${waiting.storeId}" class="store-name-link">${waiting.storeName}</a></h5>
	                            <p class="card-text">
	                                대기번호: <span class="fw-bold text-danger">${waiting.waitingNumber}번</span>
	                            </p>
	                            <c:if test="${waiting.status != 'SEATED'}">
								  <p class="card-text">
								    <small class="text-muted">내 앞 대기: ${waiting.aheadCount}팀</small>
								  </p>
								</c:if>

	                            <p class="card-text">
								  <small class="text-muted">
								    상태: 
								    <c:choose>
								      <c:when test="${waiting.status == 'SEATED'}">
								        방문 완료
								      </c:when>
								      <c:otherwise>
								        ${waiting.status}
								      </c:otherwise>
								    </c:choose>
								  </small>
								</p>

	                            <!-- <a href="#" class="btn btn-sm btn-primary">상세보기</a> -->
	                            <%-- <a href="${contextPath}/review/reviewForm?memberId=${memberInfo.memberId}&storeId=${waiting.storeId}&waitingId=${waiting.waitingId}" class="btn btn-sm btn-primary">리뷰쓰기</a> --%>
	                           	<c:if test="${waiting.status == 'SEATED'}">
								  <a href="${contextPath}/review/reviewForm?memberId=${memberInfo.memberId}&storeId=${waiting.storeId}&waitingId=${waiting.waitingId}" 
								     class="btn btn-sm btn-primary">
								    리뷰쓰기
								  </a>
								</c:if>


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
	        <a href="${pageContext.request.contextPath}/wishlist" class="text-decoration-none">&gt;&gt; 더보기</a>
	    </div>
	
	    <div class="scroll-container">
	        <c:if test="${not empty wishlistStore}">
	            <c:forEach var="wishlist" items="${wishlistStore}">
	                <div class="card scroll-item">
	                    <img src="${pageContext.request.contextPath}/images/store/${wishlist.fileName}" class="card-img-top" alt="${wishlist.storeName} 이미지">
	                    <div class="card-body">
	                    	<div style="display: flex; align-items: center; gap: 10px;" >
	                        	<h6><a href="${pageContext.request.contextPath}/store/storeDetail?storeId=${wishlist.storeId}" class="store-name-link">${wishlist.storeName}</a></h6>
	                        	<button class="wishlist-btn" data-store-id="${menu.storeId }" aria-label="위시리스트 추가/제거"><i class="fa fa-bookmark"></i></button>
	                        </div>
	                        <p class="card-text">${wishlist.roadAddress}</p>
	                        <p class="card-text">${wishlist.localNumber} - ${wishlist.number1} - ${wishlist.number2}</p>
	                    </div>
	                </div>
	            </c:forEach>
	        </c:if>
	
	        <c:if test="${empty wishlistStore}">
	            <div class="card scroll-item">
	                <div class="card-body text-center">
	                    <p class="card-text text-muted">위시리스트 정보가 없습니다.</p>
	                </div>
	            </div>
	        </c:if>
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
								<%-- <h5 class="card-title">${reservation.storeName}</h5> --%>
								<h5><a href="${contextPath}/store/storeDetail?storeId=${reservation.storeId}" class="store-name-link">${reservation.storeName}</a></h5>
	                            <p class="card-text">
	                                예약 시간:
	                                <strong>
	                                    <%-- Date 객체인 reservationDate를 사용하여 포맷팅 --%>
	                                    <%-- <fmt:formatDate value="${reservation.reservationDate}" pattern="yyyy년 MM월 dd일 HH:mm"/> --%>
	                                    <fmt:formatDate value="${reservation.reservationDate}" pattern="yyyy년 MM월 dd일 HH:mm"/>
	                                </strong>
	                            </p>
	                            <p class="card-text">
	                                예약 인원: <strong>${reservation.guestCount}명</strong>
	                            </p>
	                            <p class="card-text">
								  <small class="text-muted">
								    상태: 
								    <c:choose>
								      <c:when test="${reservation.status == 'COMPLETED'}">
								        방문 완료
								      </c:when>
								      <c:otherwise>
								        ${reservation.status}
								      </c:otherwise>
								    </c:choose>
								  </small>
								</p>
	                            <a href="${contextPath}/reservation/customer/bookingConfirm?reservationId=${reservation.reservationId}" class="btn btn-sm btn-primary">상세보기</a>
	                            <%-- <a href="${contextPath}/review/reviewForm?memberId=${memberInfo.memberId}&storeId=${reservation.storeId}&reservationId=${reservation.reservationId}" class="btn btn-sm btn-primary">리뷰쓰기</a> --%>
	                            <c:if test="${reservation.status == 'COMPLETED'}">
								  <a href="${contextPath}/review/reviewForm?memberId=${memberInfo.memberId}&storeId=${reservation.storeId}&waitingId=${reservation.reservationId}" 
								     class="btn btn-sm btn-primary">
								    리뷰쓰기
								  </a>
								</c:if>
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
