<%@ page contentType="text/html;charset=UTF-8" language="java" %>

    <footer class="py-5" style="background-color: var(--yum-dark-blue); color: var(--yum-cream);">
        <div class="container text-center">
            <p class="mb-1">&copy; 2025 Yum Table by Team Bapful. All rights reserved.</p>
            <small>
                <a href="#" class="text-white-50">서비스 소개</a> &middot;
                <a href="#" class="text-white-50">이용약관</a> &middot;
                <a href="#" class="text-white-50">개인정보처리방침</a>
            </small>
        </div>
    </footer>

    <%-- Bootstrap JS Bundle --%>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <%-- 페이지 내 모든 캐러셀(슬라이드)을 수동으로 활성화 --%>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var carousels = document.querySelectorAll('.carousel');
            carousels.forEach(function (carousel) {
                new bootstrap.Carousel(carousel);
            });
        });
    </script>
</body>
</html>
