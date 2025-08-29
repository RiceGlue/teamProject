<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>프로모션 추가/수정</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            padding: 20px;
        }
        .container {
            max-width: 600px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="mb-4">
            <c:choose>
                <c:when test="${promotion.promotionId != null}">프로모션 수정</c:when>
                <c:otherwise>새 프로모션 추가</c:otherwise>
            </c:choose>
        </h1>
        <form action="/admin/promotion/add" method="post">
            <!-- 수정 시에만 hidden 필드로 ID 전송 -->
            <c:if test="${promotion.promotionId != null}">
                <input type="hidden" name="promotionId" value="${promotion.promotionId}">
            </c:if>

            <div class="mb-3">
                <label for="title" class="form-label">제목:</label>
                <input type="text" class="form-control" id="title" name="title" value="${promotion.title}" required>
            </div>
            <div class="mb-3">
                <label for="content" class="form-label">내용:</label>
                <textarea class="form-control" id="content" name="content" rows="5" required>${promotion.content}</textarea>
            </div>
            <div class="mb-3">
                <label for="imagePath" class="form-label">이미지 경로:</label>
                <input type="text" class="form-control" id="imagePath" name="imagePath" value="${promotion.imagePath}" required>
            </div>
            <div class="mb-3">
                <label for="startDate" class="form-label">시작일:</label>
                <input type="date" class="form-control" id="startDate" name="startDate" value="${promotion.startDate}" required>
            </div>
            <div class="mb-3">
                <label for="endDate" class="form-label">종료일:</label>
                <input type="date" class="form-control" id="endDate" name="endDate" value="${promotion.endDate}" required>
            </div>
            <div class="form-check mb-3">
                <input type="checkbox" class="form-check-input" id="isActive" name="isActive" <c:if test="${promotion.isActive}">checked</c:if>>
                <label class="form-check-label" for="isActive">활성화</label>
            </div>
            <div class="d-flex justify-content-between">
                <button type="submit" class="btn btn-primary">저장</button>
                <a href="/admin/promotion/list" class="btn btn-secondary">취소</a>
            </div>
        </form>
    </div>

    <!-- Bootstrap JS (Optional) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
