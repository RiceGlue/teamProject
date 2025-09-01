<%-- /WEB-INF/views/admin/commission_rate.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <h1 class="mt-4 mb-4">가맹점 수수료율 관리</h1>

    <c:if test="${not empty msg}">
        <div class="alert alert-success" role="alert">
            ${msg}
        </div>
    </c:if>

    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">현재 수수료율</h6>
        </div>
        <div class="card-body">
            <p style="font-size: 2rem; font-weight: bold;">
                <fmt:formatNumber value="${commissionRate * 100}" pattern="#0.##"/>%
            </p>
            <hr>
            <form action="${pageContext.request.contextPath}/admin/update-commission-rate" method="post">
                <div class="mb-3">
                    <label for="newRate" class="form-label">새로운 수수료율 (%)</label>
                    <input type="number" step="0.01" class="form-control" id="rate" name="rate" placeholder="예: 0.05 (5%)" required>
                </div>
                <button type="submit" class="btn btn-primary">수수료율 변경</button>
            </form>
        </div>
    </div>
</div>