<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %> <%-- 이 줄 추가 --%>
<html>
<head>
    <title>웨이팅 설정 수정</title>
</head>
<body>
    <h2>웨이팅 설정 수정</h2>
    <%-- modelAttribute를 명시하여 form 태그 시작 --%>
    <form:form modelAttribute="waitingSettingVO" action="/waiting/owner/settings/edit" method="post">
        <form:hidden path="settingId" />
        <form:hidden path="storeId" /> <%-- storeId도 함께 전달 --%>

        <label>요일:</label>
        <form:input type="number" path="dayOfWeek" readonly="true" /><br/> <%-- 요일은 수정 불가능 --%>

        <label>시간:</label>
        <form:input type="time" path="timeSlot" readonly="true" /><br/> <%-- 시간도 수정 불가능 --%>

        <label>최대 팀 수:</label>
        <form:input type="number" path="maxTeams" min="1" required="true" /><br/>

        <label>활성화:</label>
        <form:checkbox path="active" /><br/> <%-- **이 부분만 수정하면 됩니다!** --%>

        <button type="submit">수정</button>
    </form:form> <%-- form:form 태그 닫기 --%>
    <p><a href="/waiting/owner/settings?storeId=${storeId}">목록으로 돌아가기</a></p>
</body>
</html>