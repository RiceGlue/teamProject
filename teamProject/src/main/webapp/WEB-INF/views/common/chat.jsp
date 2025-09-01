<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    /* --- 전체 채팅창 컨테이너 --- */
    .chat-container {
        position: fixed; 
        bottom: 20px;
        right: 20px;
        width: 320px;
        /* [삭제] 26차 수정: 그림자 효과를 제거하여 테두리 문제를 해결합니다. */
        /* box-shadow: 0 5px 15px rgba(0,0,0,0.2); */
        border-radius: 12px;
        overflow: hidden;
        display: flex;
        flex-direction: column;
        z-index: 1050;
    }

    /* --- 채팅창 헤더 스타일 --- */
    .chat-header {
        background-color: #7B2D26;
        color: white;
        padding: 0.8rem 1rem;
        text-align: center;
        font-weight: bold;
        cursor: pointer;
        display: flex;
        justify-content: space-between;
        align-items: center;
        transition: all 0.2s ease-in-out;
    }
    
    .chat-header:hover {
        background-color: #6a2520;
    }

    .chat-header h2 {
        font-size: 1rem;
        margin: 0;
    }

    .chat-toggle-icon {
        font-size: 1.2rem;
        font-weight: bold;
    }

    /* --- 채팅창 본문 및 푸터 (기본 숨김) --- */
    .chat-content {
        background-color: white;
        display: flex;
        flex-direction: column;
        transition: all 0.3s ease-out;
        visibility: hidden;
        opacity: 0;
        max-height: 0;
    }

    /* 채팅창이 열렸을 때의 스타일 */
    .chat-container.open .chat-content {
        visibility: visible;
        opacity: 1;
        max-height: 400px;
    }

    .chat-body {
        flex-grow: 1;
        padding: 1rem; 
        overflow-y: auto;
        background-color: #f9f9f9;
        color: #333;
        display: flex;
        flex-direction: column;
    }

    /* 채팅 메시지 예시 스타일 */
    .chat-message {
        margin-bottom: 0.75rem;
        padding: 0.5rem 1rem;
        border-radius: 12px;
        max-width: 80%;
    }
    .chat-message.received {
        background-color: #e9e9eb;
        align-self: flex-start;
    }
    .chat-message.sent {
        background-color: #dcf8c6;
        align-self: flex-end;
    }

    .chat-footer {
        padding: 0.5rem;
        display: flex;
        align-items: center; /* [추가] 27차 수정: 세로 중앙 정렬 */
        background-color: #fff;
    }

    .chat-container.open .chat-footer {
        border-top: 1px solid #ddd;
    }

    .chat-footer input {
        flex-grow: 1;
        border: 1px solid #ccc;
        border-radius: 20px;
        padding: 0.5rem 1rem;
        margin-right: 0.5rem;
    }

    .chat-footer button {
        border: none;
        background-color: #7B2D26;
        color: white;
        border-radius: 50%;
        width: 40px;
        height: 40px;
        cursor: pointer;
        flex-shrink: 0; /* [추가] 27차 수정: 버튼이 찌그러지지 않도록 설정 */
    }
</style>

<div id="chatWidget" class="chat-container">
    <div class="chat-header">
        <h2>실시간 문의</h2>
        <span class="chat-toggle-icon">▲</span>
    </div>
    <div class="chat-content">
        <div class="chat-body">
            <div class="chat-message received">안녕하세요! 무엇을 도와드릴까요?</div>
            <div class="chat-message sent">예약 관련 문의하고 싶어요.</div>
        </div>
        <div class="chat-footer">
            <input type="text" placeholder="메시지를 입력하세요...">
            <button>&#10148;</button>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const chatWidget = document.getElementById('chatWidget');
        const chatHeader = chatWidget.querySelector('.chat-header');
        const toggleIcon = chatWidget.querySelector('.chat-toggle-icon');

        chatHeader.addEventListener('click', function () {
            chatWidget.classList.toggle('open');
            
            if (chatWidget.classList.contains('open')) {
                toggleIcon.textContent = '▼';
            } else {
                toggleIcon.textContent = '▲';
            }
        });
    });
</script>

