<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid">
    <h1 class="h3 mb-4">대시보드 홈</h1>
    
    <div class="row">
        <%-- TODO: 나중에 컨트롤러에서 넘겨준 매장 목록(storeList)을 c:forEach로 반복해서 카드를 생성해야 합니다. --%>
        
        <!-- A 매장 카드 (예시) -->
        <div class="col-lg-6 mb-4">
            <div class="card border-0 rounded-3 shadow-sm">
                <div class="card-body p-4">
                    <h4 class="card-title mb-4">A 매장 (강남점)</h4>
                    <div class="row g-3 text-center">
                        <div class="col-4">
                            <a href="#" class="d-block p-3 rounded-3 text-decoration-none bg-light">
                                <div class="fs-2 fw-bold text-primary">5</div>
                                <div class="small text-muted">오늘의 예약</div>
                            </a>
                        </div>
                        <div class="col-4">
                            <a href="#" class="d-block p-3 rounded-3 text-decoration-none bg-light">
                                <div class="fs-2 fw-bold text-danger">3</div>
                                <div class="small text-muted">실시간 웨이팅</div>
                            </a>
                        </div>
                        <div class="col-4">
                            <a href="#" class="d-block p-3 rounded-3 text-decoration-none bg-light">
                                <div class="fs-2 fw-bold text-success">1</div>
                                <div class="small text-muted">새 리뷰</div>
                            </a>
                        </div>
                    </div>
                    <hr class="my-4">
                    <a href="#" class="btn btn-outline-secondary w-100">매장 관리 바로가기 <i class="bi bi-arrow-right-short"></i></a>
                </div>
            </div>
        </div>

        <!-- B 매장 카드 (예시) -->
        <div class="col-lg-6 mb-4">
            <div class="card border-0 rounded-3 shadow-sm">
                <div class="card-body p-4">
                    <h4 class="card-title mb-4">B 매장 (판교점)</h4>
                     <div class="row g-3 text-center">
                        <div class="col-4">
                            <a href="#" class="d-block p-3 rounded-3 text-decoration-none bg-light">
                                <div class="fs-2 fw-bold text-primary">2</div>
                                <div class="small text-muted">오늘의 예약</div>
                            </a>
                        </div>
                        <div class="col-4">
                            <a href="#" class="d-block p-3 rounded-3 text-decoration-none bg-light">
                                <div class="fs-2 fw-bold text-secondary">0</div>
                                <div class="small text-muted">실시간 웨이팅</div>
                            </a>
                        </div>
                        <div class="col-4">
                            <a href="#" class="d-block p-3 rounded-3 text-decoration-none bg-light">
                                <div class="fs-2 fw-bold text-secondary">0</div>
                                <div class="small text-muted">새 리뷰</div>
                            </a>
                        </div>
                    </div>
                    <hr class="my-4">
                    <a href="#" class="btn btn-outline-secondary w-100">매장 관리 바로가기 <i class="bi bi-arrow-right-short"></i></a>
                </div>
            </div>
        </div>
    </div>
</div>
