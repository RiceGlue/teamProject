<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>웨이팅 설정 수정</title>
</head>
<body>
    <h2>웨이팅 설정 수정</h2>
    <form action="/waiting/owner/settings/edit" method="post">
        <input type="hidden" name="settingId" value="${waitingSettingVO.settingId}" />
        <input type="hidden" name="storeId" value="${storeId}" /> <%-- storeId도 함께 전달 --%>
        
        <label>요일:</label>
        <input type="number" name="dayOfWeek" value="${waitingSettingVO.dayOfWeek}" readonly /><br/> <%-- 요일은 수정 불가능 --%>

        <label>시간:</label>
        <input type="time" name="timeSlot" value="${waitingSettingVO.timeSlot}" readonly /><br/> <%-- 시간도 수정 불가능 --%>

        <label>최대 팀 수:</label>
        <input type="number" name="maxTeams" value="${waitingSettingVO.maxTeams}" required /><br/>

        <label>활성화:</label>
        <input type="hidden" name="active" value="false"/>
        <input type="checkbox" name="active" value="true" ${waitingSettingVO.active ? 'checked' : ''}/><br/>

        <button type="submit">수정</button>
    </form>
    <p><a href="/waiting/owner/settings?storeId=${storeId}">목록으로 돌아가기</a></p>
</body>
</html>