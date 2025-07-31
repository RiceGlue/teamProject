// firebase-messaging-sw.js
// Firebase SDK를 불러옵니다.

console.log('SW_DEBUG: firebase-messaging-sw.js 파일 로드 시작.');

importScripts('https://www.gstatic.com/firebasejs/9.6.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.0/firebase-messaging-compat.js');

console.log('SW_DEBUG: Firebase SDK 로드 완료.');

// Firebase 프로젝트 설정 (register.jsp와 동일하게 설정)
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

console.log('SW_DEBUG: Firebase 설정 완료.');

// Firebase 초기화
try {
    const app = firebase.initializeApp(firebaseConfig);
    const messaging = firebase.messaging();
    console.log('SW_DEBUG: Firebase 초기화 및 메시징 객체 생성 완료.');

    // 백그라운드 메시지 수신 시 처리
    messaging.onBackgroundMessage((payload) => {
		// onBackgroundMessage 리스너 내부에 추가해서 확인
		console.log('SW_DEBUG: Notification permission state:', Notification.permission);
        console.log('SW_DEBUG: [firebase-messaging-sw.js] Received background message ', payload);

        // payload 구조를 명확히 파악하기 위해 전체 payload 출력
        console.log('SW_DEBUG: Full payload received (JSON):', JSON.stringify(payload, null, 2));

        const notificationTitle = payload.notification && payload.notification.title ? payload.notification.title : '알림';
        const notificationBody = payload.notification && payload.notification.body ? payload.notification.body : '내용 없음';

        // icon 경로를 static 폴더 기준으로 정확히 지정해야 합니다.
        // 예를 들어, src/main/resources/static/images/my-icon.png 라면 /images/my-icon.png
        const notificationOptions = {
            body: notificationBody,
            //icon: '/images/test/Firebase_icon.svg' // ⭐⭐ 이 아이콘 경로가 실제 파일 경로와 일치하는지 확인하세요! ⭐⭐
        };

        console.log(`SW_DEBUG: 알림 표시 시도 - Title: "${notificationTitle}", Body: "${notificationBody}"`);
        self.registration.showNotification(notificationTitle, notificationOptions)
            .then(() => {
                console.log('SW_DEBUG: 알림 표시 성공.');
            })
            .catch(error => {
                console.error('SW_ERROR: 알림 표시 실패:', error);
            });
    });

    console.log('SW_DEBUG: onBackgroundMessage 리스너 등록 완료.');

} catch (e) {
    console.error('SW_ERROR: Firebase 초기화 또는 메시징 리스너 설정 중 오류 발생:', e);
}

// ⭐⭐⭐ 여기에 서비스 워커 생명주기 이벤트 로깅을 추가합니다. ⭐⭐⭐
self.addEventListener('install', (event) => {
  console.log('SW_DEBUG: Service Worker "install" 이벤트 발생.');
  self.skipWaiting(); // 새로운 서비스 워커가 즉시 활성화되도록
});

self.addEventListener('activate', (event) => {
  console.log('SW_DEBUG: Service Worker "activate" 이벤트 발생.');
  event.waitUntil(self.clients.claim()); // 서비스 워커가 즉시 페이지를 제어하도록
});

self.addEventListener('push', (event) => {
    console.log('SW_DEBUG: Service Worker "push" 이벤트 발생.');
    if (event.data) {
        console.log('SW_DEBUG: Push data (event.data.text()):', event.data.text());
        try {
            const data = event.data.json();
            console.log('SW_DEBUG: Push data (event.data.json()):', data);

            // ⭐⭐ 이 부분을 추가하여 onBackgroundMessage 대신 여기서 직접 알림을 띄웁니다. ⭐⭐
            const notificationTitle = data.notification && data.notification.title ? data.notification.title : '알림';
            const notificationBody = data.notification && data.notification.body ? data.notification.body : '내용 없음';

            const notificationOptions = {
                body: notificationBody,
                icon: '/images/test/Firebase_icon.svg' // 아이콘 경로 확인!
            };

            console.log(`SW_DEBUG: [Push Handler] 알림 표시 시도 - Title: "${notificationTitle}", Body: "${notificationBody}"`);
            event.waitUntil(
                self.registration.showNotification(notificationTitle, notificationOptions)
                    .then(() => {
                        console.log('SW_DEBUG: [Push Handler] 알림 표시 성공.');
                    })
                    .catch(error => {
                        console.error('SW_ERROR: [Push Handler] 알림 표시 실패:', error);
                    })
            );

        } catch (e) {
            console.error('SW_ERROR: Failed to parse push data as JSON:', e);
        }
    } else {
        console.log('SW_DEBUG: Push 이벤트에 데이터 없음.');
    }
});

// 알림 클릭 이벤트 (사용자가 알림을 클릭했을 때)
self.addEventListener('notificationclick', (event) => {
  console.log('SW_DEBUG: Notification click event:', event);
  event.notification.close(); // 알림 닫기

  // 클릭 시 이동할 URL (현재 도메인 내에서)
  const urlToOpen = 'http://localhost:8080/waiting/customer/register';
  event.waitUntil(
    clients.openWindow(urlToOpen)
  );
});