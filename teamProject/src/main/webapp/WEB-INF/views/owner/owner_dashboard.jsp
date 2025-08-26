<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid">
    <h1 class="h3 mb-4">대시보드 홈</h1>

    <div class="row">
        <c:choose>
            <c:when test="${empty stores}">
                <div class="col-12">
                    <div class="card border-0 rounded-3 shadow-sm">
                        <div class="card-body p-4 text-center">
                            <h4 class="card-title mb-3">등록된 매장이 없습니다.</h4>
                            <p class="text-muted">지금 바로 새로운 매장을 등록하고 관리하세요!</p>
                            <a href="/owner/store/new" class="btn btn-primary mt-3">
                                <i class="bi bi-plus-circle me-2"></i>새 매장 등록하기
                            </a>
                        </div>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="store" items="${stores}">
                    <div class="col-lg-6 mb-4">
                        <div class="card border-0 rounded-3 shadow-sm">
                            <div class="card-body p-4">
                                <h4 class="card-title mb-4">${store.storeName} (${store.address})</h4>
                                <div class="row g-3 text-center">
                                    <div class="col-4">
                                        <a href="/owner/reservations/manage?storeId=${store.storeId}" class="d-block p-3 rounded-3 text-decoration-none bg-light">
                                            <div class="fs-2 fw-bold text-primary">${reservationCounts[store.storeId]}</div>
                                            <div class="small text-muted">오늘의 예약</div>
                                        </a>
                                    </div>
                                    <div class="col-4">
                                        <a href="/owner/waitings/manage?storeId=${store.storeId}" class="d-block p-3 rounded-3 text-decoration-none bg-light">
                                            <div class="fs-2 fw-bold text-danger">${waitingCounts[store.storeId]}</div>
                                            <div class="small text-muted">실시간 웨이팅</div>
                                        </a>
                                    </div>
                                    <div class="col-4">
                                        <a href="#" class="d-block p-3 rounded-3 text-decoration-none bg-light">
                                            <div class="fs-2 fw-bold text-success">0</div>
                                            <div class="small text-muted">새 리뷰</div>
                                        </a>
                                    </div>
                                </div>
                                <hr class="my-4">
                                <a href="#" class="btn btn-outline-secondary w-100">
                                    매장 관리 바로가기 <i class="bi bi-arrow-right-short"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</div>