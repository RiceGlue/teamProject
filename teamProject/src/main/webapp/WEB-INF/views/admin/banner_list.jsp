<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div class="container-fluid">
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">배너 관리</h1>
        <a href="${contextPath}/admin/banners/form" class="btn btn-primary btn-sm">
            <i class="bi bi-plus-lg"></i> 새 배너 등록
        </a>
    </div>

    <div class="card shadow mb-4">
        <div class="card-body">
            <c:if test="${not empty msg}">
                <div class="alert alert-success">${msg}</div>
            </c:if>
            <div class="table-responsive">
                <table class="table table-bordered" width="100%" cellspacing="0">
                    <thead>
                        <tr class="text-center">
                            <th>순서</th>
                            <th>이미지 미리보기</th>
                            <th>텍스트</th>
                            <th>게시 기간</th>
                            <th>연결 유형</th>
                            <th>상태</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty bannerList}">
                                <c:forEach var="banner" items="${bannerList}">
                                    <tr>
                                        <td class="text-center align-middle">${banner.orderIndex}</td>
                                        <td class="text-center">
                                            <%-- ? --- 여기가 핵심 수정 부분입니다 --- ? --%>
                                            <img src="${contextPath}/banner-images/${banner.imagePath}" alt="${banner.text}" style="max-width: 150px; height: auto;">
                                        </td>
                                        <td class="align-middle">${banner.text}</td>
                                        <td class="align-middle">
                                            ${banner.startAt} ~ ${banner.endAt}
                                        </td>
                                        <td class="align-middle">
                                            <c:choose>
                                                <c:when test="${not empty banner.promotionId}">
                                                    프로모션 (ID: ${banner.promotionId})
                                                </c:when>
                                                <c:otherwise>
                                                    커스텀 링크
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center align-middle">
                                            <c:if test="${banner.status == 'active'}"><span class="badge bg-success">활성</span></c:if>
                                            <c:if test="${banner.status != 'active'}"><span class="badge bg-secondary">비활성</span></c:if>
                                        </td>
                                        <td class="text-center align-middle">
                                            <a href="${contextPath}/admin/banners/form/${banner.bannerId}" class="btn btn-info btn-sm">수정</a>
                                            <%-- ✨ --- 여기가 핵심 수정 부분입니다 --- ✨ --%>
                                            <form action="${contextPath}/admin/banners/delete/${banner.bannerId}" method="post" style="display: inline;" onsubmit="return confirm('정말로 이 배너를 삭제하시겠습니까?');">
                                                <button type="submit" class="btn btn-danger btn-sm">삭제</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5">등록된 배너가 없습니다.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
