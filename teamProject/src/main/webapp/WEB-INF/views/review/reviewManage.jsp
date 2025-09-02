<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%-- External Resources --%>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<style>
.container-fluid { max-width: 900px; margin: auto; }
.store-list { display: flex; flex-direction: column; gap: 20px; padding: 10px; }
.store-item { border: 1px solid #ddd; display: flex; align-items: flex-start; gap: 20px; padding: 20px; background-color: #fff; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
.store-info { flex: 1; display: flex; flex-direction: column; gap: 10px; }
.store-info p { margin: 0; font-size: 1rem; color: #444; }
.store-info strong { color: #222; font-weight: 600; }
.review-images { margin-top: 15px; }
.review-img { width: 100px; height: 100px; object-fit: cover; border-radius: 8px; border: 1px solid #ccc; transition: transform 0.2s ease; }
.review-img:hover { transform: scale(1.05); }
.moderation-info { margin-top: 20px; padding: 15px; border-radius: 8px; background-color: #f8f9fa; border: 1px solid #e9ecef; }
.moderation-info h6 { font-weight: bold; color: #0056b3; }
.moderation-form { display: none; flex-direction: column; gap: 10px; margin-top: 15px; max-width: 500px; }
.form-control, .form-select { font-size: 0.95rem; padding: 8px 12px; }
.custom-reason { display: none; }
.btn-toggle-form, .btn-submit-form { padding: 8px 16px; font-size: 1rem; border-radius: 8px; cursor: pointer; transition: background-color 0.25s ease; }
.btn-toggle-form { background-color: #6c757d; color: white; }
.btn-toggle-form:hover { background-color: #5a6268; }
.btn-submit-form { background-color: #28a745; color: white; }
.btn-submit-form:hover { background-color: #218838; }
.status-requested { background-color: #57b0ff; }
.status-in-progress { background-color: #cdff35; }
.status-approved { background-color: #28a745; }
.status-rejected { background-color: #ff0018; }


/* --- Responsive Design --- */
@media (max-width: 768px) {
    .store-item {
        flex-direction: column;
        align-items: stretch;
    }
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const listContainer = document.querySelector('.store-list');
    
    // Event delegation for all buttons and selects
    listContainer.addEventListener('click', function(e) {
        // Toggle Form Button
        if (e.target.classList.contains('btn-toggle-form')) {
            const form = e.target.closest('.store-item').querySelector('.moderation-form');
            form.style.display = form.style.display === 'flex' ? 'none' : 'flex';
        }

        // Send Request Button
        if (e.target.classList.contains('btn-submit-form')) {
            const form = e.target.closest('form');
            const reviewId = form.querySelector('input[name="reviewId"]').value;
            const ownerId = form.querySelector('input[name="ownerId"]').value;
            const storeId = form.querySelector('input[name="storeId"]').value;
            const reasonSelect = form.querySelector('select[name="requestReason"]');
            const customReason = form.querySelector('input[name="customReason"]');
            
            const reason = reasonSelect.value;

            // Validation
            if (!reason) {
                alert('삭제 요청 사유를 선택해주세요.');
                return;
            }
            if (reason === '기타' && customReason === '') {
                alert('기타 사유를 입력해주세요.');
                return;
            }

            // AJAX request
            fetch('${pageContext.request.contextPath}/review/requestReviewManage', {
			    method: 'POST',
			    headers: {
			        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
			    },
			    body: new URLSearchParams({
			        reviewId: reviewId,
			        ownerId: ownerId,
			        storeId: storeId,
			        requestReason: reason,
			        customReason: (reason === '기타' ? customReason : '')
			    })
			})

            .then(response => {
                if (!response.ok) throw new Error('Network response was not ok.');
                return response.text();
            })
            .then(data => {
                alert('삭제 요청이 성공적으로 전송되었습니다.');
                window.location.reload(); // Refresh the page to show the updated status
            })
            .catch(error => {
                console.error('Error:', error);
                alert('요청 중 오류가 발생했습니다.');
            });
        }
    });
    
    // Reason Select Change Event Delegation
    listContainer.addEventListener('change', function(e) {
        if (e.target.classList.contains('reason-select')) {
            const form = e.target.closest('form');
            const customInput = form.querySelector('.custom-reason');
            customInput.style.display = (e.target.value === '기타') ? 'block' : 'none';
        }
    });
});
</script>

<div class="container-fluid">
    <h3>리뷰 관리</h3>
    <div class="store-list">
        <c:forEach var="review" items="${reviewList}">
            <div class="store-item">
                <div class="store-info">
                    <p><strong>리뷰 ID:</strong> ${review.reviewId}</p>
                    <p><strong>별점:</strong> ${review.rating}</p>
                    <p><strong>내용:</strong> ${review.content}</p>
                    <p><strong>작성일:</strong>
                        <fmt:formatDate value="${review.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                    </p>
                    <p><strong>작성자 ID:</strong> ${review.writerId}</p>

                    <c:if test="${not empty ImageMap[review.reviewId]}">
                        <div class="review-images d-flex flex-wrap gap-2">
                            <c:forEach var="image" items="${ImageMap[review.reviewId]}">
                                <img src="${pageContext.request.contextPath}/images/review/${image.fileName}" alt="리뷰 이미지" class="review-img">
                            </c:forEach>
                        </div>
                    </c:if>

                    <c:if test="${not empty manageMap[review.reviewId]}">
                        <div class="moderation-info">
                            <h6><i class="fa-solid fa-file-circle-check"></i> 요청 정보</h6>
                            <p><strong>요청일:</strong> <fmt:formatDate value="${manageMap[review.reviewId].createdAt}" pattern="yyyy-MM-dd HH:mm:ss" /></p>
                            <p><strong>요청 사유:</strong> ${manageMap[review.reviewId].requestReason}</p>
                            <c:if test="${not empty manageMap[review.reviewId].customReason}"><p><strong>기타 사유:</strong> ${manageMap[review.reviewId].customReason}</p></c:if>
                            <p>
	                            <strong>요청 상태:</strong>
	                            <c:set var="status" value="${manageMap[review.reviewId].status}" />
	                            <c:choose>
	                                <c:when test="${status eq 'REQUESTED'}">
	                                    <span class="status-badge status-requested">검열 요청됨</span>
	                                </c:when>
	                                <c:when test="${status eq 'IN_PROGRESS'}">
	                                    <span class="status-badge status-in-progress">검열중</span>
	                                </c:when>
	                                <c:when test="${status eq 'APPROVED'}">
	                                    <span class="status-badge status-approved">승인</span>
	                                </c:when>
	                                <c:when test="${status eq 'REJECTED'}">
	                                    <span class="status-badge status-rejected">거절</span>
	                                </c:when>
	                                <c:otherwise>
	                                    <span class="status-badge">알 수 없음</span>
	                                </c:otherwise>
	                            </c:choose>
                       		</p>
                        </div>
                    </c:if>

                    <c:if test="${empty manageMap[review.reviewId]}">
                        <button type="button" class="btn btn-toggle-form mt-3" style="width: 150px;">리뷰 검열 요청</button>
                        
                        <form class="moderation-form">
                            <input type="hidden" name="reviewId" value="${review.reviewId}" />
                            <input type="hidden" name="ownerId" value="${ownerId}" />
                            <input type="hidden" name="storeId" value="${review.storeId}" />
                            
                            <label for="reasonSelect_${review.reviewId}"><strong>삭제 요청 사유:</strong></label>
                            <select name="requestReason" id="reasonSelect_${review.reviewId}" class="form-select reason-select">
                                <option value="">-- 사유 선택 --</option>
                                <option value="비속어 또는 욕설 포함">비속어 또는 욕설 포함</option>
                                <option value="허위 사실 기재">허위 사실 기재</option>
                                <option value="개인정보 노출">개인정보 노출</option>
                                <option value="광고 또는 홍보성 내용">광고 또는 홍보성 내용</option>
                                <option value="기타">기타</option>
                            </select>
                            
                            <input type="text" name="customReason" class="form-control custom-reason" placeholder="기타 사유 입력" />
                            <button type="button" class="btn btn-submit-form">요청 전송</button>
                        </form>
                    </c:if>
                </div>
            </div>
        </c:forEach>
    </div>
    
<%
    // JSP scriptlet으로 reviewId Set 구성
    java.util.Set<Long> displayedReviewIds = new java.util.HashSet<>();
    java.util.List reviewList = (java.util.List) request.getAttribute("reviewList");

    if (reviewList != null) {
        for (Object obj : reviewList) {
            com.spring.teamProject.vo.ReviewVO r = (com.spring.teamProject.vo.ReviewVO) obj;
            displayedReviewIds.add(r.getReviewId());
        }
    }

    request.setAttribute("displayedReviewIds", displayedReviewIds);
%>

<c:forEach var="entry" items="${manageMap}">
    <c:if test="${not displayedReviewIds.contains(entry.key)}">
        <div class="store-item">
            <div class="store-info">
                <p><strong>리뷰 ID:</strong> ${entry.key}</p>
                <div class="moderation-info">
                    <h6><i class="fa-solid fa-file-circle-check"></i> 요청 정보 (삭제된 리뷰)</h6>
                    <p><strong>요청일:</strong> <fmt:formatDate value="${entry.value.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" /></p>
                    <p><strong>요청 사유:</strong> ${entry.value.requestReason}</p>
                    <c:if test="${not empty entry.value.customReason}">
                        <p><strong>기타 사유:</strong> ${entry.value.customReason}</p>
                    </c:if>
                    <p>
                        <strong>요청 상태:</strong>
                        <c:choose>
                            <c:when test="${entry.value.status eq 'REQUESTED'}">
                                <span class="status-badge status-requested">검열 요청됨</span>
                            </c:when>
                            <c:when test="${entry.value.status eq 'IN_PROGRESS'}">
                                <span class="status-badge status-in-progress">검열중</span>
                            </c:when>
                            <c:when test="${entry.value.status eq 'APPROVED'}">
                                <span class="status-badge status-approved">승인</span>
                            </c:when>
                            <c:when test="${entry.value.status eq 'REJECTED'}">
                                <span class="status-badge status-rejected">거절</span>
                            </c:when>
                            <c:otherwise>
                                <span class="status-badge">알 수 없음</span>
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </div>
        </div>
    </c:if>
</c:forEach>
    
</div>