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

        const storeId = ${storeId};

		if (storeId) {
	        const waitingRef = database.ref('waitings/' + storeId);

	        waitingRef.on('value', (snapshot) => {
	            const data = snapshot.val();
	            const realtimeWaitingListDiv = document.getElementById('realtimeWaitingList');
	            realtimeWaitingListDiv.innerHTML = ''; // 기존 목록 초기화

	            console.log("DEBUG: Firebase fetched data:", data);

	            if (data) {
	                const sortedWaitings = Object.entries(data).sort(([, a], [, b]) => a.createdAt - b.createdAt);

	                console.log("DEBUG: Sorted waitings for rendering:", sortedWaitings);

	                sortedWaitings.forEach(([waitingId, waiting]) => {
	                    console.log("DEBUG: Processing waitingId for rendering:", waitingId, "with data:", waiting);
	                    const listItem = document.createElement('div');
	                    listItem.className = 'waiting-item';

	                    const formattedCreatedAt = new Date(waiting.createdAt).toLocaleString();

	                    let htmlContent = '';
	                    htmlContent += '<p><strong>웨이팅 ID:</strong> ' + waitingId + '</p>';
	                    htmlContent += '<p><strong>고객:</strong> ' + (waiting.memberId || '알 수 없음') + ' (인원: ' + waiting.guestCount + '명)</p>';
	                    htmlContent += '<p><strong>상태:</strong> <span class="status-' + waiting.status + '">' + waiting.status + '</span></p>';
	                    htmlContent += '<p><strong>등록 시간:</strong> ' + formattedCreatedAt + '</p>';
	                    htmlContent += '<div class="actions">';
	                    // --- 여기 버튼 onclick 속성의 상태 값들을 ENUM 정의와 일치시킵니다. ---
	                    // '입장 처리'를 'CALLED' 또는 'SEATED' 중 하나로 선택. 여기서는 'SEATED'를 사용.
	                    htmlContent += '    <button class="accepted" onclick="updateWaitingStatus(\'' + waitingId + '\', \'SEATED\')">입장 처리</button>';
	                    // '취소 처리'의 철자를 'CANCELLED' (L 두 개)로 수정.
	                    htmlContent += '    <button class="canceled" onclick="updateWaitingStatus(\'' + waitingId + '\', \'CANCELLED\')">취소 처리</button>';
	                    // '노쇼 처리'는 이미 일치하므로 변경 없음.
	                    htmlContent += '    <button class="no-show" onclick="updateWaitingStatus(\'' + waitingId + '\', \'NO_SHOW\')">노쇼 처리</button>';
	                    htmlContent += '</div>';

	                    console.log("DEBUG: Generated HTML for waitingId", waitingId, ":", htmlContent);
	                    listItem.innerHTML = htmlContent;

	                    realtimeWaitingListDiv.appendChild(listItem);
	                    console.log("DEBUG: Appended listItem for waitingId", waitingId);
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

		async function updateWaitingStatus(waitingId, newStatus) {
	        console.log("DEBUG: updateWaitingStatus 호출됨. received waitingId:", waitingId, "received newStatus:", newStatus);
	        
	        // **여기서 URL 구성 방식을 문자열 연결로 변경**
	        const url = "/waiting/customer/api/" + waitingId + "?status=" + newStatus; 
	        
	        console.log("DEBUG: Constructed URL:", url); // URL이 제대로 구성되었는지 확인하는 새로운 로그
	        console.log("DEBUG: Type of waitingId:", typeof waitingId, "Type of newStatus:", typeof newStatus); // 변수 타입 확인

	        try {
	            const response = await fetch(url, {
	                method: 'PUT',
	                headers: { 'Content-Type': 'application/json' },
	            });

	            if (!response.ok) {
	                const errorText = await response.text();
	                throw new Error(`HTTP 오류: ${response.status} - ${errorText}`);
	            }

	            console.log('웨이팅 상태 업데이트 성공 (백엔드 처리 완료)');
	            alert(`웨이팅 ${waitingId}의 상태가 ${newStatus}로 변경되었습니다.`);

	        } catch (error) {
	            console.error('웨이팅 상태 업데이트 중 오류 발생:', error);
	            alert('웨이팅 상태 업데이트 실패: ' + error.message);
	        }
	    }
    </script>
</body>
</html>