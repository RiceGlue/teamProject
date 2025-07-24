<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container my-5 text-center">
    <h2 class="mb-5">회원가입 유형 선택</h2>
    <div class="row justify-content-center g-4">
        <div class="col-md-5">
            <div class="card h-100">
                <div class="card-body d-flex flex-column justify-content-center align-items-center p-5">
                    <h4 class="card-title mb-3">일반 회원</h4>
                    <p class="card-text text-muted mb-4">맛집을 예약하고 웨이팅하려면<br>일반 회원으로 가입해주세요.</p>
                    <a href="${contextPath}/member/join?role=USER" class="btn btn-primary btn-lg">일반 회원가입</a>
                </div>
            </div>
        </div>
        <div class="col-md-5">
            <div class="card h-100">
                <div class="card-body d-flex flex-column justify-content-center align-items-center p-5">
                    <h4 class="card-title mb-3">가맹점주 회원</h4>
                    <p class="card-text text-muted mb-4">가게를 등록하고 예약을 받으려면<br>가맹점주 회원으로 가입해주세요.</p>
                    <a href="${contextPath}/member/join?role=OWNER" class="btn btn-success btn-lg">가맹점주 회원가입</a>
                </div>
            </div>
        </div>
    </div>
</div>
