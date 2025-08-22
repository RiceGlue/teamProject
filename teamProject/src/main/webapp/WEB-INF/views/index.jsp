<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="row">
	<!-- test 섹션 -->
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

	<div class="container my-4">
		<div class="col-12">
			<h2>배너</h2>
		</div>
	</div>
	<div class="container my-4">
		<div class="col-12">
			<h2>검색바</h2>
			<div class="search-container">
				<input type="text" class="search-input" placeholder="검색어를 입력하세요..." id="keyword">
				<button type="button" class="search-button" onclick="goSearch()">
				   	<img src="https://cdn-icons-png.flaticon.com/512/54/54481.png" alt="검색">
				</button>
			</div>
		</div>
	</div>
	<!-- 지역 선택 섹션 -->
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

	<!-- 빠른 링크 섹션 -->
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
	<div class="container my-4">
		<div class="col-12">
			<h2>내 지역 맛집</h2>
		</div>
	</div>
</div>
