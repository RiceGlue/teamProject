<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid">
    <h1 class="h3 mb-4 text-gray-800">가맹점주 계정 생성</h1>

    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h6 class="m-0 font-weight-bold text-primary">신규 가맹점주 정보 입력</h6>
        </div>
        <div class="card-body">
            <%-- TODO: 가맹점주 생성 처리할 URL로 action 변경 필요 --%>
            <form action="${contextPath}/admin/owners" method="post">
                <input type="hidden" name="role" value="OWNER">

                <div class="mb-3">
                    <label for="loginId" class="form-label">아이디</label>
                    <input type="text" class="form-control" id="loginId" name="loginId" required>
                </div>
                
                <div class="mb-3">
                    <label for="loginPw" class="form-label">초기 비밀번호</label>
                    <input type="password" class="form-control" id="loginPw" name="loginPw" required>
                </div>

                <div class="mb-3">
                    <label for="memberName" class="form-label">대표자명</label>
                    <input type="text" class="form-control" id="memberName" name="memberName" required>
                </div>

                <div class="mb-3">
                    <label for="birth" class="form-label">생년월일</label>
                    <input type="date" class="form-control" id="birth" name="birth" required>
                </div>

                <div class="mb-3">
                    <label class="form-label">성별</label>
                    <div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="sex" id="male" value="male" checked>
                            <label class="form-check-label" for="male">남성</label>
                        </div>
                        <div class="form-check form-check-inline">
                            <input class="form-check-input" type="radio" name="sex" id="female" value="female">
                            <label class="form-check-label" for="female">여성</label>
                        </div>
                    </div>
                </div>
                
                <div class="mb-3">
                    <label for="phone" class="form-label">연락처</label>
                    <div class="input-group">
                        <select class="form-select" name="countryCode" style="max-width: 150px;">
                            <option value="82" selected>+82 (대한민국)</option>
                            <option value="1">+1 (United States)</option>
                        </select>
                        <input type="tel" class="form-control" id="phone" name="phone" placeholder="'-' 없이 숫자만 입력" required>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="email" class="form-label">이메일</label>
                    <input type="email" class="form-control" id="email" name="email" placeholder="name@example.com" required>
                </div>

                <div class="d-grid">
                    <button type="submit" class="btn btn-primary">계정 생성</button>
                </div>
            </form>
        </div>
    </div>
</div>
