<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">

<c:if test="${not empty msg}">
    <script>
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

    if (type === 'waiting') {
        if (status === 'SEATED') {
            isReviewable = true;
        } else {
            alertMessage = '입장 완료된 웨이팅만 리뷰를 남길 수 있습니다.';
        }
    } else if (type === 'reservation') {
        if (status === 'COMPLETED' || status === 'USED') {
            isReviewable = true;
        } else {
            alertMessage = '이용 완료된 예약만 리뷰를 남길 수 있습니다.';
        }
    }

    if (isReviewable) {
        if (type === 'waiting') {
            window.location.href = contextPath + '/review/reviewForm?memberId=${memberInfo.memberId}&storeId=' + storeId + '&waitingId=' + id;
        } else if (type === 'reservation') {
            window.location.href = contextPath + '/review/reviewForm?memberId=${memberInfo.memberId}&storeId=' + storeId + '&reservationId=' + id;
        }
    } else {
        alert(alertMessage);
    }
}

function checkWishlistStatus(storeId, btnElement) {
    if (!memberId || memberId.trim() === '') return;

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

    if (confirm(confirmMsg)) {
        $.ajax({
            url: url,
            type: type,
            data: { memberId, storeId },
            success: function(response) {
                alert(response);
                if (type === 'DELETE') {
                    // 삭제 성공 시 페이지 새로고침
                    window.location.reload();
                } else {
                    // 추가 성공 시 버튼 상태만 변경
                    $(btnElement).addClass('active');
                }
            },
            error: function(xhr) {
                alert(xhr.responseText || "오류가 발생했습니다.");
            }
        });
    }
}

$(document).ready(function() {
    $('.wishlist-btn').each(function() {
        const storeId = $(this).data('store-id');
        checkWishlistStatus(storeId, this);
    });

    $('.wishlist-btn').on('click', function() {
        const storeId = $(this).data('store-id');
        toggleWishlist(storeId, this);
    });
});
</script>

<style>
    .scroll-container {
        overflow-x: auto;
        white-space: nowrap;
        padding-bottom: 15px;
        position: relative;
    }
    .scroll-item {
        display: inline-block;
        width: 220px;
        margin-right: 15px;
        white-space: normal;
        vertical-align: top;
    }
    .profile-img {
        width: 150px;
        height: 150px;
        object-fit: cover;
    }
    .card-img-top {width: 100%;  height: 180px; object-fit: cover;  display: block; }
    .wishlist-btn{background:none;border:none;cursor:pointer;font-size:24px;color:#ccc;transition:color 0.3s ease;}
    .wishlist-btn.active{color:#ff6347;}
</style>

<div class="container my-5">
    <div class="row mb-5 align-items-center">
        <div class="col-auto">
            <c:choose>
                <c:when test="${not empty memberInfo.profileImageUrl}">
                    <img src="${contextPath}${memberInfo.profileImageUrl}" class="img-fluid rounded-circle profile-img" alt="프로필 이미지">
                </c:when>
                <c:otherwise>
                    <img src="${contextPath}/images/default_profile.png" class="img-fluid rounded-circle profile-img" alt="기본 프로필 이미지">
                </c:otherwise>
            </c:choose>
        </div>
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
					                        <c:when test="${waiting.status == 'SEATED'}">방문 완료</c:when>
					                        <c:otherwise>${waiting.status}</c:otherwise>
					                    </c:choose>
					                </small>
					            </p>
					            <c:if test="${waiting.status == 'SEATED'}">
								    <c:set var="hasReview" value="false" />
								    <c:set var="foundReviewId" value="" />
								    <c:forEach var="review" items="${reviewList}">
								        <c:if test="${review.waitingId == waiting.waitingId}">
								            <c:set var="hasReview" value="true" />
								            <c:set var="foundReviewId" value="${review.reviewId}" />
								        </c:if>
								    </c:forEach>
								    <c:choose>
								        <c:when test="${hasReview}">
								            <!-- 리뷰 수정 버튼 -->
								            <a href="${contextPath}/review/modifyReviewForm?reviewId=${foundReviewId}" class="btn btn-sm btn-warning">리뷰 수정</a>
								        </c:when>
								        <c:otherwise>
								            <!-- 리뷰 쓰기 버튼 -->
								            <a href="${contextPath}/review/reviewForm?memberId=${memberInfo.memberId}&storeId=${waiting.storeId}&waitingId=${waiting.waitingId}" class="btn btn-sm btn-primary">
								                리뷰 쓰기
								            </a>
								        </c:otherwise>
								    </c:choose>
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
                                <button class="wishlist-btn" data-store-id="${wishlist.storeId}" aria-label="위시리스트 추가/제거"><i class="fa fa-bookmark"></i></button>
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
                                <h5><a href="${contextPath}/store/storeDetail?storeId=${reservation.storeId}" class="store-name-link">${reservation.storeName}</a></h5>
                                <p class="card-text">
                                    예약 시간:
                                    <strong>
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
                                <c:if test="${reservation.status == 'COMPLETED'}">
								    <c:set var="hasReview" value="false" />
								    <c:set var="foundReviewId" value="" />
								    <c:forEach var="review" items="${reviewList}">
								        <c:if test="${review.reservationId == reservation.reservationId}">
								            <c:set var="hasReview" value="true" />
								            <c:set var="foundReviewId" value="${review.reviewId}" />
								        </c:if>
								    </c:forEach>
								    <c:choose>
								        <c:when test="${hasReview}">
								            <!-- 리뷰 수정 버튼 -->
								            <a href="${contextPath}/review/modifyReviewForm?reviewId=${foundReviewId}" class="btn btn-sm btn-warning">리뷰 수정</a>
								        </c:when>
								        <c:otherwise>
								            <!-- 리뷰 쓰기 버튼 -->
								            <a href="${contextPath}/review/reviewForm?memberId=${memberInfo.memberId}&storeId=${reservation.storeId}&reservationId=${reservation.reservationId}" class="btn btn-sm btn-primary">
								                리뷰 쓰기
								            </a>
								        </c:otherwise>
								    </c:choose>
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
    </div>
</div>