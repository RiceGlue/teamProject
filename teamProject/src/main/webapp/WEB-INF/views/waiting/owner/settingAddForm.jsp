<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %> <%-- 이 줄 추가 --%>
<html>
<head>
    <title>웨이팅 설정 추가</title>
</head>
<body>
    <h2>웨이팅 설정 추가</h2>
    <%-- modelAttribute를 명시하여 form 태그 시작 --%>
    <form:form modelAttribute="waitingSettingVO" action="/waiting/owner/settings/add" method="post">
        <%-- hidden 필드는 form:hidden 사용 --%>
        <form:hidden path="storeId" />

        <label>요일 (0:일요일 ~ 6:토요일):</label>
        <form:input type="number" path="dayOfWeek" min="0" max="6" required="true" /><br/>

        <label>시간 (HH:mm):</label>
        <form:input type="time" path="timeSlot" required="true" /><br/>

        <label>최대 팀 수:</label>
        <form:input type="number" path="maxTeams" min="1" required="true" /><br/>

        <label>활성화:</label>
        <form:checkbox path="active" /><br/> <%-- **이 부분만 수정하면 됩니다!** --%>

        <button type="submit">등록</button>
    </form:form> <%-- form:form 태그 닫기 --%>
    <p><a href="/waiting/owner/settings?storeId=${storeId}">목록으로 돌아가기</a></p>
</body>
</html>