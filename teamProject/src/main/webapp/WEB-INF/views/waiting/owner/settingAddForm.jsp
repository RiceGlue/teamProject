<%-- src/main/webapp/WEB-INF/views/waiting/owner/settingAddForm.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<html>
<head>
    <title>${store.storeName} - 웨이팅 설정 추가</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f4; }
        h2 { color: #333; text-align: center; margin-bottom: 25px; }
        form { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); width: 400px; margin: 20px auto; }
        label { display: block; margin-bottom: 8px; font-weight: bold; }
        input[type="text"],
        input[type="number"],
        select { width: calc(100% - 22px); padding: 10px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 4px; }
        input[type="checkbox"] { margin-top: 5px; margin-bottom: 15px; }
        button { background-color: #28a745; color: white; padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background-color: #218838; }
        p a { color: #007bff; text-decoration: none; display: block; text-align: center; margin-top: 20px; }
        p a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h2>${store.storeName} - 웨이팅 설정 추가</h2>

    <form:form modelAttribute="waitingSettingVO" action="/waiting/owner/settings/add" method="post">

        <form:hidden path="storeId" />

        <label for="dayOfWeek">요일:</label>
        <form:input type="number" path="dayOfWeek" id="dayOfWeek" min="1" max="7" required="true" placeholder="1=월, 7=일" /><br/>

        <%-- timeSlot 입력 필드를 제거합니다. --%>

        <label for="maxTeams">최대 팀 수:</label>
        <form:input type="number" path="maxTeams" id="maxTeams" min="1" required="true" /><br/>

        <label for="active">활성화:</label>
        <form:checkbox path="active" id="active" /><br/>

        <button type="submit">설정 추가</button>
    </form:form>

    <p><a href="<c:url value='/waiting/owner/settings?storeId=${storeId}'/>">설정 목록으로 돌아가기</a></p>
</body>
</html>