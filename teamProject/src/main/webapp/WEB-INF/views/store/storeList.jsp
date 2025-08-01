<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
	.store-card { display:flex; border:1px solid #e0e0e0; border-radius:8px; padding:12px; max-width:500px; margin-bottom:16px; margin: 0 auto 0; font-family:'Segoe UI', sans-serif; box-shadow:0 2px 6px rgba(0,0,0,0.05); align-items:center; }
	.store-image { position:relative; width:120px; height:120px; border-radius:6px; overflow:hidden; flex-shrink:0; }
	.store-image img { width:100%; height:100%; object-fit:cover; }
	.badge-rank { position:absolute; top:6px; left:6px; background:#ff4b4b; color:#fff; font-size:14px; padding:2px 6px; border-radius:4px; font-weight:bold; }
	.badge-wait { position:absolute; bottom:6px; left:6px; background:#00b386; color:#fff; font-size:12px; padding:2px 6px; border-radius:4px; }
	.store-info { margin-left:16px; flex:1; }
	.store-info h4 { margin:0 0 6px; font-size:18px; }
	.store-info p { margin:4px 0; font-size:14px; color:#444; }
	.rating { color:#ffa500; font-weight:bold; }
	.meta-info { font-size:13px; color:#777; }
	.meta-info i { margin-right:4px; }
</style>

<h2>${keyword }</h2>
<!-- 반복 렌더링 시작 -->
<c:forEach var="store" items="${storelist}" varStatus="status">
  <div class="store-card">
    <div class="store-image">
      <a href="${contextPath}/store/storeDetail?storeId=${store.storeId}">
        <img src="${store.mainImage}" alt="가게이미지">
      </a>
<!--       대기 팀 수 표시 -->
<%--       <c:if test="${store.waitCount > 0}"> --%>
<%--         <div class="badge-wait">대기 ${store.waitCount}팀</div> --%>
<%--       </c:if> --%>
    </div>

    <div class="store-info">
      <h4>${store.storeName}</h4>
      <p>
        <span class="rating">★ ${store.avgRating}</span>
        리뷰 ${store.countRating}개
      </p>
      <p class="meta-info">${store.storeType} · ${store.region}</p>
      <p class="meta-info">${store.description}</p>
<%--       <p class="meta-info">${store.openHour}:${store.openMin}~${store.endHour}:${store.endMin}</p> --%>
    </div>
  </div>
</c:forEach>
