function goSearch() {
    const input = document.getElementById('keyword');
    const keyword = input.value.trim();

    if (!keyword) {
        alert("검색어를 입력해주세요.");
        input.focus();
        return;
    }

    // contextPath가 /myapp 같은 경우를 대비
    const url = `${contextPath}/store/searchStore?keyword=${encodeURIComponent(keyword)}`;

    window.location.href = url;
}
