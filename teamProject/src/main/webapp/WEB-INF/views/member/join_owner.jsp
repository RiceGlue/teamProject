<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container my-5" style="max-width: 600px;">
    <h2 class="text-center mb-4">가맹점주 회원가입</h2>
    
    <form action="${contextPath}/member/join" method="post">
        <input type="hidden" name="role" value="OWNER">

        <!-- ... 아이디, 비밀번호, 대표자명, 생년월일, 성별 필드 ... -->
        
        <div class="mb-3">
            <label for="loginId" class="form-label">아이디</label>
            <input type="text" class="form-control" id="loginId" name="loginId" required>
        </div>
        <div class="mb-3">
            <label for="loginPw" class="form-label">비밀번호</label>
            <input type="password" class="form-control" id="loginPw" name="loginPw" required>
        </div>
        <div class="mb-3">
            <label for="memberName" class="form-label">대표자명</label>
            <input type="text" class="form-control" id="memberName" name="memberName" required>
        </div>
        <div class="alert alert-secondary" role="alert">
          사업자 등록 정보는 추후 별도 페이지에서 인증 및 입력하게 됩니다.
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
        
        <!-- (수정) 전화번호 입력 부분 -->
        <div class="mb-3">
            <label for="phone" class="form-label">연락처</label>
            <div class="input-group">
                <select class="form-select" name="countryCode" style="max-width: 150px;">
                    <option value="82" selected>+82 (대한민국)</option>
                    <option value="1">+1 (United States)</option>
                    <option value="81">+81 (日本)</option>
                    <option value="86">+86 (中国)</option>
                    <option value="44">+44 (United Kingdom)</option>
                    <option value="49">+49 (Deutschland)</option>
                    <option value="33">+33 (France)</option>
                    <option value="1">+1 (Canada)</option>
                    <option value="61">+61 (Australia)</option>
                    <option value="7">+7 (Россия)</option>
                    <option value="34">+34 (España)</option>
                    <option value="39">+39 (Italia)</option>
                    <option value="84">+84 (Việt Nam)</option>
                    <option value="66">+66 (ประเทศไทย)</option>
                    <option value="63">+63 (Pilipinas)</option>
                    <option value="886">+886 (台灣)</option>
                    <option value="852">+852 (Hong Kong)</option>
                    <option value="65">+65 (Singapore)</option>
                    <option value="60">+60 (Malaysia)</option>
                    <option value="62">+62 (Indonesia)</option>
                    <option value="91">+91 (India)</option>
                    <option value="55">+55 (Brasil)</option>
                    <option value="52">+52 (México)</option>
                </select>
                <input type="tel" class="form-control" id="phone" name="phone" placeholder="'-' 없이 숫자만 입력" required>
            </div>
        </div>

        <div class="mb-3">
            <label for="email" class="form-label">이메일</label>
            <input type="email" class="form-control" id="email" name="email" placeholder="name@example.com" required>
        </div>
        <div class="d-grid">
            <button type="submit" class="btn btn-success">가입하기</button>
        </div>
    </form>
</div>
