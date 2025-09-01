<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div class="container-fluid">
    <div class="d-sm-flex align-items-center justify-content-between mb-4">
        <h1 class="h3 mb-0 text-gray-800">배너 관리</h1>
        <div>
            <%-- '현재 게시 중' 탭일 때만 '순서 변경 모드' 버튼을 보여줍니다. --%>
            <c:if test="${currentTab == 'active'}">
                <a href="${contextPath}/admin/banners/order" class="btn btn-warning btn-sm">
                    <i class="bi bi-arrow-down-up"></i> 순서 변경 모드
                </a>
            </c:if>
            <a href="${contextPath}/admin/banners/form" class="btn btn-primary btn-sm">
                <i class="bi bi-plus-lg"></i> 새 배너 등록
            </a>
        </div>
    </div>

    <%-- ? --- [신규] 기본 배너 관리 섹션 --- ? --%>
    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">기본 배너 관리</h6>
        </div>
        <div class="card-body">
            <p class="text-muted small">활성화된 프로모션 배너가 없을 때 메인 페이지에 표시될 기본 배너입니다.</p>
            <div class="row align-items-center">
                <div class="col-md-4">
                    <p class="mb-2"><strong>현재 기본 배너:</strong></p>
                    <%-- 
                        - FTP 서버의 /banners/default_banner.png 이미지를 불러옵니다.
                        - 캐시 문제를 방지하기 위해 현재 시간을 쿼리 파라미터로 추가합니다.
                    --%>
                    <img src="${contextPath}/banner-images/default_banner.png?t=${System.currentTimeMillis()}" 
                         alt="기본 배너 미리보기" 
                         class="img-thumbnail"
                         onerror="this.onerror=null; this.src='https://placehold.co/400x100/FDF6EC/7B2D26?text=Default+Banner';">
                </div>
                <div class="col-md-8">
                    <form action="${contextPath}/admin/banners/upload-default" method="post" enctype="multipart/form-data">
                        <div class="mb-3">
                            <label for="defaultImageFile" class="form-label"><strong>새 기본 배너로 교체:</strong></label>
                            <input class="form-control" type="file" id="defaultImageFile" name="defaultImageFile" required>
                            <div class="form-text">권장 사이즈: 1200x400, 최대 2MB, (JPG, PNG, GIF)</div>
                        </div>
                        <button type="submit" class="btn btn-info btn-sm">기본 배너 저장</button>
                    </form>
                </div>
            </div>
        </div>
    </div>



    <%-- ? --- 1. 탭(Tab) UI 구조 --- ? --%>
    <ul class="nav nav-tabs mb-3">
        <li class="nav-item">
            <a class="nav-link ${currentTab == 'active' ? 'active' : ''}" href="${contextPath}/admin/banners?tab=active">현재 게시 중</a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${currentTab == 'scheduled' ? 'active' : ''}" href="${contextPath}/admin/banners?tab=scheduled">게시 예정</a>
        </li>
        <li class="nav-item">
            <a class="nav-link ${currentTab == 'ended' ? 'active' : ''}" href="${contextPath}/admin/banners?tab=ended">게시 종료</a>
        </li>
    </ul>

    <div class="card shadow mb-4">
        <div class="card-body">
            <c:if test="${not empty msg}">
                <div class="alert alert-success">${msg}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
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
                        <%-- ? --- 2. bannerPage.content로 목록을 반복 --- ? --%>
                        <c:choose>
                            <c:when test="${bannerPage.hasContent()}">
                                <c:forEach var="banner" items="${bannerPage.content}">
                                    <tr>
                                        <td class="text-center align-middle">${banner.orderIndex}</td>
                                        <td class="text-center">
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
                                            <form action="${contextPath}/admin/banners/delete/${banner.bannerId}" method="post" style="display: inline;" onsubmit="return confirm('정말로 이 배너를 삭제하시겠습니까?');">
                                                <button type="submit" class="btn btn-danger btn-sm">삭제</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5">해당 상태의 배너가 없습니다.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <%-- ? --- 3. 페이지네이션(Pagination) UI --- ? --%>
            <%-- 배너가 있을 경우에만 페이지네이션을 표시하도록 <c:if>로 감싸줍니다. --%>
            <c:if test="${bannerPage.hasContent()}">
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center">
                        <%-- 이전 페이지 버튼 --%>
                        <li class="page-item ${bannerPage.first ? 'disabled' : ''}">
                            <a class="page-link" href="?tab=${currentTab}&page=${bannerPage.number - 1}">이전</a>
                        </li>

                        <%-- 페이지 번호들 --%>
                        <c:forEach var="i" begin="0" end="${bannerPage.totalPages - 1}">
                            <li class="page-item ${i == bannerPage.number ? 'active' : ''}">
                                <a class="page-link" href="?tab=${currentTab}&page=${i}">${i + 1}</a>
                            </li>
                        </c:forEach>

                        <%-- 다음 페이지 버튼 --%>
                        <li class="page-item ${bannerPage.last ? 'disabled' : ''}">
                            <a class="page-link" href="?tab=${currentTab}&page=${bannerPage.number + 1}">다음</a>
                        </li>
                    </ul>
                </nav>
            </c:if>
        </div>
    </div>
</div>
