<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">

<style>
    .manage-review-list { display: flex; flex-direction: column; gap: 20px; padding: 20px; background-color: #f8f9fa; border-radius: 8px; }
    .manage-review-item { background-color: #fff; border: 1px solid #ababab; border-radius: 8px; padding: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
    .review-info-section h5 { font-weight: bold; color: #0056b3; margin-bottom: 15px; border-bottom: 2px solid #0056b3; padding-bottom: 5px; }
    .review-info-section p { margin: 0; line-height: 1.6; color: #333; }
    .review-info-section strong { color: #222; display: inline-block; width: 120px; font-weight: 600; }
    .status-select { width: 200px; font-size: 0.95rem; padding: 6px 10px; margin-top: 5px; border-radius: 6px; }
    .form-control.status-reason { margin-top: 10px; max-width: 400px; }
    .btn-status-update { margin-top: 15px; padding: 6px 12px; font-size: 0.9rem; border-radius: 6px; background-color: #17a2b8; color: #fff; border: none; transition: background-color 0.2s ease; }
    .btn-status-update:hover { background-color: #138496; }
</style>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const forms = document.querySelectorAll('.review-manage-form');

        forms.forEach(function(form) {
            const statusSelect = form.querySelector('.status-select');
            const reasonInput = form.querySelector('.status-reason');

            // 초기 상태 체크 (페이지 로드 시)
            toggleReasonInput(statusSelect.value, reasonInput);

            // 상태 변경 시 이벤트
            statusSelect.addEventListener('change', function() {
                toggleReasonInput(this.value, reasonInput);
            });

            // 제출 전 검증
            form.addEventListener('submit', function(e) {
                const status = statusSelect.value;
                const reason = reasonInput.value.trim();

                if (!status) {
                    alert("상태를 선택해주세요.");
                    e.preventDefault();
                    return;
                }

                // 거절일 때는 사유 반드시 입력
                if (status === 'REJECTED' && !reason) {
                    alert("거절 시 검열 사유를 입력해주세요.");
                    e.preventDefault();
                    return;
                }
            });
        });

        // 상태에 따라 검열 사유 입력란 표시/숨김 함수
        function toggleReasonInput(status, inputElem) {
            if (status === 'REJECTED') {
                inputElem.style.display = 'block';
            } else {
                inputElem.style.display = 'none';
                inputElem.value = '';  // 상태 바뀌면 입력란 초기화 (선택사항)
            }
        }
    });
</script>


<div class="manage-review-list">
    <!-- 📌 검열 요청 섹션 -->
    <h3>검열 요청</h3>
    <c:forEach var="manageReview" items="${manageReviewList}">
        <c:if test="${manageReview.status == 'REQUESTED' || manageReview.status == 'IN_PROGRESS'}">
            <form class="review-manage-form" action="${pageContext.request.contextPath}/review/updateReviewManageStatus" method="post">
                <div class="manage-review-item">
                    <div class="review-info-section">
                        <input type="hidden" name="manageId" value="${manageReview.manageId}" />
                        <input type="hidden" name="reviewId" value="${manageReview.reviewId}" />

                        <p><strong>리뷰 번호:</strong> ${manageReview.reviewId}</p>
                        <p><strong>요청 ID:</strong> ${manageReview.ownerId}</p>
                        <p><strong>리뷰 매장:</strong> ${manageReview.storeName}</p>
                        <p><strong>요청 사유:</strong> ${manageReview.requestReason}</p>
                        <c:if test="${not empty manageReview.customReason}">
                            <p><strong>기타 사유:</strong> ${manageReview.customReason}</p>
                        </c:if>
                        <p><strong>요청일:</strong><fmt:formatDate value="${manageReview.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" /></p>

                        <!-- 상태 변경 가능 -->
                        <p>
                            <strong>요청 상태:</strong>
                            <select name="status" class="status-select">
                                <option value="REQUESTED" ${manageReview.status == 'REQUESTED' ? 'selected' : ''}>검열 요청</option>
								<option value="IN_PROGRESS" ${manageReview.status == 'IN_PROGRESS' ? 'selected' : ''}>검열중</option>
								<option value="APPROVED" ${manageReview.status == 'APPROVED' ? 'selected' : ''}>승인</option>
								<option value="REJECTED" ${manageReview.status == 'REJECTED' ? 'selected' : ''}>거절</option>
                            </select>
                        </p>

                        <p>
                            <input type="text" name="rejectedReason"
                                   class="form-control status-reason"
                                   placeholder="검열 사유를 입력해주세요"
                                   value="${manageReview.rejectedReason}" />
                        </p>

                        <button type="submit" class="btn-status-update">상태 변경</button>
                    </div>
                </div>
            </form>
        </c:if>
    </c:forEach>

    <!-- 📌 승인 / 거절 섹션 -->
    <h3>승인 / 거절</h3>
    <c:forEach var="manageReview" items="${manageReviewList}">
        <c:if test="${manageReview.status == 'APPROVED' || manageReview.status == 'REJECTED'}">
            <div class="manage-review-item">
                <div class="review-info-section">
                    <p><strong>리뷰 번호:</strong> ${manageReview.reviewId}</p>
                    <p><strong>요청 ID:</strong> ${manageReview.ownerId}</p>
                    <p><strong>리뷰 매장:</strong> ${manageReview.storeName}</p>
                    <p><strong>요청 사유:</strong> ${manageReview.requestReason}</p>
                    <p><strong>요청일:</strong><fmt:formatDate value="${manageReview.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" /></p>

                    <c:choose>
                        <c:when test="${manageReview.status == 'APPROVED'}">
                            <p><strong>상태:</strong> 승인됨</p>
                            <%-- 승인된 건 리뷰 내용 안 보여줌, 이력만 표시 --%>
                        </c:when>
                        <c:otherwise>
                            <p><strong>상태:</strong> 거절됨</p>
                            <p><strong>거절 사유:</strong> ${manageReview.rejectedReason}</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:if>
    </c:forEach>
</div>
