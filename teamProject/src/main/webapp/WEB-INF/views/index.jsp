<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- Google Maps JavaScript API 로드 (API 키 필요) -->
<script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyB1kAhEMiW_-y5zg2uFTUeAOTG_uVO_kts&callback=initMap"></script>

<style>
    .carousel-item img { height: 500px; object-fit: cover; }
    .carousel-caption { background-color: rgba(0, 0, 0, 0.5); border-radius: 5px; padding: 10px; }
    #map { height:300px; width:100%; background-color:#eee; }
</style>

<div class="row">
	<div class="container my-4">
	    <div class="col-12">
	        <div id="bannerCarousel" class="carousel slide" data-bs-ride="carousel">
	            <div class="carousel-inner">
	                <c:forEach var="banner" items="${bannerList}" varStatus="status">
	                    <div class="carousel-item <c:if test="${status.first}">active</c:if>">
	                        <a href="${contextPath}/promotion/detail?id=${banner.promotionId}">
	                            <img src="${contextPath}/images/banners/${banner.getImagePath()}"
	                                 class="d-block w-100 img-fluid" alt="${banner.text}">
								<div class="carousel-caption d-none d-md-block">
                                    <h5 class="text-white">${banner.text}</h5>
                                </div>
	                        </a>
	                    </div>
	                </c:forEach>
	            </div>

	            <button class="carousel-control-prev" type="button" data-bs-target="#bannerCarousel" data-bs-slide="prev">
	                <span class="carousel-control-prev-icon" aria-hidden="true"></span>
	                <span class="visually-hidden">Previous</span>
	            </button>
	            <button class="carousel-control-next" type="button" data-bs-target="#bannerCarousel" data-bs-slide="next">
	                <span class="carousel-control-next-icon" aria-hidden="true"></span>
	                <span class="visually-hidden">Next</span>
	            </button>

	            <div class="carousel-indicators">
	                <c:forEach varStatus="status" items="${bannerList}">
	                    <button type="button" data-bs-target="#bannerCarousel" data-bs-slide-to="${status.index}"
	                            class="<c:if test="${status.first}">active</c:if>" aria-current="true"
	                            aria-label="Slide ${status.index + 1}"></button>
	                </c:forEach>
	            </div>
	        </div>
	    </div>
	</div>

	<div class="container my-4">
		<div class="col-12">
			<div class="search-container">
				<input type="text" class="search-input" placeholder="검색어를 입력하세요..." id="keyword">
				<button type="button" class="search-button" onclick="goSearch()">
				   	<img src="https://cdn-icons-png.flaticon.com/512/54/54481.png" alt="검색">
				</button>
			</div>
		</div>
	</div>
	<div class="container my-4">
	    <h2>지역 선택</h2>
	    <div class="row row-cols-2 row-cols-md-4 g-3">
	        <div class="col">
	        	<div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/store/storeList?option=region&keyword=서울">서울</a></h5>

	                </div>
	            </div>
	        	<div class="card text-center">
	        		<h5 class="card-title"><a href="${contextPath}/franchise/addStoreInfoForm?ownerId=10">매장 정보 입력</a></h5>
					<h5 class="card-title"><a href="${contextPath}/franchise/modifyStoreInfoForm?storeId=1">매장 정보 수정</a></h5>
					<h5 class="card-title"><a href="${contextPath}/franchise/addMenuForm?storeId=1&ownerId=1">메뉴 입력</a></h5>
					<h5 class="card-title"><a href="${contextPath}/franchise/modifyMenuForm?storeId=1">메뉴 수정</a></h5>
	        	</div>
	        	<div class="card text-center">
	        		<h5 class="card-title"><a href="${contextPath}/review/reviewForm?memberId=3&storeId=1&reservationId=114">리뷰 작성</a></h5>
	        		<h5 class="card-title"><a href="${contextPath}/review/modifyReviewForm?memberId=3&reviewId=60">리뷰 수정</a></h5>
	        	</div>

	        </div>
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/store/storeList?option=region&keyword=경기">경기</a></h5>
	                </div>
	            </div>
	        </div>
			<div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/store/storeList?option=region&keyword=대전">대전</a></h5>
	                </div>
	            </div>
	        </div>
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/store/storeList?option=region&keyword=부산">부산</a></h5>
	                </div>
	            </div>
	        </div>
	    </div>
	</div>

	<div class="container my-4">
	    <h2>빠른 링크</h2>
	    <div class="row row-cols-1 row-cols-md-3 g-3">
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <a href="#" class="stretched-link">요즘뜨는</a>
	                </div>
	            </div>
	        </div>
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <a href="#" class="stretched-link">음식별</a>
	                </div>
	            </div>
	        </div>
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <a href="#" class="stretched-link">테마별</a>
	                </div>
            </div>
        </div>
    </div>
</div>
<div class="container my-4">
    <div class="col-12">
        <h2>최신인기리뷰</h2>
    </div>
</div>
<div class="row">
    <div class="container my-4">
        <div class="col-12">
            <h2>내 지역 맛집</h2>
            <p>사용자 현재 위치 : <span id="address"> 위치 정보를 불러오는 중...</span> </p>
            <div id="map"></div>
            <hr />
            <h4>근처 매장</h4>
            <div id="nearbyStores"></div>
         </div>
    </div>
</div>
   
<div class="container my-4">
    <h2>매장 관리자 (점주) TEST 링크</h2>
    <div class="row g-3">
        <div class="col">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="card-title"><a href="${contextPath}/waiting/owner/settings?storeId=1">사용자(점주) 웨이팅 설정 관리</h5>
                </div>
            </div>
        </div>
         <div class="col">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="card-title"><a href="/reservation/owner/manageList?storeId=1">사용자(점주) 예약 관리</a></h5>
                </div>
            </div>
        </div>
    </div>
</div>

</div>