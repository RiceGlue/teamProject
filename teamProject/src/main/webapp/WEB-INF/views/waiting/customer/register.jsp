<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>웨이팅 등록</title>
</head>
<body>
    <h2>웨이팅 등록</h2>
    <form action="/waiting/customer/register" method="post">
        <label>회원 ID:</label>
        <input type="number" name="memberId" required /><br/>

        <label>매장 ID:</label>
        <input type="number" name="storeId" required /><br/>

        <label>인원 수:</label>
        <input type="number" name="guestCount" required /><br/>

        <button type="submit">등록</button>
    </form>
</body>
</html>
