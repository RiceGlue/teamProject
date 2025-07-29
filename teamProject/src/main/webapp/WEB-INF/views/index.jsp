<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<div class="row">
	<!-- test 섹션 -->
	<div class="container my-4">
	    <h2>test 링크</h2>
	    <div class="row row-cols-2 row-cols-md-2 g-3">
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/waiting/customer/register">사용자 웨이팅 등록 버튼</a></h5>
	                </div>
	            </div>
	        </div>
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/waiting/owner/settings?storeId=1">관리자 웨이팅 설정,<br> 웨이팅 실시간 대기열 리스트 버튼</a></h5>
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
			    <input type="text" class="search-input" placeholder="검색어를 입력하세요...">
			    <button class="search-button" onclick="goSearch()">
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
	                    <h5 class="card-title"><a href="${contextPath}/store/storeRegionList.do?region=서울">서울</a></h5>
						<h5 class="card-title"><a href="${contextPath}/franchise/storeInfoForm.do?storeId=1">서울</a></h5>
	                </div>
	            </div>
	        </div>
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/store/storeRegionList.do?region=경기">경기</a></h5>
	                </div>
	            </div>
	        </div>
			<div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/store/storeRegionList.do?region=대전">대전</a></h5>
	                </div>
	            </div>
	        </div>
	        <div class="col">
	            <div class="card text-center">
	                <div class="card-body">
	                    <h5 class="card-title"><a href="${contextPath}/store/storeRegionList.do?region=부산">부산</a></h5>
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
