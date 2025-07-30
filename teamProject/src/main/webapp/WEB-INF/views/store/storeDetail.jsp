<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="contextPath"  value="${pageContext.request.contextPath}"  />
<c:set var="store"  value="${storeMap.store}"  />
<c:set var="image"  value="${storeMap.imagelist }"  />
<c:set var="menu"  value="${storeMap.menu }"  />
<%-- <c:set var="review"  value="${storeMap.review }"  /> --%>
<c:set var="reservation"  value="${storeMap.reservation }"  />

<style>
	body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f4; }
	.container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); width: 600px; margin: 30px auto; }
	h2 { color: #333; text-align: center; margin-bottom: 25px; }
	p { margin-bottom: 10px; line-height: 1.6; }
	strong { display: inline-block; width: 100px; }
	.button-group { text-align: center; margin-top: 30px; }
	.button-group a { background-color: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin: 0 10px; display: inline-block; }
	.button-group a:hover { background-color: #0056b3; }
	.back-link { display: block; text-align: center; margin-top: 20px; }
	a { color: #007bff; text-decoration: none; }
	a:hover { text-decoration: underline; }
</style>

	<title>${store.storeName}</title>

    <div class="container">
        <h2>${store.storeName} 상세 정보</h2>

        <p><strong>주소:</strong> ${store.address}</p>
        <p><strong>설명:</strong> ${store.description}</p>
        <p><strong>운영 방식:</strong> ${store.operationType}</p>
        <%-- 추가적인 매장 정보 (예: 운영 시간, 전화번호 등)를 여기에 표시할 수 있습니다. --%>

        <div class="button-group">
            <%-- 예약 페이지로 이동하는 링크. storeId를 함께 넘깁니다. --%>
            <a href="<c:url value='/reservation/customer/bookForm?storeId=${store.storeId}'/>">예약하기</a>
            <%-- 점주용 관리 페이지로 이동하는 링크. storeId를 함께 넘깁니다. --%>
            <a href="<c:url value='/reservation/owner/manageList?storeId=${store.storeId}'/>">점주 관리 페이지</a>
        </div>

        <div class="back-link">
            <a href="<c:url value='/store/storeList.do'/>">매장 목록으로 돌아가기</a>
        </div>
    </div>
</body>
</html>