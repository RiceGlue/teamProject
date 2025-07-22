<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
    <title>웨이팅 슬롯 목록</title>
    <link rel="stylesheet" href="/resources/css/bootstrap.min.css"/>
</head>
<body>
    <div class="container mt-5">
        <h2>웨이팅 슬롯 관리</h2>

        <!-- 슬롯 등록 폼 -->
        <form action="${pageContext.request.contextPath}/admin/waiting/add" method="post" class="mb-4">
            <input type="hidden" name="storeId" value="${param.storeId}" />

            <div class="row g-2">
                <div class="col-md-2">
                    <label>요일</label>
                    <select name="dayOfWeek" class="form-control">
                        <c:forEach var="i" begin="1" end="7">
                            <option value="${i}">${i}요일</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="col-md-3">
                    <label>시간 (HH:mm:ss)</label>
                    <input type="time" name="timeSlot" class="form-control" required />
                </div>

                <div class="col-md-2">
                    <label>최대 팀 수</label>
                    <input type="number" name="maxTeams" class="form-control" required />
                </div>

                <div class="col-md-2">
                    <label>활성화</label><br/>
                    <input type="checkbox" name="isActive" value="true" checked />
                </div>

                <div class="col-md-3 align-self-end">
                    <button type="submit" class="btn btn-primary w-100">등록</button>
                </div>
            </div>
        </form>

        <!-- 슬롯 목록 테이블 -->
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>요일</th>
                    <th>시간</th>
                    <th>최대 팀</th>
                    <th>활성화</th>
                    <th>삭제</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="slot" items="${slots}">
                    <tr>
                        <td>${slot.dayOfWeek}</td>
                        <td>${slot.timeSlot}</td>
                        <td>${slot.maxTeams}</td>
                        <td>
                            <c:choose>
                                <c:when test="${slot.active}">✅</c:when>
                                <c:otherwise>❌</c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <form method="post" action="${pageContext.request.contextPath}/admin/waiting/delete/${slot.waitingId}">
                                <input type="hidden" name="storeId" value="${slot.storeId}" />
                                <button type="submit" class="btn btn-danger btn-sm">삭제</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</body>
</html>
