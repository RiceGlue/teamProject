<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>웨이팅 설정 추가</title>
</head>
<body>
    <h2>웨이팅 설정 추가</h2>
    <form action="/waiting/owner/settings/add" method="post">
        <label>매장 ID:</label>
        <input type="number" name="storeId" required /><br/>

        <label>요일 (0~6):</label>
        <input type="number" name="dayOfWeek" required /><br/>

        <label>시간 (HH:mm):</label>
        <input type="time" name="timeSlot" required /><br/>

        <label>최대 팀 수:</label>
        <input type="number" name="maxTeams" required /><br/>

        <label>활성화:</label>
        <input type="checkbox" name="active" value="true" /><br/>

        <button type="submit">등록</button>
    </form>
</body>
</html>
