<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">

<style>
	.store-list { display: flex; flex-direction: column; gap: 15px; }
	.store-item { display: flex; align-items: center; padding: 15px; background-color: #fff; border-radius: 8px; box-shadow: 0 1px 4px rgba(0,0,0,0.1); gap: 20px; }
	.store-img { width: 180px; height: 120px; object-fit: cover; border-radius: 8px; flex-shrink: 0; }
	.store-info { flex-grow: 1; display: flex; flex-direction: column; gap: 4px; }
	.store-name { margin: 0; font-size: 1.4rem; font-weight: 600; color: #222; }
	.store-type, .store-address, .store-desc { margin: 0; font-size: 0.95rem; color: #555; }
	.btn-primary { padding: 6px 14px; font-size: 0.9rem; border-radius: 6px; transition: background-color 0.25s ease; border: none; background-color: #007bff; color: white; cursor: pointer; flex-shrink: 0; }
	.btn-primary:hover, .btn-primary:focus { background-color: #0056b3; outline: none; }
</style>

<div class="container-fluid">
	<c:choose>
		<c:when test="${type eq 'store'}">
			<h1 class="h3 mb-4">매장 정보 관리</h1>
			<div class="row">
				<c:if test="${not empty storeList}">
					<div class="store-list">
						<c:forEach var="store" items="${storeList}">
							<div class="store-item">
								<img src="${contextPath}/images/store/${store.fileName}" alt="${store.storeName}" class="store-img"/>
								<div class="store-info">
									<h3 class="store-name">${store.storeName}</h3>
									<p class="store-type">${store.storeType}</p>
									<p class="store-address">${store.roadAddress}</p>
									<p class="store-desc">${store.description}</p>
								</div>
								<a href="${contextPath}/franchise/modifyStoreInfoForm?storeId=${store.storeId}" class="btn btn-primary btn-sm" aria-label="${store.storeName} 수정하기">수정</a>
							</div>
						</c:forEach>
					</div>
				</c:if>
				<c:if test="${empty storeList}">
					<div class="col-12">
						<div class="card border-0 rounded-3 shadow-sm">
							<div class="card-body p-4 text-center">
								<h4 class="card-title mb-3">등록된 매장이 없습니다.</h4>
								<p class="text-muted">지금 바로 새로운 매장을 등록하고 관리하세요!</p>
								<a href="${contextPath }/franchise/addStoreInfoForm?ownerId=${memberId}" class="btn btn-primary mt-3">
									<i class="bi bi-plus-circle me-2"></i>새 매장 등록하기
								</a>
							</div>
						</div>
					</div>
				</c:if>
			</div>
		</c:when>
		
		<c:when test="${type eq 'menu'}">
			<h1 class="h3 mb-4">메뉴 관리</h1>
			<div class="row">
				<c:if test="${not empty storeList}">
					<div class="store-list">
						<c:forEach var="store" items="${storeList}">
							<div class="store-item">
								<img src="${contextPath}/images/store/${store.fileName}" alt="${store.storeName}" class="store-img"/>
								<div class="store-info">
									<h3 class="store-name">${store.storeName}</h3>
									<p class="store-type">${store.storeType}</p>
									<p>메뉴 ${store.menuCount }개 </p>
								</div>
								<c:choose>
									<c:when test="${store.menuCount > 0}">
										<a href="${contextPath}/franchise/modifyMenuForm?storeId=${store.storeId}" class="btn btn-primary btn-sm" aria-label="${store.storeName} 메뉴 수정하기">메뉴 수정</a>
									</c:when>
									<c:otherwise>
										<a href="${contextPath}/franchise/addMenuForm?storeId=${store.storeId}" class="btn btn-success btn-sm" aria-label="${store.storeName} 메뉴 추가하기">메뉴 추가</a>
									</c:otherwise>
								</c:choose>
							</div>
						</c:forEach>
					</div>
				</c:if>
				<c:if test="${empty storeList}">
					<p>등록된 매장이 없습니다.</p>
				</c:if>
			</div>
		</c:when>
		
		<c:when test="${type eq 'review'}">
			<h1 class="h3 mb-4">리뷰 관리</h1>
			<div class="row">
				<c:if test="${not empty storeList}">
					<div class="store-list">
						<c:forEach var="store" items="${storeList}">
							<div class="store-item">
								<img src="${contextPath}/images/store/${store.fileName}" alt="${store.storeName}" class="store-img"/>
								<div class="store-info">
									<h3 class="store-name">${store.storeName}</h3>
									<p class="store-type">${store.storeType}</p>
									<p>리뷰 ${store.countRating }개 </p>
								</div>

								<a href="${contextPath}/review/reviewManage?storeId=${store.storeId}" class="btn btn-primary btn-sm" aria-label="${store.storeName} 리뷰 관리">리뷰 관리</a>
							</div>
						</c:forEach>
					</div>
				</c:if>
				<c:if test="${empty storeList}">
					<p>등록된 매장이 없습니다.</p>
				</c:if>
			</div>
		</c:when>
		<c:otherwise></c:otherwise>
	</c:choose>
</div>
