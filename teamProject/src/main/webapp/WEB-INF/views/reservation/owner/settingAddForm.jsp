<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>웨이팅 설정 추가</title>
</head>
<body>
    <h2>웨이팅 설정 추가</h2>
    <form action="/waiting/owner/settings/add" method="post">
        <input type="hidden" name="storeId" value="${storeId}" />

        <label>요일 (0:일요일 ~ 6:토요일):</label>
        <input type="number" name="dayOfWeek" min="0" max="6" required /><br/>

        <label>시간 (HH:mm):</label>
        <input type="time" name="timeSlot" required /><br/>

        <label>최대 팀 수:</label>
        <input type="number" name="maxTeams" min="1" required /><br/>

        <label>활성화:</label>
        <input type="hidden" name="active" value="false"/>
        <input type="checkbox" name="active" value="true" checked/><br/>

        <button type="submit">등록</button>
    </form>
    <p><a href="/waiting/owner/settings?storeId=${storeId}">목록으로 돌아가기</a></p>
</body>
</html>