<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 기존 <%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %> 는 주석 처리하거나 제거하세요. --%>
<html>
<head>
    <title>예약하기 - ${store.storeName}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f4; }
        h2 { color: #333; }
        form { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); width: 400px; margin: 20px auto; }
        label { display: block; margin-bottom: 8px; font-weight: bold; }
        input[type="date"],
        input[type="time"],
        input[type="number"],
        input[type="text"],
        textarea { width: calc(100% - 22px); padding: 10px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 4px; }
        button { background-color: #007bff; color: white; padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background-color: #0056b3; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h2>${store.storeName} 예약하기 (가데이터 화면)</h2>

    <%-- Spring form 태그 대신 일반 HTML form 태그 사용 --%>
    <form action="/reservation/customer/book" method="post">
        <input type="hidden" name="storeId" value="${storeId}" />
        <input type="hidden" name="memberId" value="1" /> <%-- 예시 멤버 ID --%>

        <label for="reservationDate">날짜:</label>
        <input type="date" id="reservationDate" name="reservationDate" required="true" value="2025-07-29" /><br/> <%-- 가데이터 --%>

        <label for="reservationTime">시간:</label>
        <input type="time" id="reservationTime" name="reservationTime" required="true" value="14:30" /><br/> <%-- 가데이터 --%>

        <label for="guestCount">인원 수:</label>
        <input type="number" id="guestCount" name="guestCount" min="1" required="true" value="2" /><br/> <%-- 가데이터 --%>

        <label for="customerName">예약자 이름:</label>
        <input type="text" id="customerName" name="customerName" required="true" value="홍길동" /><br/> <%-- 가데이터 --%>

        <label for="customerPhoneNumber">예약자 연락처:</label>
        <input type="text" id="customerPhoneNumber" name="customerPhoneNumber" placeholder="010-1234-5678" required="true" value="010-1234-5678" /><br/> <%-- 가데이터 --%>

        <label for="request">요청 사항 (선택 사항):</label>
        <textarea id="request" name="request" rows="3" cols="30">창가 자리로 부탁드립니다.</textarea><br/> <%-- 가데이터 --%>

        <button type="submit">예약 신청 (화면 이동만)</button>
    </form>

    <p><a href="/store/detail?storeId=${store.storeId}">매장 상세 보기로 돌아가기</a></p>
</body>
</html>