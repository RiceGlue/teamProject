<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> <%-- JSTL Core 태그 라이브러리 임포트 --%>
<html>
<head>
    <title>웨이팅 등록</title>
    <script src="https://www.gstatic.com/firebasejs/9.6.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.6.0/firebase-messaging-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.6.0/firebase-database-compat.js"></script>
    <style>
    	.content-wrapper {padding: 50px;}
        body { font-family: Arial, sans-serif;}
        label { display: block; margin-bottom: 5px; }
        input[type="number"], input[type="text"] { /* text 타입도 포함하도록 수정 */
            width: 200px;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        button {
            padding: 10px 15px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #0056b3;
        }
        #fcmStatus {
            margin-top: 15px;
            padding: 10px;
            background-color: #e6ffe6;
            border: 1px solid #aaddaa;
            border-radius: 4px;
            color: #006600;
        }
        #fcmError {
            margin-top: 15px;
            padding: 10px;
            background-color: #ffe6e6;
            border: 1px solid #ddaaaa;
            border-radius: 4px;
            color: #cc0000;
            display: none; /* 초기에는 숨김 */
        }
        /* 추가: 웨이팅 등록 실패 시 표시될 오류 메시지 스타일 */
        .registration-error-message {
            color: #d9534f; /* 진한 빨강 */
            background-color: #f2dede; /* 연한 빨강 배경 */
            border: 1px solid #ebccd1;
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
            text-align: center;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h2>웨이팅 등록</h2>

    <%-- 웨이팅 등록 실패 시 에러 메시지 표시 --%>
    <c:if test="${not empty error}">
        <div class="registration-error-message">
            <p>${error}</p>
        </div>
    </c:if>

    <form id="waitingForm" action="/waiting/customer/register" method="post">
        <input type="hidden" id="memberId" name="memberId" value=""/><br/>
        <input type="hidden" id="storeId" name="storeId" value="${storeId}" /><br/>

        <label for="guestCount">인원 수:</label>
        <input type="number" id="guestCount" name="guestCount" value="1" required /><br/>

        <input type="hidden" id="fcmToken" name="fcmToken" value="" />

        <button type="submit" id="submitButton" disabled>등록</button>
        <button type="button" onclick="location.href='/store/storeDetail?storeId=${storeId}'">목록으로</button>

    </form>
	<div style="display: none;">
	    <div id="fcmStatus">FCM 초기화 중...</div>
	    <div id="fcmError"></div>
	</div>
    <script>
        // 1. Firebase 프로젝트 설정 (실제 Firebase Console에서 가져온 값)
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

        // Firebase 초기화
        const app = firebase.initializeApp(firebaseConfig);
        const messaging = firebase.messaging(); // Firebase v9 호환 버전 사용
        const submitButton = document.getElementById('submitButton');
        const fcmTokenInput = document.getElementById('fcmToken');
        const fcmStatusDiv = document.getElementById('fcmStatus');
        const fcmErrorDiv = document.getElementById('fcmError');

        // 메시지 상태 업데이트 함수
        function updateStatus(message, isError = false) {
            if (isError) {
                fcmErrorDiv.innerText = message;
                fcmErrorDiv.style.display = 'block'; // 에러 메시지 표시
                fcmStatusDiv.style.display = 'none'; // 상태 메시지 숨김
                submitButton.disabled = true; // 에러 시 버튼 비활성화
            } else {
                fcmStatusDiv.innerText = message;
                fcmStatusDiv.style.display = 'block'; // 상태 메시지 표시
                fcmErrorDiv.style.display = 'none'; // 에러 메시지 숨김
                submitButton.disabled = false; // 성공 시 버튼 활성화
            }
        }

        // 2. 서비스 워커 등록
        // 서비스 워커 파일이 현재 JSP와 같은 웹 루트에 있다고 가정합니다.
        // 예를 들어, WebContent/js/firebase-messaging-sw.js 라면, /js/firebase-messaging-sw.js
        navigator.serviceWorker.register('/js/firebase-messaging-sw.js')
            .then((registration) => {
                updateStatus('Service Worker 등록 완료.');
                // ❗ 중요: messaging.useServiceWorker(registration)는 Firebase JS SDK v9+에서는 필요 없습니다.
                // getToken() 호출 시 serviceWorkerRegistration 속성을 통해 직접 전달됩니다.

                // 3. FCM 토큰 요청 및 가져오기 (registration 객체를 getToken의 serviceWorkerRegistration 속성으로 전달)
                // VAPID Key는 Firebase Console -> Project settings -> Cloud Messaging -> Web configuration에서 찾을 수 있습니다.
                messaging.getToken({ vapidKey: 'BKFJYBAC5SLYDQ6_uQIC1wUmaG5ICAOxa6vanaV84dGtP-DlP0emdmBvAh7xV2bxg31_ldVS9BzqeGeH6q2Llpk', serviceWorkerRegistration: registration })
                    .then((currentToken) => {
                        if (currentToken) {
                            updateStatus('FCM 토큰 발급 완료: ' + currentToken);
                            fcmTokenInput.value = currentToken; // 숨겨진 input에 토큰 설정
                            submitButton.disabled = false; // 👈 여기에서 버튼 활성화
                        } else {
                            // 토큰이 없다는 것은 보통 알림 권한이 없거나, 서비스 워커 문제일 수 있습니다.
                            updateStatus('FCM 토큰을 가져올 수 없습니다. 알림 권한이 필요합니다.', true);
                            requestNotificationPermission(); // 권한 요청
                        }
                    })
                    .catch((err) => {
                        updateStatus('FCM 토큰 가져오는 중 오류 발생: ' + err.message, true); // err.message로 더 명확한 메시지 표시
                        console.error('An error occurred while retrieving token. ', err);
                    });
            })
            .catch((err) => {
                updateStatus('서비스 워커 등록 실패: ' + err.message, true); // err.message로 더 명확한 메시지 표시
                console.error('Service Worker registration failed: ', err);
            });

        // 사용자가 알림 권한을 거부했을 경우 다시 요청하는 함수
        function requestNotificationPermission() {
            Notification.requestPermission().then((permission) => {
                if (permission === 'granted') {
                    updateStatus('알림 권한이 허용되었습니다. FCM 토큰을 다시 시도합니다.');
                    // 권한 부여 후 토큰 다시 요청 시에도 serviceWorkerRegistration를 포함해야 합니다.
                    // 현재 활성화된 서비스 워커가 있다면 그것을 사용합니다.
                    messaging.getToken({ vapidKey: 'BKFJYBAC5SLYDQ6_uQIC1wUmaG5ICAOxa6vanaV84dGtP-DlP0emdmBvAh7xV2bxg31_ldVS9BzqeGeH6q2Llpk',
                                         serviceWorkerRegistration: navigator.serviceWorker.controller || navigator.serviceWorker.active || navigator.serviceWorker.ready
                                       })
                        .then((currentToken) => {
                            if (currentToken) {
                                updateStatus('새로운 FCM 토큰 발급 완료: ' + currentToken);
                                fcmTokenInput.value = currentToken;
                            } else {
                                updateStatus('새로운 FCM 토큰을 가져올 수 없습니다. 다시 시도해주세요.', true);
                            }
                        })
                        .catch((err) => {
                            updateStatus('새로운 FCM 토큰 가져오는 중 오류 발생: ' + err.message, true);
                            console.error('Error getting new FCM token: ', err);
                        });
                } else {
                    updateStatus('알림 권한이 거부되었습니다. 푸시 알림을 받을 수 없습니다.', true);
                }
            });
        }

        // 선택 사항: 포그라운드(앱이 열려있는 상태) 메시지 수신 시 처리
        // 이 메시지는 서비스 워커가 아닌, 현재 페이지에서 직접 처리됩니다.
        messaging.onMessage((payload) => {
            console.log('포그라운드 메시지 수신: ', payload);
            // 알림 객체가 payload에 직접 포함되어 있는 경우
            const notificationTitle = payload.notification ? payload.notification.title : '새 알림';
            const notificationBody = payload.notification ? payload.notification.body : '내용 없음';
            const notificationOptions = {
                body: notificationBody,
                icon: '/images/firebase-logo.png' // 적절한 아이콘 경로로 변경 (예: /images/app-icon.png)
            };
            // Notification API를 사용하여 사용자에게 알림을 보여줍니다.
            if (Notification.permission === 'granted') {
                 new Notification(notificationTitle, notificationOptions);
            }
            updateStatus(`새로운 알림 수신: ${notificationTitle} - ${notificationBody}`);
        });
    </script>
</body>
</html>