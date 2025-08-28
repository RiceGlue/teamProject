<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<div class="container-fluid">
    <h1 class="h3 mb-4">매장 선택</h1>
    <p class="text-muted">설정을 변경할 매장을 선택해 주세요.</p>

    <div class="row">
        <c:choose>
            <c:when test="${empty stores}">
                <div class="col-12">
                    <div class="card border-0 rounded-3 shadow-sm">
                        <div class="card-body p-4 text-center">
                            <h4 class="card-title mb-3">등록된 매장이 없습니다.</h4>
                            <a href="${contextPath}/owner/store/new" class="btn btn-primary mt-3">새 매장 등록하기</a>
                        </div>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="store" items="${stores}">
                    <div class="col-md-6 mb-4">
                        <div class="card border-0 rounded-3 shadow-sm">
                            <div class="card-body p-4">
                                <h5 class="card-title">${store.storeName}</h5>
                                <p class="card-text text-muted">${store.roadAddress}</p>
                                <a href="${contextPath}/owner/waitings/manage?storeId=${store.storeId}" class="btn btn-info btn-sm">웨이팅 관리</a>
                                <a href="${contextPath}/owner/reservations/manage?storeId=${store.storeId}" class="btn btn-primary btn-sm">예약 관리</a>
                                <a href="${contextPath}/owner/store/layoutEditor?storeId=${store.storeId}" class="btn btn-secondary btn-sm">레이아웃 편집</a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</div>