<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>웨이팅 설정 목록 및 실시간 현황</title>
    <script src="https://www.gstatic.com/firebasejs/9.6.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.6.0/firebase-database-compat.js"></script>
    <style>
        /* 실시간 웨이팅 목록 스타일 */
        .waiting-item {
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .waiting-item p {
            margin: 5px 0;
        }
        .waiting-item button {
            margin-right: 8px;
            padding: 8px 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            transition: background-color 0.2s;
        }
        .waiting-item button.accepted {
            background-color: #28a745; /* Green */
            color: white;
        }
        .waiting-item button.canceled {
            background-color: #dc3545; /* Red */
            color: white;
        }
        .waiting-item button.no-show {
            background-color: #ffc107; /* Yellow */
            color: #333;
        }
        .waiting-item button:hover {
            opacity: 0.9;
        }

        /* 상태별 텍스트 색상 */
        .status-WAITING { color: #007bff; font-weight: bold; } /* Blue */
        .status-ACCEPTED { color: #28a745; font-weight: bold; } /* Green */
        .status-CANCELED { color: #dc3545; font-weight: bold; } /* Red */
        .status-NO_SHOW { color: #ffc107; font-weight: bold; } /* Orange */
    </style>
</head>
<body>
    <h1>매장 관리 대시보드</h1>

    <h2>웨이팅 설정 목록</h2>
    <a href="/waiting/owner/settings/addForm?storeId=${storeId}" style="display: inline-block; margin-bottom: 20px; padding: 10px 15px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px;">
        + 새 설정 추가
    </a>
    <table border="1" style="width: 100%; border-collapse: collapse; margin-bottom: 40px;">
        <thead>
            <tr style="background-color: #f2f2f2;">
                <th style="padding: 10px; text-align: left;">요일</th>
                <th style="padding: 10px; text-align: left;">시간</th>
                <th style="padding: 10px; text-align: left;">최대 팀 수</th>
                <th style="padding: 10px; text-align: left;">활성화 여부</th>
                <th style="padding: 10px; text-align: left;">액션</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="setting" items="${settings}">
                <tr>
                    <td style="padding: 10px;">
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
                    </td>
                    <td style="padding: 10px;">${setting.timeSlot}</td>
                    <td style="padding: 10px;">${setting.maxTeams}</td>
                    <td style="padding: 10px;">
                        <c:choose>
                            <c:when test="${setting.active}">사용</c:when>
                            <c:otherwise>중지</c:otherwise>
                        </c:choose>
                    </td>
                    <td style="padding: 10px;">
                        <a href="/waiting/owner/settings/editForm/${setting.settingId}?storeId=${storeId}" style="margin-right: 5px; text-decoration: none; color: #007bff;">수정</a> |
                        <a href="/waiting/owner/settings/delete/${setting.settingId}?storeId=${storeId}"
                           onclick="return confirm('정말로 삭제하시겠습니까?');" style="text-decoration: none; color: #dc3545;">삭제</a>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty settings}">
                <tr>
                    <td colspan="5" style="padding: 10px; text-align: center; color: #6c757d;">등록된 웨이팅 설정이 없습니다.</td>
                </tr>
            </c:if>
        </tbody>
    </table>

    <hr style="margin: 40px 0; border: 0; border-top: 1px solid #eee;" />

    <h2>실시간 웨이팅 현황</h2>
    <div id="realtimeWaitingList">
        <p>로딩 중 웨이팅 목록...</p>
    </div>

    <script>
        // --- Firebase 설정: YOUR_API_KEY, YOUR_PROJECT_ID 등을 실제 값으로 변경해야 합니다! ---
        const firebaseConfigExam = {
            apiKey: "YOUR_API_KEY_HERE",           // <-- 실제 API 키로 변경
            authDomain: "YOUR_PROJECT_ID_HERE.firebaseapp.com", // <-- 실제 프로젝트 ID로 변경
            databaseURL: "https://YOUR_PROJECT_ID_HERE.firebaseio.com", // <-- 실제 프로젝트 ID로 변경
            projectId: "YOUR_PROJECT_ID_HERE",     // <-- 실제 프로젝트 ID로 변경
            storageBucket: "YOUR_PROJECT_ID_HERE.appspot.com", // <-- 실제 프로젝트 ID로 변경
            messagingSenderId: "YOUR_MESSAGING_SENDER_ID_HERE", // <-- 실제 발신자 ID로 변경
            appId: "YOUR_APP_ID_HERE"              // <-- 실제 앱 ID로 변경
        };
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

        // JSP Model에서 전달받은 storeId 사용
        const storeId = ${storeId};

        if (storeId) {
            // 'waitings/{storeId}' 경로의 변경사항을 구독
            const waitingRef = database.ref('waitings/' + storeId);

            waitingRef.on('value', (snapshot) => {
                const data = snapshot.val();
                const realtimeWaitingListDiv = document.getElementById('realtimeWaitingList');
                realtimeWaitingListDiv.innerHTML = ''; // 기존 목록 초기화

                if (data) {
                    // 웨이팅 순서를 위해 createdAt 기준으로 정렬 (가장 오래된 웨이팅이 먼저 오도록)
                    const sortedWaitings = Object.entries(data).sort(([, a], [, b]) => a.createdAt - b.createdAt);

                    sortedWaitings.forEach(([waitingId, waiting]) => {
                        const listItem = document.createElement('div');
                        listItem.className = 'waiting-item';

                        // **수정된 부분: new Date() 사용을 JavaScript 블록으로 이동**
                        const formattedCreatedAt = new Date(waiting.createdAt).toLocaleString();

                        listItem.innerHTML = `
                            <p><strong>웨이팅 ID:</strong> ${waitingId}</p>
                            <p><strong>고객:</strong> ${waiting.memberId || '알 수 없음'} (인원: ${waiting.guestCount}명)</p>
                            <p><strong>상태:</strong> <span class="status-${waiting.status}">${waiting.status}</span></p>
                            <p><strong>등록 시간:</strong> ${formattedCreatedAt}</p> <div class="actions">
                                <button class="accepted" onclick="updateWaitingStatus('${waitingId}', 'ACCEPTED', ${storeId})">입장 처리</button>
                                <button class="canceled" onclick="updateWaitingStatus('${waitingId}', 'CANCELED', ${storeId})">취소 처리</button>
                                <button class="no-show" onclick="updateWaitingStatus('${waitingId}', 'NO_SHOW', ${storeId})">노쇼 처리</button>
                            </div>
                        `;
                        realtimeWaitingListDiv.appendChild(listItem);
                    });
                } else {
                    realtimeWaitingListDiv.innerHTML = '<p>현재 웨이팅이 없습니다.</p>';
                }
            }, (error) => {
                console.error("Firebase 데이터 읽기 실패:", error);
                realtimeWaitingListDiv.innerHTML = '<p>웨이팅 데이터를 불러오는 중 오류가 발생했습니다.</p>';
            });
        } else {
             document.getElementById('realtimeWaitingList').innerHTML = '<p>유효한 매장 ID가 필요합니다.</p>';
        }

        // 웨이팅 상태 업데이트 함수 (Firebase 및 백엔드 DB)
        async function updateWaitingStatus(waitingId, newStatus, storeId) {
            console.log(`웨이팅 ${waitingId}의 상태를 ${newStatus}로 변경 시도 (매장 ID: ${storeId})`);
            try {
                // 1. 백엔드 API 호출 (Spring Controller): DB 및 Firebase 동기화 담당
                const response = await fetch('/waiting/owner/api/updateStatus', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ waitingId: waitingId, status: newStatus, storeId: storeId })
                });

                if (!response.ok) {
                    const errorData = await response.json();
                    throw new Error(errorData.error || '상태 업데이트 실패');
                }

                const result = await response.json();
                console.log('상태 업데이트 성공:', result);
                // Firebase 리스너가 자동적으로 화면을 업데이트하므로 별도 DOM 조작은 필요 없습니다.
                alert(`웨이팅 ${waitingId}의 상태가 ${newStatus}로 변경되었습니다.`);

            } catch (error) {
                console.error('웨이팅 상태 업데이트 중 오류 발생:', error);
                alert('웨이팅 상태 업데이트 실패: ' + error.message);
            }
        }
    </script>
</body>
</html>