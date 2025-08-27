<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="container-fluid">
    <h1 class="h3 mb-4 text-gray-800">새 배너 등록</h1>

    <div class="card shadow mb-4">
        <div class="card-body">
            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>
            <form action="${contextPath}/admin/banners/form" method="post" enctype="multipart/form-data">
                
                <div class="mb-3">
                    <label for="pcImageFile" class="form-label">PC용 배너 이미지 (권장: 1200x400)</label>
                    <input class="form-control" type="file" id="pcImageFile" name="pcImageFile" required>
                </div>

                <div class="mb-3">
                    <label for="mobileImageFile" class="form-label">모바일용 배너 이미지 (선택)</label>
                    <input class="form-control" type="file" id="mobileImageFile" name="mobileImageFile">
                    <div class="form-text">모바일용 이미지를 등록하지 않으면 PC용 이미지가 모바일에서도 보여집니다.</div>
                </div>

                <div class="mb-3">
                    <label for="bannerText" class="form-label">배너 텍스트</label>
                    <input type="text" class="form-control" id="bannerText" name="text" placeholder="예: 여름 특별 할인!">
                </div>

                <div class="row mb-3">
                    <div class="col">
                        <label for="startDate" class="form-label">게시 시작일</label>
                        <input type="date" class="form-control" id="startDate" name="startAt" required>
                    </div>
                    <div class="col">
                        <label for="endDate" class="form-label">게시 종료일</label>
                        <input type="date" class="form-control" id="endDate" name="endAt" required>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">게시 상태</label>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="status" id="statusActive" value="active" checked>
                        <label class="form-check-label" for="statusActive">활성</label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="status" id="statusInactive" value="inactive">
                        <label class="form-check-label" for="statusInactive">비활성</label>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">연결 유형</label>
                    <div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="linkType" id="linkTypeCustom" value="custom" checked>
                            <label class="form-check-label" for="linkTypeCustom">커스텀 주소</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="linkType" id="linkTypePromo" value="promotion">
                            <label class="form-check-label" for="linkTypePromo">프로모션 연결</label>
                        </div>
                    </div>
                </div>

                <div id="customLinkDiv" class="mb-3">
                    <label for="customUrl" class="form-label">연결할 주소 (URL)</label>
                    <input type="url" class="form-control" id="customUrl" name="linkUrl" placeholder="https://example.com">
                </div>

                <div id="promotionLinkDiv" class="mb-3" style="display: none;">
                    <label for="promotionSelect" class="form-label">연결할 프로모션</label>
                    <select class="form-select" id="promotionSelect" name="promotionId">
                        <option value="">-- 프로모션을 선택하세요 --</option>
                        <c:forEach var="promo" items="${promotionList}">
                            <option value="${promo.promotionId}">${promo.title}</option>
                        </c:forEach>
                    </select>
                </div>

                <hr>
                <button type="submit" class="btn btn-primary">저장하기</button>
                <a href="${contextPath}/admin/banners" class="btn btn-secondary">취소</a>
            </form>
        </div>
    </div>
</div>

<script>
    document.querySelectorAll('input[name="linkType"]').forEach(function(radio) {
        radio.addEventListener('change', function() {
            const customUrlInput = document.getElementById('customUrl');
            const promotionSelect = document.getElementById('promotionSelect');

            if (this.value === 'promotion') {
                document.getElementById('customLinkDiv').style.display = 'none';
                document.getElementById('promotionLinkDiv').style.display = 'block';
                customUrlInput.required = false;
                promotionSelect.required = true;
            } else {
                document.getElementById('customLinkDiv').style.display = 'block';
                document.getElementById('promotionLinkDiv').style.display = 'none';
                customUrlInput.required = true;
                promotionSelect.required = false;
            }
        });
    });
</script>
