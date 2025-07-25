<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>웨이팅 등록</title>
    <script src="https://www.gstatic.com/firebasejs/9.1.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.1.0/firebase-messaging-compat.js"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        label { display: block; margin-bottom: 5px; }
        input[type="number"] { width: 200px; padding: 8px; margin-bottom: 10px; border: 1px solid #ddd; border-radius: 4px; }
        button { padding: 10px 15px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; }
        button:hover { background-color: #0056b3; }
        #fcmStatus { margin-top: 15px; padding: 10px; background-color: #e6ffe6; border: 1px solid #aaddaa; border-radius: 4px; color: #006600;}
        #fcmError { margin-top: 15px; padding: 10px; background-color: #ffe6e6; border: 1px solid #ddaaaa; border-radius: 4px; color: #cc0000;}
    </style>
</head>
<body>
    <h2>웨이팅 등록</h2>
    <form action="/waiting/customer/register" method="post">
        <label for="memberId">회원 ID:</label>
        <input type="number" id="memberId" name="memberId" value="101" required /><br/>

        <label for="storeId">매장 ID:</label>
        <input type="number" id="storeId" name="storeId" value="1" required /><br/>

        <label for="guestCount">인원 수:</label>
        <input type="number" id="guestCount" name="guestCount" value="2" required /><br/>

        <input type="hidden" id="fcmToken" name="fcmToken" value="" />

        <button type="submit">등록</button>
    </form>

    <div id="fcmStatus">FCM 초기화 중...</div>
    <div id="fcmError"></div>

    <script>
        // 1. Firebase 프로젝트 설정 (실제 Firebase Console에서 가져온 값으로 변경해야 합니다)
        const firebaseConfigExam = {
            apiKey: "YOUR_API_KEY",
            authDomain: "YOUR_AUTH_DOMAIN",
            projectId: "YOUR_PROJECT_ID", // YOUR_PROJECT_ID를 실제 프로젝트 ID로 변경
            storageBucket: "YOUR_STORAGE_BUCKET",
            messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
            appId: "YOUR_APP_ID"
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
		
        // Firebase 초기화
        const app = firebase.initializeApp(firebaseConfig);
        const messaging = firebase.messaging(); // Firebase v9 호환 버전 사용

        const fcmTokenInput = document.getElementById('fcmToken');
        const fcmStatusDiv = document.getElementById('fcmStatus');
        const fcmErrorDiv = document.getElementById('fcmError');

        // 메시지 상태 업데이트 함수
        function updateStatus(message, isError = false) {
            if (isError) {
                fcmErrorDiv.innerText = message;
                fcmErrorDiv.style.display = 'block';
                fcmStatusDiv.style.display = 'none';
            } else {
                fcmStatusDiv.innerText = message;
                fcmStatusDiv.style.display = 'block';
                fcmErrorDiv.style.display = 'none';
            }
        }

        // 2. 서비스 워커 등록 (경로 변경: /js/firebase-messaging-sw.js)
        navigator.serviceWorker.register('/js/firebase-messaging-sw.js')
            .then((registration) => {
                updateStatus('Service Worker 등록 완료.');
                // *** 여기를 수정합니다. useServiceWorker() 호출을 제거합니다. ***
                // messaging.useServiceWorker(registration); // 이 줄을 제거하세요.

                // 3. FCM 토큰 요청 및 가져오기 (registration 객체를 getToken의 serviceWorkerRegistration 속성으로 전달)
                messaging.getToken({ vapidKey: 'BKFJYBAC5SLYDQ6_uQIC1wUmaG5ICAOxa6vanaV84dGtP-DlP0emdmBvAh7xV2bxg31_ldVS9BzqeGeH6q2Llpk', serviceWorkerRegistration: registration })
                    .then((currentToken) => {
                        if (currentToken) {
                            updateStatus('FCM 토큰 발급 완료: ' + currentToken);
                            fcmTokenInput.value = currentToken; // 숨겨진 input에 토큰 설정
                        } else {
                            updateStatus('FCM 토큰을 가져올 수 없습니다. 알림 권한이 필요합니다.', true);
                            requestNotificationPermission(); // 권한 요청
                        }
                    })
                    .catch((err) => {
                        updateStatus('FCM 토큰 가져오는 중 오류 발생: ' + err, true);
                        console.error('An error occurred while retrieving token. ', err);
                    });
            })
            .catch((err) => {
                updateStatus('서비스 워커 등록 실패: ' + err, true);
                console.error('Service Worker registration failed: ', err);
            });

        // 사용자가 알림 권한을 거부했을 경우 다시 요청하는 함수
        function requestNotificationPermission() {
            Notification.requestPermission().then((permission) => {
                if (permission === 'granted') {
                    updateStatus('알림 권한이 허용되었습니다. FCM 토큰을 다시 시도합니다.');
                    // 권한 부여 후 토큰 다시 요청 시에도 serviceWorkerRegistration를 포함해야 합니다.
                    messaging.getToken({ vapidKey: 'BKFJYBAC5SLYDQ6_uQIC1wUmaG5ICAOxa6vanaV84dGtP-DlP0emdmBvAh7xV2bxg31_ldVS9BzqeGeH6q2Llpk', serviceWorkerRegistration: navigator.serviceWorker.controller ? navigator.serviceWorker.controller.waiting : navigator.serviceWorker.active })
                        .then((currentToken) => {
                            if (currentToken) {
                                updateStatus('새로운 FCM 토큰 발급 완료: ' + currentToken);
                                fcmTokenInput.value = currentToken;
                            }
                        })
                        .catch((err) => {
                            updateStatus('새로운 FCM 토큰 가져오는 중 오류 발생: ' + err, true);
                            console.error('Error getting new FCM token: ', err);
                        });
                } else {
                    updateStatus('알림 권한이 거부되었습니다. 푸시 알림을 받을 수 없습니다.', true);
                }
            });
        }

        // 선택 사항: 포그라운드(앱이 열려있는 상태) 메시지 수신 시 처리
        messaging.onMessage((payload) => {
            console.log('포그라운드 메시지 수신: ', payload);
            const notificationTitle = payload.notification.title;
            const notificationOptions = {
                body: payload.notification.body,
                icon: '/firebase-logo.png' // 선택 사항: 알림 아이콘
            };
            new Notification(notificationTitle, notificationOptions);
            updateStatus(`새로운 알림 수신: ${notificationTitle} - ${payload.notification.body}`);
        });
    </script>
</body>
</html>