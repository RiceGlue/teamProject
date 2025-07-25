<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>웨이팅 등록 성공</title>
</head>
<body>
    <h1>웨이팅 등록이 성공적으로 완료되었습니다!</h1>
    <p>회원 ID: ${waiting.memberId}</p>  <%-- Model에 "waiting"으로 담았으니 이렇게 접근해야 합니다. --%>
    <p>매장 ID: ${waiting.storeId}</p>
    <p>인원 수: ${waiting.guestCount}</p>
    <p>웨이팅 상태: ${waiting.status}</p>
    <p>FCM 토큰: ${waiting.fcmToken}</p>
    <p><a href="/">메인으로 돌아가기</a></p>
</body>
</html>