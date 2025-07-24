<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>웨이팅 설정 목록</title>
</head>
<body>
    <h2>웨이팅 설정 목록</h2>
    <a href="/waiting/owner/settings/add">+ 새 설정 추가</a>
    <table border="1">
        <tr>
            <th>요일</th>
            <th>시간</th>
            <th>최대 팀 수</th>
            <th>활성화 여부</th>
        </tr>
        <c:forEach var="setting" items="${settings}">
            <tr>
                <td>${setting.dayOfWeek}</td>
                <td>${setting.timeSlot}</td>
                <td>${setting.maxTeams}</td>
                <td>${setting.active}</td>
            </tr>
        </c:forEach>
    </table>
</body>
</html>
