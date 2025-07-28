<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container my-5" style="max-width: 600px;">
    <h2 class="text-center mb-4">추가 정보 입력</h2>
    <p class="text-center text-muted mb-4">정확한 서비스 이용을 위해 추가 정보를 입력해주세요.</p>
    
    <form action="${contextPath}/member/join-social" method="post">
        <div class="mb-3">
            <label for="email" class="form-label">이메일</label>
            <input type="email" class="form-control" id="email" name="email" value="${socialUserInfo.email}" readonly>
        </div>
        <div class="mb-3">
            <label for="memberName" class="form-label">이름</label>
            <%-- (수정) readonly 속성을 제거하여 사용자가 직접 이름을 수정할 수 있도록 변경 --%>
            <input type="text" class="form-control" id="memberName" name="memberName" value="${socialUserInfo.name}" required>
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
            <label for="phone" class="form-label">전화번호</label>
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
        
        <div class="d-grid">
            <button type="submit" class="btn btn-primary">가입 완료</button>
        </div>
    </form>
</div>
