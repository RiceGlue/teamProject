<%-- /WEB-INF/views/admin/owner_settlement_history.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="ko_KR"/>
<div class="container-fluid">
    <h1 class="mt-4 mb-4">점주 ID ${ownerId} 정산 내역</h1>
    <form action="${pageContext.request.contextPath}/admin/settlement-history" method="get" class="mb-4 d-flex align-items-center">
        <input type="hidden" name="ownerId" value="${ownerId}">
        <div class="me-2">
            <label for="startDate" class="form-label">시작일:</label>
            <input type="date" class="form-control" id="startDate" name="startDate" value="${startDate}">
        </div>
        <div class="me-2">
            <label for="endDate" class="form-label">종료일:</label>
            <input type="date" class="form-control" id="endDate" name="endDate" value="${endDate}">
        </div>
        <button type="submit" class="btn btn-primary mt-4 me-2">조회</button>
        <a href="${pageContext.request.contextPath}/admin/owners" class="btn btn-secondary mt-4">목록으로</a>
    </form>

    <c:if test="${empty settlementList}">
        <p>조회된 정산 내역이 없습니다.</p>
    </c:if>
    <c:if test="${not empty settlementList}">
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>정산 ID</th>
                    <th>매장 ID</th>
                    <th>정산 기간</th>
                    <th>총매출액</th>
                    <th>수수료</th>
                    <th>최종 정산액</th>
                    <th>상태</th>
                    <th>정산일</th>
                    <th>승인</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="settlement" items="${settlementList}">
                    <tr>
                        <td>${settlement.settlementId}</td>
                        <td>${settlement.storeId}</td>
                        <td>
                            <fmt:formatDate value="${settlement.settlementPeriodStart}" pattern="yyyy년 MM월 dd일"/> ~ <fmt:formatDate value="${settlement.settlementPeriodEnd}" pattern="yyyy년 MM월 dd일"/>
                        </td>
                        <td><fmt:formatNumber value="${settlement.totalRevenueAmount}" type="number" pattern="#,##0"/></td>
                        <td><fmt:formatNumber value="${settlement.totalCommissionAmount}" type="number" pattern="#,##0.00"/></td>
                        <td><fmt:formatNumber value="${settlement.finalSettlementAmount}" type="number" pattern="#,##0.00"/></td>
                        <td>${settlement.status}</td>
                        <td>
                            <c:if test="${settlement.settledAt != null}">
                                <fmt:formatDate value="${settlement.settledAt}" pattern="yyyy-MM-dd HH:mm"/>
                            </c:if>
                            <c:if test="${settlement.settledAt == null}">
                                -
                            </c:if>
                        </td>
                        <td>
                            <c:if test="${settlement.status == 'PENDING'}">
                                <a href="${pageContext.request.contextPath}/admin/approve-settlement?settlementId=${settlement.settlementId}&ownerId=${ownerId}" class="btn btn-primary btn-sm">승인</a>
                            </c:if>
                            <c:if test="${settlement.status == 'COMPLETED'}">
                                <button class="btn btn-success btn-sm" disabled>완료됨</button>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </c:if>
</div>