<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid">
    <h1 class="h3 mb-4 text-gray-800">관리자 대시보드</h1>

    <div class="row">
        <!-- 일반 회원 관리 카드 -->
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-primary shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                일반 회원 관리</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">사용자 계정 조회</div>
                        </div>
                        <div class="col-auto">
                            <i class="bi bi-people-fill fs-2 text-gray-300"></i>
                        </div>
                    </div>
                    <a href="${contextPath}/admin/users" class="stretched-link"></a>
                </div>
            </div>
        </div>

        <!-- 가맹점주 관리 카드 -->
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-success shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                가맹점주 관리</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">계정 생성 및 관리</div>
                        </div>
                        <div class="col-auto">
                            <i class="bi bi-person-badge fs-2 text-gray-300"></i>
                        </div>
                    </div>
                     <a href="${contextPath}/admin/owners" class="stretched-link"></a>
                </div>
            </div>
        </div>

        <!-- 가맹점 관리 카드 -->
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-info shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-info text-uppercase mb-1">
                                가맹점 관리</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">매장 정보 관리</div>
                        </div>
                        <div class="col-auto">
                            <i class="bi bi-shop fs-2 text-gray-300"></i>
                        </div>
                    </div>
                    <a href="#" class="stretched-link"></a>
                </div>
            </div>
        </div>

        <!-- 게시판 관리 카드 -->
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-warning shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                게시판 관리</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">문의 및 리뷰 확인</div>
                        </div>
                        <div class="col-auto">
                            <i class="bi bi-clipboard-data-fill fs-2 text-gray-300"></i>
                        </div>
                    </div>
                    <a href="#" class="stretched-link"></a>
                </div>
            </div>
        </div>
    </div>
</div>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

