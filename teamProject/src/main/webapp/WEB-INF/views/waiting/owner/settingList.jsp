<%-- src/main/webapp/WEB-INF/views/waiting/owner/settingList.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>${store.storeName} - 웨이팅 설정 목록</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f4; }
        .container { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); width: 80%; max-width: 1000px; margin: 20px auto; }
        h2 { color: #333; text-align: center; margin-bottom: 25px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: #f2f2f2; }
        .active-status { font-weight: bold; }
        .active-true { color: green; }
        .active-false { color: red; }
        .button-group { margin-top: 20px; text-align: right; }
        .action-button, .add-button { background-color: #007bff; color: white; padding: 8px 12px; border: none; border-radius: 4px; cursor: pointer; font-size: 0.9em; text-decoration: none; display: inline-block; margin-left: 5px;}
        .add-button { background-color: #28a745; }
        .action-button:hover { background-color: #0056b3; }
        .add-button:hover { background-color: #218838; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <h2>${store.storeName} - 웨이팅 설정 목록</h2>

        <div class="button-group">
            <a href="<c:url value='/waiting/owner/settings/addForm?storeId=${storeId}'/>" class="add-button">새 설정 추가</a>
        </div>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>요일</th>
                    <%-- <th>시간대</th> --%> <th>최대 팀 수</th>
                    <th>활성화</th>
                    <th>생성일</th>
                    <th>수정일</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty settings}">
                        <c:forEach var="setting" items="${settings}">
                            <tr>
                                <td>${setting.settingId}</td>
                                <td>${setting.dayOfWeek}</td>
                                <%-- <td>${setting.timeSlot}</td> --%> <td>${setting.maxTeams}</td>
                                <td class="active-status ${setting.active ? 'active-true' : 'active-false'}">
                                    ${setting.active ? '활성' : '비활성'}
                                </td>
                                <td>${setting.createdAt}</td>
                                <td>${setting.updatedAt}</td>
                                <td>
                                    <a href="<c:url value='/waiting/owner/settings/editForm/${setting.settingId}?storeId=${storeId}'/>" class="action-button">수정</a>
                                    <a href="<c:url value='/waiting/owner/settings/delete/${setting.settingId}?storeId=${storeId}'/>" class="action-button" onclick="return confirm('이 설정을 삭제하시겠습니까?');">삭제</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="6" style="text-align: center;">등록된 웨이팅 설정이 없습니다. (colspan 7 -> 6으로 변경)</td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>

        <p><a href="<c:url value='/store/storeDetail.do?storeId=${storeId}'/>">매장 상세 보기로 돌아가기</a></p>
    </div>
</body>
</html>