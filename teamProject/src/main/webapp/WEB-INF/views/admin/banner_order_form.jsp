<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- 드래그 앤 드롭 기능을 위한 SortableJS 라이브러리 로드 --%>
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js"></script>

<style>
    .sortable-list {
        list-style-type: none;
        padding: 0;
    }
    .sortable-item {
        padding: 1rem;
        margin-bottom: 0.5rem;
        background-color: #fff;
        border: 1px solid #ddd;
        border-radius: 0.25rem;
        cursor: grab;
        display: flex;
        align-items: center;
    }
    .sortable-item:active {
        cursor: grabbing;
    }
    .sortable-item .handle {
        font-size: 1.5rem;
        margin-right: 1rem;
        color: #aaa;
    }
    .sortable-item img {
        max-width: 120px;
        height: auto;
        margin-right: 1rem;
    }
    .sortable-ghost {
        opacity: 0.4;
        background-color: #c8ebfb;
    }
</style>

<div class="container-fluid">
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">배너 순서 변경</h1>
        <div>
            <a href="${contextPath}/admin/banners" class="btn btn-secondary btn-sm">취소</a>
            <button id="saveOrderBtn" class="btn btn-success btn-sm">순서 저장</button>
        </div>
    </div>

    <div class="card shadow mb-4">
        <div class="card-body">
            <p class="text-muted">배너를 드래그하여 순서를 변경한 후, '순서 저장' 버튼을 눌러주세요.</p>
            <div id="bannerOrderList" class="sortable-list">
                <c:forEach var="banner" items="${bannerList}">
                    <div class="sortable-item" data-id="${banner.bannerId}">
                        <span class="handle">☰</span>
                        <img src="${contextPath}/banner-images/${banner.imagePath}" alt="${banner.text}">
                        <span>${banner.text} (ID: ${banner.bannerId})</span>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const list = document.getElementById('bannerOrderList');
        const saveBtn = document.getElementById('saveOrderBtn');

        // SortableJS 초기화
        const sortable = new Sortable(list, {
            animation: 150,
            ghostClass: 'sortable-ghost'
        });

        // '순서 저장' 버튼 클릭 이벤트
        saveBtn.addEventListener('click', function() {
            // 현재 순서대로 배너 ID 목록을 가져옵니다.
            const bannerIds = Array.from(list.children).map(item => item.dataset.id);

            // AJAX를 사용하여 서버에 새로운 순서를 전송합니다.
            fetch('${contextPath}/admin/banners/update-order', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(bannerIds),
            })
            .then(response => response.text())
            .then(data => {
                if (data === 'success') {
                    alert('배너 순서가 성공적으로 저장되었습니다.');
                    window.location.href = '${contextPath}/admin/banners';
                } else {
                    alert('순서 저장 중 오류가 발생했습니다.');
                }
            })
            .catch((error) => {
                console.error('Error:', error);
                alert('순서 저장 중 오류가 발생했습니다.');
            });
        });
    });
</script>
