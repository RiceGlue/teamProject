<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>웨이팅 등록 성공</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700&display=swap');

        .waiting-success-container {
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f7f9fc;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 50px 0;
            margin: 0;
            color: #333;
        }

        .waiting-success-card {
            background-color: #ffffff;
            padding: 40px 60px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            text-align: center;
            max-width: 450px;
            width: 90%;
            border-top: 5px solid #4CAF50;
        }

        .waiting-success-card h1 {
            color: #4CAF50;
            font-size: 2.2em;
            margin-bottom: 20px;
            font-weight: 700;
        }

        .waiting-success-card p {
            font-size: 1.1em;
            color: #555;
            line-height: 1.6;
            margin: 10px 0;
            display: flex;
            justify-content: space-between;
            padding: 5px 0;
            border-bottom: 1px solid #eee;
        }

        .waiting-success-card p:last-of-type {
            border-bottom: none;
        }

        .waiting-success-card .label {
            font-weight: 700;
            color: #444;
        }

        .waiting-success-card a {
            display: inline-block;
            margin-top: 30px;
            padding: 12px 25px;
            background-color: #4CAF50;
            color: #fff;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 700;
            transition: background-color 0.3s ease, transform 0.2s ease;
        }

        .waiting-success-card a:hover {
            background-color: #45a049;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="waiting-success-container">
        <div class="waiting-success-card">
            <h1>웨이팅 등록이 성공적으로 완료되었습니다!</h1>
            <p><span class="label">회원 ID:</span> <span>${waiting.memberId}</span></p>
            <p><span class="label">매장 ID:</span> <span>${waiting.storeId}</span></p>
            <p><span class="label">인원 수:</span> <span>${waiting.guestCount} 명</span></p>
            <p><span class="label">웨이팅 상태:</span> <span>${waiting.status}</span></p>
            <p><span class="label">FCM 토큰:</span> <span>${waiting.fcmToken}</span></p>
            <a href="/">메인으로 돌아가기</a>
        </div>
    </div>
</body>
</html>
