<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>${store.storeName} - 웨이팅 관리 대시보드</title> <%-- 제목 통일 --%>

    <%-- Firebase SDK 스크립트 (버전 9.6.0으로 명시) --%>
    <script src="https://www.gstatic.com/firebasejs/9.6.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.6.0/firebase-database-compat.js"></script>

    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f4f4; }
        .container { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); width: 80%; max-width: 1200px; margin: 20px auto; }
        h2, h3 { color: #333; text-align: center; margin-bottom: 25px; margin-top: 30px; }

        /* 웨이팅 설정 테이블 스타일 */
        .setting-table { width: 100%; border-collapse: collapse; margin-top: 20px; margin-bottom: 40px;}
        .setting-table th, .setting-table td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        .setting-table th { background-color: #f2f2f2; }
        .active-status { font-weight: bold; }
        .active-true { color: green; }
        .active-false { color: red; }
        .button-group { margin-top: 20px; text-align: right; }
        .action-button, .add-button { background-color: #007bff; color: white; padding: 8px 12px; border: none; border-radius: 4px; cursor: pointer; font-size: 0.9em; text-decoration: none; display: inline-block; margin-left: 5px;}
        .add-button { background-color: #28a745; }
        .action-button:hover { background-color: #0056b3; }
        .add-button:hover { background-color: #218838; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }

        /* 실시간 웨이팅 목록 스타일 (개별 항목 카드 형식) */
        #realtimeWaitingList {
            display: grid; /* Flexbox 대신 Grid 사용으로 더 깔끔한 배치 */
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); /* 최소 300px 너비로 자동 채움 */
            gap: 20px; /* 항목 간 간격 */
            margin-top: 20px;
        }

        .waiting-item {
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 15px;
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            display: flex;
            flex-direction: column;
            justify-content: space-between; /* 내용과 버튼 그룹을 분리 */
        }
        .waiting-item p { margin: 5px 0; }
        .waiting-item strong { color: #555; }

        .waiting-item .actions {
            margin-top: 15px;
            display: flex;
            flex-wrap: wrap; /* 버튼이 많아지면 줄바꿈 */
            gap: 8px; /* 버튼 간 간격 */
            justify-content: flex-end; /* 버튼을 오른쪽 정렬 */
        }

        .waiting-item button {
            padding: 8px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            transition: background-color 0.2s;
            font-size: 0.9em;
        }
        .waiting-item button.called { background-color: #007bff; color: white; } /* 호출 버튼 */
        .waiting-item button.seated { background-color: #28a745; color: white; } /* 입장 처리 (accepted 대신) */
        .waiting-item button.canceled { background-color: #dc3545; color: white; } /* 취소 처리 */
        .waiting-item button.no-show { background-color: #ffc107; color: #333; } /* 노쇼 처리 */
        .waiting-item button:hover { opacity: 0.9; }

        /* 상태별 텍스트 색상 */
        .status-WAITING { color: #007bff; font-weight: bold; } /* Blue */
        .status-CALLED { color: #6f42c1; font-weight: bold; } /* Purple */
        .status-SEATED { color: #28a745; font-weight: bold; } /* Green */
        .status-CANCELLED { color: #dc3545; font-weight: bold; } /* Red */
        .status-NO_SHOW { color: #ffc107; font-weight: bold; } /* Orange */

        hr { margin: 40px 0; border: 0; border-top: 1px solid #eee; }
    </style>
</head>
<body>
    <div class="container">
        <h1>${store.storeName} - 매장 관리 대시보드</h1> <%-- h1은 페이지 전체 제목 --%>

        <hr> <%-- 상단 구분선 추가 --%>

        <h2>웨이팅 설정 목록</h2>
        <div class="button-group">
            <%-- 요일별 설정이 아니므로 "새 설정 추가" 버튼은 매장별로 한 번만 추가하도록 로직 변경 고려 --%>
            <a href="<c:url value='/waiting/owner/settings/addForm?storeId=${storeId}'/>" class="add-button">+ 새 설정 추가</a>
        </div>

        <%-- 웨이팅 설정 테이블 --%>
        <table class="setting-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <%-- <th>요일</th> --%> <%-- 요일 필드 제거 --%>
                    <th>최대 팀 수</th>
                    <th>활성화 여부</th>
                    <th>생성일</th>
                    <th>수정일</th>
                    <th>관리</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty settings}">
                        <c:forEach var="setting" items="${settings}">
                            <tr>
                                <td>${setting.settingId}</td>
                                <%-- <td>
                                    <c:choose>
                                        <c:when test="${setting.dayOfWeek == 0}">일요일</c:when>
                                        <c:when test="${setting.dayOfWeek == 1}">월요일</c:when>
                                        <c:when test="${setting.dayOfWeek == 2}">화요일</c:when>
                                        <c:when test="${setting.dayOfWeek == 3}">수요일</c:when>
                                        <c:when test="${setting.dayOfWeek == 4}">목요일</c:when>
                                        <c:when test="${setting.dayOfWeek == 5}">금요일</c:when>
                                        <c:when test="${setting.dayOfWeek == 6}">토요일</c:when>
                                        <c:otherwise>알수없음</c:otherwise>
                                    </c:choose>
                                </td> --%>
                                <td>${setting.maxTeams}</td>
                                <td class="active-status ${setting.active ? 'active-true' : 'active-false'}">
                                    ${setting.active ? '사용' : '중지'}
                                </td>
                                <td>${setting.createdAt}</td>
                                <td>${setting.updatedAt}</td>
                                <td>
                                    <a href="<c:url value='/waiting/owner/settings/editForm/${setting.settingId}?storeId=${storeId}'/>" class="action-button">수정</a>
                                    <a href="<c:url value='/waiting/owner/settings/delete/${setting.settingId}?storeId=${storeId}'/>"
                                       class="action-button" onclick="return confirm('이 설정을 삭제하시겠습니까?');">삭제</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <%-- 요일 컬럼 삭제로 인해 colspan 값 변경 (7 -> 6) --%>
                            <td colspan="6" style="padding: 10px; text-align: center; color: #6c757d;">등록된 웨이팅 설정이 없습니다.</td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>

        <hr> <%-- 중간 구분선 추가 --%>

        <h2>실시간 웨이팅 현황</h2>
        <div id="realtimeWaitingList">
            <p>로딩 중 웨이팅 목록...</p>
        </div>

        <hr> <%-- 하단 구분선 추가 --%>

        <p><a href="<c:url value='/store/storeDetail.do?storeId=${storeId}'/>">매장 상세 보기로 돌아가기</a></p>
    </div>

    <script>
        // Firebase 프로젝트 설정
        const firebaseConfig = {
            apiKey: "AIzaSyA9D4IB4LfBgyU-UBwoFSPJLo6giLcNyf4",
            authDomain: "riceglue-9864b.firebaseapp.com",
            databaseURL: "https://riceglue-9864b-default-rtdb.asia-southeast1.firebasedatabase.app",
            projectId: "riceglue-9864b",
            storageBucket: "riceglue-9864b.firebasestorage.app",
            messagingSenderId: "962078958463",
            appId: "1:962078958463:web:e6448b0d9a515cfecc304a",
            measurementId: "G-B3DPWVEZJR"
        };
        firebase.initializeApp(firebaseConfig);
        const database = firebase.database();

        // Spring Model에서 storeId 가져오기
        const storeId = ${storeId}; // JSP 변수를 JavaScript로 가져옴

        if (storeId) {
            // Firebase Realtime Database의 해당 매장 웨이팅 참조
            const waitingRef = database.ref('waitings/' + storeId);

            // 데이터 변경 감지 리스너
            waitingRef.on('value', (snapshot) => {
                const data = snapshot.val(); // Firebase에서 가져온 모든 웨이팅 데이터
                const realtimeWaitingListDiv = document.getElementById('realtimeWaitingList');
                realtimeWaitingListDiv.innerHTML = ''; // 기존 목록 초기화

                console.log("DEBUG: Firebase fetched data:", data);

                if (data) {
                    // status가 'WAITING' 또는 'CALLED'인 항목만 필터링하고 createdAt으로 정렬
                    const currentWaitings = Object.entries(data)
                        .filter(([, waiting]) => waiting.status === 'WAITING' || waiting.status === 'CALLED')
                        .sort(([, a], [, b]) => a.createdAt - b.createdAt);

                    console.log("DEBUG: Filtered and sorted waitings for rendering:", currentWaitings);

                    if (currentWaitings.length > 0) {
                        currentWaitings.forEach(([waitingId, waiting]) => {
                            console.log("DEBUG: Processing waitingId for rendering:", waitingId, "with data:", waiting);
                            const listItem = document.createElement('div');
                            listItem.className = 'waiting-item';

                            // Unix timestamp (ms)를 Date 객체로 변환 후 로컬 형식으로 포맷
                            const formattedCreatedAt = new Date(waiting.createdAt).toLocaleString();
                            const formattedUpdatedAt = new Date(waiting.updatedAt || waiting.createdAt).toLocaleString(); // updatedAt이 없으면 createdAt 사용

                            let htmlContent = '';
                            htmlContent += '<p><strong>대기번호:</strong> ' + waitingId + '</p>';
                            htmlContent += '<p><strong>회원 ID:</strong> ' + (waiting.memberId || '비회원') + '</p>';
                            htmlContent += '<p><strong>인원:</strong> ' + waiting.guestCount + '명</p>';
                            htmlContent += '<p><strong>상태:</strong> <span class="status-' + waiting.status + '">' + waiting.status + '</span></p>';
                            htmlContent += '<p><strong>등록 시간:</strong> ' + formattedCreatedAt + '</p>';
                            if (waiting.updatedAt) {
                                htmlContent += '<p><strong>업데이트 시간:</strong> ' + formattedUpdatedAt + '</p>';
                            }
                            htmlContent += '<div class="actions">';

                            // 'WAITING' 상태일 때만 '호출' 버튼 보이기
                            if (waiting.status === 'WAITING') {
                                htmlContent += '<button class="called" onclick="updateWaitingStatus(\'' + waitingId + '\', \'CALLED\')">호출</button>';
                            }
                            // 'CALLED' 상태일 때만 '입장 처리' 버튼 보이기
                            if (waiting.status === 'CALLED') {
                                htmlContent += '<button class="seated" onclick="updateWaitingStatus(\'' + waitingId + '\', \'SEATED\')">입장 처리</button>';
                            }
                            // 어떤 상태든 '취소', '노쇼' 버튼은 보이게 (필요에 따라 조건 추가 가능)
                            htmlContent += '<button class="canceled" onclick="updateWaitingStatus(\'' + waitingId + '\', \'CANCELLED\')">취소 처리</button>';
                            htmlContent += '<button class="no-show" onclick="updateWaitingStatus(\'' + waitingId + '\', \'NO_SHOW\')">노쇼 처리</button>';
                            htmlContent += '</div>';

                            listItem.innerHTML = htmlContent;
                            realtimeWaitingListDiv.appendChild(listItem);
                        });
                    } else {
                        realtimeWaitingListDiv.innerHTML = '<p style="text-align: center; color: #6c757d;">현재 대기 중인 고객이 없습니다.</p>';
                    }
                } else {
                    realtimeWaitingListDiv.innerHTML = '<p style="text-align: center; color: #6c757d;">현재 웨이팅이 없습니다.</p>';
                }
            }, (error) => {
                console.error("Firebase 데이터 읽기 실패:", error);
                realtimeWaitingListDiv.innerHTML = '<p style="text-align: center; color: #dc3545;">웨이팅 데이터를 불러오는 중 오류가 발생했습니다.</p>';
            });
        } else {
             document.getElementById('realtimeWaitingList').innerHTML = '<p style="text-align: center; color: #dc3545;">유효한 매장 ID가 필요합니다.</p>';
        }

        // 웨이팅 상태 업데이트 함수 (백엔드 API 호출)
        async function updateWaitingStatus(waitingId, newStatus) {
            console.log("DEBUG: updateWaitingStatus 호출됨. received waitingId:", waitingId, "received newStatus:", newStatus);

            // WaitingOwnerController의 /waiting/owner/api/updateStatus (POST) API 호출
            // JSON body로 waitingId, status, storeId를 전달
            const url = "/waiting/owner/api/updateStatus"; // API URL

            console.log("DEBUG: API URL:", url);
            console.log("DEBUG: Payload: { waitingId:", waitingId, ", status:", newStatus, ", storeId:", storeId, "}");

            try {
                const response = await fetch(url, {
                    method: 'POST', // POST 메소드 사용
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ // JSON.stringify로 객체를 JSON 문자열로 변환
                        waitingId: parseInt(waitingId), // waitingId를 Long 타입으로 변환 (숫자형으로 전달)
                        status: newStatus,
                        storeId: storeId // storeId도 함께 전달
                    })
                });

                if (!response.ok) {
                    const errorData = await response.json(); // 에러 응답도 JSON으로 파싱 시도
                    throw new Error(`HTTP 오류: ${response.status} - ${errorData.error || '알 수 없는 서버 오류'}`);
                }

                // 성공 응답이 비어있을 수 있으므로 text() 대신 응답 상태만 확인
                console.log('웨이팅 상태 업데이트 성공 (백엔드 처리 완료)');
                alert(`웨이팅 ${waitingId}의 상태가 ${newStatus}로 변경되었습니다.`);
                // Firebase 리스너에 의해 자동으로 UI 갱신될 것임. (페이지 새로고침 불필요)
            } catch (error) {
                console.error('웨이팅 상태 업데이트 중 오류 발생:', error);
                alert('웨이팅 상태 업데이트 실패: ' + error.message);
            }
        }
    </script>
</body>
</html>