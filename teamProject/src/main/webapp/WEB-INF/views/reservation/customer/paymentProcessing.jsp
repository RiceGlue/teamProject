<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>결제 처리 중</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        .container { text-align: center; margin-top: 100px; }
    </style>
    <meta http-equiv="refresh" content="5; url=/reservation/customer/bookingConfirm?storeId=1"> </head>
<body>
<div class="container">
    <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
    </div>
    <h3 class="mt-3">결제 처리 중입니다...</h3>
    <p class="text-muted">잠시만 기다려주세요. 예약이 확정되는 대로 알림을 보내드립니다.</p>
    <p class="text-muted">결제 ID: ${paymentId}</p>
    <p>
        <a href="/reservation/customer/bookingConfirm?storeId=1">예약 내역 확인하기</a> </p>
</div>
</body>
</html>