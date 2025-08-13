<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <h1 class="h3 mb-2 text-gray-800">일반 회원 관리</h1>
    <p class="mb-4">일반 회원의 정보를 조회, 수정, 관리할 수 있습니다.</p>

    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">일반 회원 목록</h6>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                    <thead>
                        <tr>
                            <th>아이디/소셜</th>
                            <th>이름</th>
                            <th>이메일</th>
                            <th>연락처</th>
                            <th>가입일</th>
                            <th>상태</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty userList}">
                                <c:forEach var="user" items="${userList}">
                                    <tr>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty user.loginId}">${user.loginId}</c:when>
                                                <c:otherwise>
                                                    <c:forEach var="social" items="${user.socialAccounts}" varStatus="status">
                                                        ${social.provider}<c:if test="${not status.last}">, </c:if>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${user.memberName}</td>
                                        <td>${user.email}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${user.countryCode == '82' and not fn:startsWith(user.phone, '0')}">
                                                    0${user.phone}
                                                </c:when>
                                                <c:otherwise>
                                                    ${user.phone}
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><fmt:formatDate value="${user.createdAt}" pattern="yyyy-MM-dd"/></td>
                                        <td>
                                            <c:if test="${user.status == 'ACTIVE'}"><span class="badge bg-success">활성</span></c:if>
                                            <c:if test="${user.status == 'DEACTIVATED'}"><span class="badge bg-secondary">비활성</span></c:if>
                                        </td>
                                        <td>
                                            <a href="${contextPath}/admin/users/${user.memberId}/edit" class="btn btn-info btn-sm">수정</a>
                                            <form action="${contextPath}/admin/users/${user.memberId}/deactivate" method="post" style="display:inline;" onsubmit="return confirm('정말로 이 회원을 비활성화하시겠습니까?');">
                                                <button type="submit" class="btn btn-danger btn-sm">비활성화</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center">등록된 일반 회원이 없습니다.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
