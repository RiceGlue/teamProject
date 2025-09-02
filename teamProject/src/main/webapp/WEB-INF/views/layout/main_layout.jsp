<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>얌테이블</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
    
    <%-- Sticky Footer를 위한 스타일 추가 --%>
    <style>
        /* html, body를 화면 전체 높이로 설정합니다. */
        html, body {
            height: 100%;
        }
        /* body를 flex 컨테이너로 만들어 자식 요소들을 세로로 정렬합니다. */
        body {
            display: flex;
            flex-direction: column;
        }
        /* content-wrapper가 남는 공간을 모두 차지하도록 설정하여 푸터를 밀어냅니다. */
        .content-wrapper {
            flex-grow: 1;
        }
    </style>
</head>
<body>
    <%-- 1. 헤더 포함 --%>
    <%@ include file="main_header.jsp" %>

    <%-- 2. 메인 콘텐츠를 감싸는 래퍼 div 추가 --%>
    <div class="content-wrapper">
        <jsp:include page="/WEB-INF/views/${body}" />
    </div>

    <%-- 채팅창 UI를 모든 페이지에 포함시킵니다. --%>
    <jsp:include page="../common/chat.jsp" />

    <%-- 3. 푸터 포함 --%>
    <%@ include file="main_footer.jsp" %>
</body>
</html>

