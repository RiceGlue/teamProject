<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>${store.storeName} - 예약 관리</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f4; }
        h2 { color: #333; text-align: center; margin-bottom: 25px; }
        .container { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); width: 80%; max-width: 1000px; margin: 20px auto; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: #f2f2f2; }
        .status-pending { color: orange; font-weight: bold; }
        .status-confirmed { color: green; font-weight: bold; }
        .status-cancelled { color: red; font-weight: bold; }
        .action-button { background-color: #007bff; color: white; padding: 6px 10px; border: none; border-radius: 4px; cursor: pointer; font-size: 0.9em; }
        .action-button:hover { background-color: #0056b3; }
        .back-link { display: block; text-align: center; margin-top: 20px; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <h2>${store.storeName} - 예약 관리 (가데이터 화면)</h2>

        <table>
            <thead>
                <tr>
                    <th>예약 ID</th>
                    <th>예약 날짜/시간</th>
                    <th>인원</th>
                    <th>예약자 이름</th>
                    <th>연락처</th>
                    <th>상태</th>
                    <th>요청 사항</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <%-- 가데이터 1 --%>
                <tr>
                    <td>101</td>
                    <td>2025-07-30 18:00</td>
                    <td>2명</td>
                    <td>김철수</td>
                    <td>010-1111-2222</td>
                    <td class="status-pending">대기 중</td>
                    <td>창가 자리 희망</td>
                    <td>
                        <button class="action-button">확인</button>
                        <button class="action-button">취소</button>
                    </td>
                </tr>
                <%-- 가데이터 2 --%>
                <tr>
                    <td>102</td>
                    <td>2025-07-30 19:30</td>
                    <td>4명</td>
                    <td>이영희</td>
                    <td>010-3333-4444</td>
                    <td class="status-confirmed">확인 완료</td>
                    <td>아이 동반</td>
                    <td>
                        <button class="action-button">완료</button>
                        <button class="action-button">취소</button>
                    </td>
                </tr>
                 <%-- 가데이터 3 --%>
                <tr>
                    <td>103</td>
                    <td>2025-07-31 12:00</td>
                    <td>1명</td>
                    <td>박민준</td>
                    <td>010-5555-6666</td>
                    <td class="status-cancelled">취소됨</td>
                    <td>조용한 자리</td>
                    <td>
                        <button class="action-button">재확인</button>
                    </td>
                </tr>
                <%-- 더 많은 가데이터를 추가할 수 있습니다. --%>
            </tbody>
        </table>

        <div class="back-link">
            <p><a href="/">메인 페이지로 돌아가기</a></p> <%-- 메인 페이지 링크 (필요시 수정) --%>
        </div>
    </div>
</body>
</html>