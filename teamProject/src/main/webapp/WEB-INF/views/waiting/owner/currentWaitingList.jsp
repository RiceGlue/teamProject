<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid">
    <h1 class="h3 mb-4">실시간 웨이팅 현황</h1>

    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">웨이팅 목록 (매장 ID: ${storeId})</h6>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered" id="waitingTable" width="100%" cellspacing="0">
                    <thead>
                        <tr>
                            <th>순번</th>
                            <th>웨이팅 번호</th>
                            <th>인원 수</th>
                            <th>상태</th>
                            <th>대기 시간</th>
                            <th>등록 시각</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty waitings}">
                                <tr>
                                    <td colspan="7" class="text-center">현재 대기 중인 웨이팅이 없습니다.</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="waiting" items="${waitings}" varStatus="status">
                                    <tr>
                                        <td>${status.index + 1}</td>
                                        <td>${waiting.waitingNumber}</td>
                                        <td>${waiting.numberOfPeople}명</td>
                                        <td>
                                            <span class="badge
                                                <c:if test="${waiting.status == 'WAITING'}">bg-warning text-dark</c:if>
                                                <c:if test="${waiting.status == 'CALLED'}">bg-info</c:if>
                                                <c:if test="${waiting.status == 'SEATED'}">bg-success</c:if>
                                                <c:if test="${waiting.status == 'NO_SHOW'}">bg-danger</c:if>
                                                <c:if test="${waiting.status == 'CANCELLED'}">bg-secondary</c:if>
                                                ">
                                                ${waiting.status}
                                            </span>
                                        </td>
                                        <td>
                                            계산 필요
                                        </td>
                                        <td>${waiting.createdAt}</td>
                                        <td>
                                            <button class="btn btn-sm btn-success update-status-btn" data-waiting-id="${waiting.waitingId}" data-status="SEATED">착석</button>
                                            <button class="btn btn-sm btn-info update-status-btn" data-waiting-id="${waiting.waitingId}" data-status="CALLED">호출</button>
                                            <button class="btn btn-sm btn-danger update-status-btn" data-waiting-id="${waiting.waitingId}" data-status="NO_SHOW">노쇼</button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    $('.update-status-btn').on('click', function() {
        var waitingId = $(this).data('waiting-id');
        var newStatus = $(this).data('status');
        var storeId = ${storeId}; // 컨트롤러에서 받은 storeId 사용

        $.ajax({
            url: '/owner/waitings/updateStatus', // 컨트롤러의 API URL
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                waitingId: waitingId,
                status: newStatus,
                storeId: storeId
            }),
            success: function(response) {
                alert('웨이팅 상태가 업데이트되었습니다.');
                location.reload(); // 페이지 새로고침
            },
            error: function(xhr, status, error) {
                alert('상태 업데이트 실패: ' + xhr.responseJSON.error);
            }
        });
    });
});
</script>