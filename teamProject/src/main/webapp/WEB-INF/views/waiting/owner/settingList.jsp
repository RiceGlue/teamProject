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
                <!--<td>${setting.dayOfWeek}</td>-->
				<!-- 요일 숫자를 한글로 변환 -->
                <td>
                    <c:choose>
                        <c:when test="${setting.dayOfWeek == 0}">일요일</c:when>
                        <c:when test="${setting.dayOfWeek == 1}">월요일</c:when>
                        <c:when test="${setting.dayOfWeek == 2}">화요일</c:when>
                        <c:when test="${setting.dayOfWeek == 3}">수요일</c:when>
                        <c:when test="${setting.dayOfWeek == 4}">목요일</c:when>
                        <c:when test="${setting.dayOfWeek == 5}">금요일</c:when>
                        <c:when test="${setting.dayOfWeek == 6}">토요일</c:when>
                        <c:otherwise>알수없음</c:otherwise>
                    </c:choose>
                </td>
                <td>${setting.timeSlot}</td>
                <td>${setting.maxTeams}</td>
                <!--<td>${setting.active}</td>-->
				<!-- true/false를 텍스트로 -->
                <td>
                    <c:choose>
                        <c:when test="${setting.active}">사용</c:when>
                        <c:otherwise>중지</c:otherwise>
                    </c:choose>
                </td>
            </tr>
        </c:forEach>
    </table>
</body>
</html>
