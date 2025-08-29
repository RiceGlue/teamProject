<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>관리자 - 프로모션 목록</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            padding: 20px;
        }
        .container {
            max-width: 900px;
        }
        .table-actions {
            white-space: nowrap;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1 class="h3">프로모션 관리</h1>
            <a href="/admin/promotion/form" class="btn btn-primary">새 프로모션 추가</a>
        </div>

        <table class="table table-striped table-hover">
            <thead class="table-dark">
                <tr>
                    <th scope="col">ID</th>
                    <th scope="col">제목</th>
                    <th scope="col">시작일</th>
                    <th scope="col">종료일</th>
                    <th scope="col">상태</th>
                    <th scope="col">관리</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="promotion" items="${promotions}">
                    <tr>
                        <th scope="row">${promotion.promotionId}</th>
                        <td>${promotion.title}</td>
                        <td>${promotion.startDate}</td>
                        <td>${promotion.endDate}</td>
                        <td>
                            <span class="badge ${promotion.isActive ? 'bg-success' : 'bg-secondary'}">
                                ${promotion.isActive ? "활성" : "비활성"}
                            </span>
                        </td>
                        <td class="table-actions">
                            <!-- 수정 링크 -->
                            <a href="/admin/promotion/form?id=${promotion.promotionId}" class="btn btn-sm btn-info me-2">수정</a>

                            <!-- 삭제 폼 -->
                            <form action="/admin/promotion/delete" method="post" class="d-inline-block">
                                <input type="hidden" name="id" value="${promotion.promotionId}">
                                <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('정말로 삭제하시겠습니까?');">삭제</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Bootstrap JS (Optional, for some features) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
