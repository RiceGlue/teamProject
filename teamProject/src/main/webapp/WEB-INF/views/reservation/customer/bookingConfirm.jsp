<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>예약 확인</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f4; text-align: center; }
        .container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); width: 500px; margin: 50px auto; }
        h2 { color: #28a745; }
        p { font-size: 1.1em; margin-bottom: 20px; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <h2>${store.storeName} 예약 완료!</h2>
        <p>${message}</p>
        <p>예약해주셔서 감사합니다. 빠른 시일 내에 매장에서 확인 연락을 드릴 예정입니다.</p>
        <p><a href="/store/storeDetail.do?storeId=${storeId}">매장 상세 보기로 돌아가기</a></p>
    </div>
</body>
</html>