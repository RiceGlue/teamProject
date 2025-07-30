// firebase-messaging-sw.js
// Firebase SDK를 불러옵니다.

importScripts('https://www.gstatic.com/firebasejs/9.6.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.0/firebase-messaging-compat.js');

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

// Firebase 초기화
const app = firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

// 백그라운드 메시지 수신 시 처리
messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body
        //body: payload.notification.body,
        //icon: '/firebase-logo.png' // 알림 아이콘 경로 (선택 사항, src/main/resources/static/ 에 있어야 함)
    };

    // 알림 표시
    self.registration.showNotification(notificationTitle, notificationOptions);
});