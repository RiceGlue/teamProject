<%-- /WEB-INF/views/admin/owner_list.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <h1 class="h3 mb-2 text-gray-800">가맹점 회원 관리</h1>
    <p class="mb-4">가맹점 회원의 정보를 관리하고 신규 계정을 생성할 수 있습니다.</p>

    <div class="card shadow mb-4">
        <div class="card-header py-3 d-flex justify-content-between align-items-center">
            <h6 class="m-0 font-weight-bold text-primary">가맹점 회원 목록</h6>
            <a href="${contextPath}/admin/owners/new" class="btn btn-primary btn-sm">
                신규 가맹점주 등록
            </a>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                    <thead>
                        <tr>
                            <th>아이디</th>
                            <th>대표자명</th>
                            <th>이메일</th>
                            <th>연락처</th>
                            <th>가입일</th>
                            <th>상태</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty ownerList}">
                                <c:forEach var="owner" items="${ownerList}">
                                    <tr>
                                        <td>${owner.loginId}</td>
                                        <td>${owner.memberName}</td>
                                        <td>${owner.email}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${owner.countryCode == '82' and not fn:startsWith(owner.phone, '0')}">
                                                    0${owner.phone}
                                                </c:when>
                                                <c:otherwise>
                                                    ${owner.phone}
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><fmt:formatDate value="${owner.createdAt}" pattern="yyyy-MM-dd"/></td>
                                        <td>
                                            <c:if test="${owner.status == 'ACTIVE'}"><span class="badge bg-success">활성</span></c:if>
                                            <c:if test="${owner.status == 'DEACTIVATED'}"><span class="badge bg-secondary">비활성</span></c:if>
                                        </td>
                                        <td>
                                            <a href="#" class="btn btn-info btn-sm">수정</a>
                                            <a href="#" class="btn btn-danger btn-sm">비활성화</a>
                                            <a href="${pageContext.request.contextPath}/admin/settlement-history?ownerId=${owner.memberId}" class="btn btn-primary btn-sm">정산 관리</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center">등록된 가맹점주가 없습니다.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>