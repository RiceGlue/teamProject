<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>매장 목록</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f4; }
        h1 { color: #333; text-align: center; }
        table { width: 60%; margin: 20px auto; border-collapse: collapse; background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: #f2f2f2; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>

<h1>매장 목록 (가데이터)</h1>

<table>
	<thead>
		<tr>
			<th>매장명</th>
			<th>매장정보</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td><a href="<c:url value='/store/storeDetail.do?storeId=1'/>">맛있는 반찬가게 1호점</a></td>
			<td>
				<a href="<c:url value='/store/storeDetail.do?storeId=1'/>">상세 보기</a>
			</td>
		</tr>
        <tr>
			<td><a href="<c:url value='/store/storeDetail.do?storeId=2'/>">행복한 김치찌개 2호점</a></td>
			<td>
				<a href="<c:url value='/store/storeDetail.do?storeId=2'/>">상세 보기</a>
			</td>
		</tr>
        <tr>
			<td><a href="<c:url value='/store/storeDetail.do?storeId=3'/>">고소한 삼겹살 3호점</a></td>
			<td>
				<a href="<c:url value='/store/storeDetail.do?storeId=3'/>">상세 보기</a>
			</td>
		</tr>
		<%-- 필요에 따라 더 많은 가데이터 매장을 추가하세요 --%>
	</tbody>
</table>

</body>
</html>