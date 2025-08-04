


//index page searching bar onclick
function goSearch() {
  const input = document.getElementById("keyword");
  const keyword = input.value.trim();

  if (keyword === "") {
    alert("검색어를 입력해주세요.");
    input.focus();
    return;
  }

  // 원하는 검색 결과 페이지 경로 설정
  const baseUrl = "/store/storeList?option=search"; // 예: /search 페이지로 이동
  const url = new URL(baseUrl, window.location.origin);
  url.searchParams.set("keyword", keyword);

  // 페이지 이동
  window.location.href = url.toString();
}