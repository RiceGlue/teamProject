<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="container-fluid">
    <%-- 수정 모드일 때와 신규 등록일 때 제목을 동적으로 변경합니다. --%>
    <h1 class="h3 mb-4 text-gray-800">
        <c:choose>
            <c:when test="${not empty banner.bannerId}">배너 수정</c:when>
            <c:otherwise>새 배너 등록</c:otherwise>
        </c:choose>
    </h1>

    <div class="card shadow mb-4">
        <div class="card-body">
            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>
            
            <%-- form action 경로를 공통 저장 경로(/admin/banners/save)로 지정합니다. --%>
            <form action="${contextPath}/admin/banners/save" method="post" enctype="multipart/form-data">
                
                <%-- 수정 모드일 때, bannerId를 서버로 함께 보내기 위한 hidden input --%>
                <c:if test="${not empty banner.bannerId}">
                    <input type="hidden" name="bannerId" value="${banner.bannerId}">
                </c:if>

                <div class="mb-3">
                    <label for="pcImageFile" class="form-label">PC용 배너 이미지 <span class="text-danger">*</span></label>
                    <%-- 신규 등록일 때만 이미지 첨부를 필수로 설정합니다. --%>
                    <input class="form-control" type="file" id="pcImageFile" name="pcImageFile" <c:if test="${empty banner.bannerId}">required</c:if>>
                    <div class="form-text">권장 사이즈: 1200x400, 최대 2MB, (JPG, PNG, GIF)</div>
                    <c:if test="${not empty banner.imagePath}">
                        <div class="mt-2">
                            <small>현재 이미지:</small>
                            <img src="${contextPath}/banner-images/${banner.imagePath}" style="max-width: 200px; height: auto;" class="img-thumbnail ms-2">
                        </div>
                    </c:if>
                </div>

                <div class="mb-3">
                    <label for="mobileImageFile" class="form-label">모바일용 배너 이미지 (선택)</label>
                    <input class="form-control" type="file" id="mobileImageFile" name="mobileImageFile">
                    <div class="form-text">등록하지 않으면 PC용 이미지가 모바일에서도 보여집니다.</div>
                     <c:if test="${not empty banner.mobileImagePath}">
                        <div class="mt-2">
                            <small>현재 모바일 이미지:</small>
                            <img src="${contextPath}/banner-images/${banner.mobileImagePath}" style="max-width: 200px; height: auto;" class="img-thumbnail ms-2">
                        </div>
                    </c:if>
                </div>

                <div class="mb-3">
                    <label for="bannerText" class="form-label">배너 텍스트</label>
                    <input type="text" class="form-control" id="bannerText" name="text" value="${banner.text}">
                </div>

                <div class="row mb-3">
                    <div class="col">
                        <label for="startDate" class="form-label">게시 시작일 <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" id="startDate" name="startAt" value="${banner.startAt}" required>
                    </div>
                    <div class="col">
                        <label for="endDate" class="form-label">게시 종료일 <span class="text-danger">*</span></label>
                        <input type="date" class="form-control" id="endDate" name="endAt" value="${banner.endAt}" required>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">게시 상태 <span class="text-danger">*</span></label>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="status" id="statusActive" value="active" ${banner.status ne 'inactive' ? 'checked' : ''}>
                        <label class="form-check-label" for="statusActive">활성</label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="status" id="statusInactive" value="inactive" ${banner.status eq 'inactive' ? 'checked' : ''}>
                        <label class="form-check-label" for="statusInactive">비활성</label>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">연결 유형 <span class="text-danger">*</span></label>
                    <div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="linkType" id="linkTypeCustom" value="custom" ${empty banner.promotionId ? 'checked' : ''}>
                            <label class="form-check-label" for="linkTypeCustom">커스텀 주소</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="linkType" id="linkTypePromo" value="promotion" ${not empty banner.promotionId ? 'checked' : ''}>
                            <label class="form-check-label" for="linkTypePromo">프로모션 연결</label>
                        </div>
                    </div>
                </div>

                <div id="customLinkDiv" class="mb-3">
                    <label for="customUrl" class="form-label">연결할 주소 (URL)</label>
                    <input type="url" class="form-control" id="customUrl" name="linkUrl" value="${banner.linkUrl}">
                </div>

                <div id="promotionLinkDiv" class="mb-3">
                    <label for="promotionSelect" class="form-label">연결할 프로모션</label>
                    <select class="form-select" id="promotionSelect" name="promotionId">
                        <option value="">-- 프로모션을 선택하세요 --</option>
                        <c:forEach var="promo" items="${promotionList}">
                            <option value="${promo.promotionId}" ${banner.promotionId == promo.promotionId ? 'selected' : ''}>${promo.title}</option>
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
    // 페이지가 처음 로드될 때, 저장된 '연결 유형'에 맞춰 입력창을 올바르게 보여줍니다.
    document.addEventListener('DOMContentLoaded', function() {
        const linkType = document.querySelector('input[name="linkType"]:checked').value;
        toggleLinkFields(linkType);
    });

    // 라디오 버튼을 클릭할 때마다 입력창을 변경합니다.
    document.querySelectorAll('input[name="linkType"]').forEach(function(radio) {
        radio.addEventListener('change', function() {
            toggleLinkFields(this.value);
        });
    });

    function toggleLinkFields(type) {
        const customUrlInput = document.getElementById('customUrl');
        const promotionSelect = document.getElementById('promotionSelect');
        const customLinkDiv = document.getElementById('customLinkDiv');
        const promotionLinkDiv = document.getElementById('promotionLinkDiv');

        if (type === 'promotion') {
            customLinkDiv.style.display = 'none';
            promotionLinkDiv.style.display = 'block';
            customUrlInput.required = false; 
            promotionSelect.required = true;
        } else {
            customLinkDiv.style.display = 'block';
            promotionLinkDiv.style.display = 'none';
            customUrlInput.required = false; // ? [수정] 필수가 아님
            promotionSelect.required = false;
        }
    }
</script>
