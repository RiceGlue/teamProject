<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<h1>${region}
<c:forEach var="store" items="${storelist}">
	<div>
		<div id="store_image">
			<figure>
				<a href="${contextPath}/store/storeDetail.do?store_id=${store.store_id}"><img src="/image?goods_id=123&fileName=test.jpg" alt="가게이미지"></a>
			</figure>
		</div>
		</div id="store_info">
			<h4>${store.storeName}</h4>
			<p>${store.avgRating} 리뷰 ${store.countRating}개</p>
			<p>${store.description}</p>
		<div>
	</div>
</c:forEach>