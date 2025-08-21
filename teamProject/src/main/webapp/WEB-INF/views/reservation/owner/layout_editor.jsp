<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>매장 좌석 배치도 관리 시스템</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Noto Sans KR', sans-serif;
        }
        .grid-cell {
            width: 20px;
            height: 20px;
            border: 1px solid #e2e8f0;
            background-color: #f8fafc;
            transition: background-color 0.1s;
        }
        /* 개체별 스타일 */
        .grid-cell.table-part { background-color: #a16207; border-color: #854d0e; } /* 나무색 */
        .grid-cell.wall-part { background-color: #475569; border-color: #334155; } /* 진한 회색 */
        .grid-cell.glass-part { background-color: #a5f3fc; border-color: #22d3ee; opacity: 0.8; } /* 밝은 하늘색 */

        .grid-cell.table-part.editable:hover,
        .grid-cell.wall-part.editable:hover,
        .grid-cell.glass-part.editable:hover {
             cursor: grab;
        }
        .grid-cell.selected-object-part {
            background-color: #fbbf24;
            border-color: #f59e0b;
        }
        /* 활성화된 셀 (생성 미리보기) 스타일 변경 */
        .grid-cell.active {
            background-color: rgba(59, 130, 246, 0.6); /* 반투명 파랑 */
            border-color: #2563eb;
            opacity: 1; /* 다른 개체의 투명도에 영향받지 않도록 */
        }
        #grid-container::-webkit-scrollbar { width: 8px; height: 8px; }
        #grid-container::-webkit-scrollbar-track { background: #f1f1f1; }
        #grid-container::-webkit-scrollbar-thumb { background: #a8a8a8; border-radius: 4px; }
        #grid-container::-webkit-scrollbar-thumb:hover { background: #555; }
        
        .mode-button.active, .palette-button.active {
            background-color: #3b82f6;
            color: white;
            box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
        }
        .mode-button:not(.active), .palette-button:not(.active) {
            background-color: #e2e8f0;
            color: #334155;
        }
    </style>
</head>
<body class="bg-slate-100 text-slate-800 flex h-screen overflow-hidden">

    <!-- 메인 그리드 영역 -->
    <main class="flex-1 flex flex-col p-4">
        <h1 class="text-2xl font-bold mb-4">매장 레이아웃</h1>
        <div id="grid-container" class="flex-1 bg-white rounded-lg shadow-md overflow-auto border border-slate-200">
            <div id="grid" class="relative"></div>
        </div>
    </main>

    <!-- 컨트롤 패널 -->
    <aside class="w-96 bg-white p-6 shadow-lg overflow-y-auto">
        <div class="space-y-6">
            <!-- 층 관리 -->
            <div>
                <h2 class="text-lg font-bold border-b pb-2 mb-3">층 관리</h2>
                <div class="space-y-2">
                    <label for="floor-selector" class="block text-sm font-medium text-slate-700">현재 층</label>
                    <select id="floor-selector" class="w-full p-2 border rounded-md"></select>
                    <div class="grid grid-cols-2 gap-2 pt-2">
                        <button id="rename-floor" class="bg-amber-500 text-white py-2 px-4 rounded-md hover:bg-amber-600">이름 변경</button>
                        <button id="delete-floor" class="bg-red-600 text-white py-2 px-4 rounded-md hover:bg-red-700">층 삭제</button>
                    </div>
                    <div class="flex space-x-2 pt-2">
                        <input type="text" id="new-floor-name" placeholder="새 층 이름" class="w-full p-2 border rounded-md">
                        <button id="add-floor" class="bg-slate-700 text-white py-2 px-4 rounded-md hover:bg-slate-800 whitespace-nowrap">층 추가</button>
                    </div>
                </div>
            </div>

            <!-- 레이아웃 설정 -->
            <div>
                <h2 class="text-lg font-bold border-b pb-2 mb-3">레이아웃 설정</h2>
                <div class="space-y-2">
                    <div class="flex items-center space-x-2"><label for="grid-rows" class="w-12">세로:</label><input type="number" id="grid-rows" class="w-full p-2 border rounded-md"></div>
                    <div class="flex items-center space-x-2"><label for="grid-cols" class="w-12">가로:</label><input type="number" id="grid-cols" class="w-full p-2 border rounded-md"></div>
                    <button id="resize-grid" class="w-full bg-slate-700 text-white py-2 rounded-md hover:bg-slate-800">크기 적용</button>
                </div>
            </div>

            <!-- 개체 관리 -->
            <div id="edit-panel">
                <h2 class="text-lg font-bold border-b pb-2 mb-3">개체 관리</h2>
                <div class="flex flex-col space-y-2 mb-4">
                    <button id="mode-create" class="mode-button w-full py-2 px-4 rounded-md">생성 모드</button>
                    <button id="mode-edit" class="mode-button w-full py-2 px-4 rounded-md">편집 모드</button>
                </div>
                <!-- 생성 팔레트 -->
                <div id="create-palette" class="hidden grid grid-cols-3 gap-2 mb-4">
                    <button data-type="table" class="palette-button py-2 rounded-md">테이블</button>
                    <button data-type="wall" class="palette-button py-2 rounded-md">벽</button>
                    <button data-type="glass" class="palette-button py-2 rounded-md">유리</button>
                </div>
                <div id="create-form" class="hidden space-y-3 bg-slate-50 p-4 rounded-lg"></div>
                <div id="update-form" class="hidden space-y-3 bg-amber-50 p-4 rounded-lg"></div>
                <p id="info-text" class="text-sm text-slate-500 mt-4 text-center"></p>
            </div>
        </div>
    </aside>

    <!-- 맞춤형 Modal -->
    <div id="modal-backdrop" class="fixed inset-0 bg-black bg-opacity-50 hidden flex items-center justify-center z-50"></div>

    <script>
        // --- 전역 변수 및 상태 관리 ---
        const gridElement = document.getElementById('grid');
        const rowsInput = document.getElementById('grid-rows');
        const colsInput = document.getElementById('grid-cols');
        const createForm = document.getElementById('create-form');
        const updateForm = document.getElementById('update-form');
        const infoText = document.getElementById('info-text');
        const modeCreateBtn = document.getElementById('mode-create');
        const modeEditBtn = document.getElementById('mode-edit');
        const floorSelector = document.getElementById('floor-selector');
        const createPalette = document.getElementById('create-palette');
        
        let floors = { '1층': { objects: [], rows: 30, cols: 30 } };
        let currentFloor = '1층';

        let activeCells = new Set();
        let previewCells = new Set(); // 드래그 중인 셀을 임시 저장
        let selectedObjectId = null;
        let currentMode = 'create';
        let currentObjectType = 'table';

        // 마우스 인터랙션 상태
        let isDrawing = false;
        let drawMode = 'add'; // 'add' or 'remove'
        let isDragging = false;
        let mouseMoved = false;
        let mousedownTarget = null;
        let drawStartCell = { row: null, col: null };
        let draggedObject = null;
        let originalObjectCells = [];

        // --- 유틸리티 함수 ---
        const getCellId = (row, col) => `${row}-${col}`;
        const parseCellId = (id) => id.split('-').map(Number);

        // --- 그리드 및 개체 렌더링 ---
        function createGrid() {
            const floorData = floors[currentFloor];
            gridElement.innerHTML = '';
            gridElement.style.width = `${floorData.cols * 20}px`;
            gridElement.style.height = `${floorData.rows * 20}px`;
            gridElement.style.display = 'grid';
            gridElement.style.gridTemplateColumns = `repeat(${floorData.cols}, 20px)`;
            gridElement.style.gridTemplateRows = `repeat(${floorData.rows}, 20px)`;

            for (let i = 0; i < floorData.rows; i++) {
                for (let j = 0; j < floorData.cols; j++) {
                    const cell = document.createElement('div');
                    cell.className = 'grid-cell';
                    cell.id = getCellId(i, j);
                    cell.dataset.row = i;
                    cell.dataset.col = j;
                    gridElement.appendChild(cell);
                }
            }
            renderAllObjects();
        }
        
        function renderAllObjects() {
            document.querySelectorAll('.grid-cell').forEach(c => {
                c.className = 'grid-cell';
                delete c.dataset.objectId;
            });
            
            const sortedObjects = [...floors[currentFloor].objects].sort((a, b) => {
                const order = { 'wall': 1, 'glass': 2, 'table': 3 };
                return (order[a.type] || 0) - (order[b.type] || 0);
            });

            sortedObjects.forEach(obj => {
                obj.cells.forEach(cellPos => {
                    const cellElement = document.getElementById(getCellId(cellPos.row, cellPos.col));
                    if (cellElement) {
                        cellElement.classList.remove('wall-part', 'glass-part', 'table-part');
                        cellElement.classList.add(`${obj.type}-part`);
                        if (currentMode === 'edit') cellElement.classList.add('editable');
                        cellElement.dataset.objectId = obj.id;
                        if (obj.id === selectedObjectId) {
                            cellElement.classList.add('selected-object-part');
                        }
                    }
                });
            });

            const cellsToRenderAsActive = new Set(activeCells);
            if (isDrawing && mouseMoved) {
                if (drawMode === 'add') {
                    previewCells.forEach(cellId => cellsToRenderAsActive.add(cellId));
                } else { // 'remove'
                    previewCells.forEach(cellId => cellsToRenderAsActive.delete(cellId));
                }
            }
            
            cellsToRenderAsActive.forEach(cellId => {
                document.getElementById(cellId)?.classList.add('active');
            });
        }

        // --- UI 업데이트 ---
        function updateControlPanel() {
            infoText.classList.add('hidden');
            createForm.classList.add('hidden');
            updateForm.classList.add('hidden');

            if (currentMode === 'create') {
                const currentActiveCellCount = activeCells.size;
                if (currentActiveCellCount > 0) {
                    createForm.classList.remove('hidden');
                    if (currentObjectType === 'table') {
                        createForm.innerHTML = `<h3 class="font-semibold text-md">새 테이블 정보</h3><div><label class="block text-sm font-medium">이름</label><input type="text" id="obj-name" placeholder="예: 창가 4인석" class="mt-1 w-full p-2 border rounded-md"></div><div><label class="block text-sm font-medium">수용 인원</label><input type="number" id="obj-capacity" placeholder="예: 4" class="mt-1 w-full p-2 border rounded-md"></div><div class="flex space-x-2"><button id="save-object" class="flex-1 bg-blue-600 text-white py-2 rounded-md">저장</button><button id="clear-selection" class="flex-1 bg-slate-200 py-2 rounded-md">취소</button></div>`;
                    } else {
                        const typeName = currentObjectType === 'wall' ? '벽' : '유리';
                        createForm.innerHTML = `<h3 class="font-semibold text-md">새 ${typeName} 저장</h3><p class="text-sm text-slate-600">${currentActiveCellCount}개의 셀이 선택되었습니다.</p><div class="flex space-x-2"><button id="save-object" class="flex-1 bg-blue-600 text-white py-2 rounded-md">저장</button><button id="clear-selection" class="flex-1 bg-slate-200 py-2 rounded-md">취소</button></div>`;
                    }
                    document.getElementById('save-object').onclick = handleSaveObject;
                    document.getElementById('clear-selection').onclick = handleClearSelection;
                } else {
                    infoText.classList.remove('hidden');
                    infoText.textContent = '클릭 또는 드래그하여 개체를 생성하세요.';
                }
            } else { // 'edit' mode
                if (selectedObjectId) {
                    updateForm.classList.remove('hidden');
                    const obj = floors[currentFloor].objects.find(o => o.id === selectedObjectId);
                    if (obj.type === 'table') {
                        updateForm.innerHTML = `<h3 class="font-semibold text-md">테이블 정보 수정</h3><div><label class="block text-sm font-medium">이름</label><input type="text" id="update-obj-name" value="${obj.name}" class="mt-1 w-full p-2 border rounded-md"></div><div><label class="block text-sm font-medium">수용 인원</label><input type="number" id="update-obj-capacity" value="${obj.capacity}" class="mt-1 w-full p-2 border rounded-md"></div><div class="flex space-x-2"><button id="update-object" class="flex-1 bg-amber-500 text-white py-2 rounded-md">수정</button><button id="delete-object" class="flex-1 bg-red-600 text-white py-2 rounded-md">삭제</button></div><button id="deselect-object" class="w-full bg-slate-200 py-2 rounded-md mt-2">선택 해제</button>`;
                        document.getElementById('update-object').onclick = handleUpdateObject;
                    } else {
                        const typeName = obj.type === 'wall' ? '벽' : '유리';
                        updateForm.innerHTML = `<h3 class="font-semibold text-md">${typeName} 편집</h3><p class="text-sm text-slate-600">선택된 개체를 삭제할 수 있습니다.</p><button id="delete-object" class="w-full bg-red-600 text-white py-2 rounded-md">삭제</button><button id="deselect-object" class="w-full bg-slate-200 py-2 rounded-md mt-2">선택 해제</button>`;
                    }
                    document.getElementById('delete-object').onclick = handleDeleteObject;
                    document.getElementById('deselect-object').onclick = () => selectObject(null);
                } else {
                    infoText.classList.remove('hidden');
                    infoText.textContent = '개체를 선택하여 이동, 수정 또는 삭제하세요.';
                }
            }
        }

        function updateModeUI() {
            modeCreateBtn.classList.toggle('active', currentMode === 'create');
            modeEditBtn.classList.toggle('active', currentMode !== 'create');
            createPalette.classList.toggle('hidden', currentMode !== 'create');
            gridElement.style.cursor = currentMode === 'create' ? 'crosshair' : 'default';
            handleClearSelection();
            selectObject(null);
        }

        // --- 층 관리 로직 ---
        function renderFloorSelector() {
            floorSelector.innerHTML = '';
            Object.keys(floors).forEach(name => {
                const option = document.createElement('option');
                option.value = name; option.textContent = name;
                if (name === currentFloor) option.selected = true;
                floorSelector.appendChild(option);
            });
        }

        function handleSwitchFloor() {
            currentFloor = floorSelector.value;
            const floorData = floors[currentFloor];
            rowsInput.value = floorData.rows;
            colsInput.value = floorData.cols;
            handleClearSelection();
            selectObject(null);
            createGrid();
        }
        
        // --- 저장 로직 ---
        function handleSaveObject() {
            if (activeCells.size === 0) { customAlert('그리드에 개체 모양을 먼저 그리세요.'); return; }

            const currentObjects = floors[currentFloor].objects;
            const newCells = Array.from(activeCells).map(id => ({ row: parseCellId(id)[0], col: parseCellId(id)[1] }));

            if (currentObjectType === 'table') {
                const name = document.getElementById('obj-name').value;
                const capacity = document.getElementById('obj-capacity').value;
                if (!name || !capacity) { customAlert('테이블 이름과 수용 인원을 입력하세요.'); return; }
                if (currentObjects.some(obj => obj.cells.some(c1 => newCells.some(c2 => c1.row === c2.row && c1.col === c2.col)))) {
                    customAlert('기존 개체와 겹치는 위치에는 생성할 수 없습니다.'); return;
                }
                currentObjects.push({ id: Date.now(), type: 'table', name, capacity: parseInt(capacity), cells: newCells });
            } else if (currentObjectType === 'glass') {
                if (currentObjects.filter(o => o.type === 'table').some(obj => obj.cells.some(c1 => newCells.some(c2 => c1.row === c2.row && c1.col === c2.col)))) {
                    customAlert('유리는 테이블과 겹칠 수 없습니다.'); return;
                }
                currentObjects.push({ id: Date.now(), type: 'glass', cells: newCells });
            } else if (currentObjectType === 'wall') {
                if (currentObjects.filter(o => o.type !== 'wall').some(obj => obj.cells.some(c1 => newCells.some(c2 => c1.row === c2.row && c1.col === c2.col)))) {
                    customAlert('벽은 테이블이나 유리와 겹칠 수 없습니다.'); return;
                }
                const intersectingWalls = currentObjects.filter(obj => obj.type === 'wall' && obj.cells.some(c1 => newCells.some(c2 => c1.row === c2.row && c1.col === c2.col)));
                const allWallCells = new Set(activeCells);
                intersectingWalls.forEach(wall => wall.cells.forEach(cell => allWallCells.add(getCellId(cell.row, cell.col))));
                floors[currentFloor].objects = currentObjects.filter(obj => !intersectingWalls.includes(obj));
                floors[currentFloor].objects.push({ id: Date.now(), type: 'wall', cells: Array.from(allWallCells).map(id => ({ row: parseCellId(id)[0], col: parseCellId(id)[1] })) });
            }
            handleClearSelection();
        }
        
        function handleClearSelection() {
            activeCells.clear();
            previewCells.clear();
            renderAllObjects();
            updateControlPanel();
        }

        function selectObject(objectId) {
            selectedObjectId = objectId;
            renderAllObjects();
            updateControlPanel();
        }
        
        function handleUpdateObject() {
            if (!selectedObjectId) return;
            const obj = floors[currentFloor].objects.find(o => o.id === selectedObjectId);
            if (obj.type === 'table') {
                const name = document.getElementById('update-obj-name').value;
                const capacity = document.getElementById('update-obj-capacity').value;
                if (!name || !capacity) { customAlert('모든 정보를 입력하세요.'); return; }
                obj.name = name;
                obj.capacity = parseInt(capacity);
                customAlert('테이블 정보가 수정되었습니다.');
            }
        }

        function handleDeleteObject() {
            if (!selectedObjectId) return;
            customConfirm('정말로 이 개체를 삭제하시겠습니까?', () => {
                floors[currentFloor].objects = floors[currentFloor].objects.filter(o => o.id !== selectedObjectId);
                selectObject(null);
            });
        }
        
        // --- 마우스 인터랙션 핸들러 ---
        function handleGridMouseDown(e) {
            if (!e.target.classList.contains('grid-cell')) return;
            e.preventDefault();
            
            mousedownTarget = e.target;
            mouseMoved = false;

            if (currentMode === 'create') {
                isDrawing = true;
                const { row, col } = e.target.dataset;
                drawStartCell = { row: parseInt(row), col: parseInt(col) };
                drawMode = activeCells.has(e.target.id) ? 'remove' : 'add';
            } else { // edit mode
                const objectId = parseInt(e.target.dataset.objectId);
                if (objectId) {
                    draggedObject = floors[currentFloor].objects.find(o => o.id === objectId);
                    if (!draggedObject) return;
                    originalObjectCells = JSON.parse(JSON.stringify(draggedObject.cells));
                    const { row, col } = e.target.dataset;
                    drawStartCell = { row: parseInt(row), col: parseInt(col) };
                }
            }
        }

        function handleGridMouseMove(e) {
            const currentCell = e.target;
            if (!currentCell.classList.contains('grid-cell') || !mousedownTarget) return;
            
            mouseMoved = true;

            if (isDrawing) {
                previewCells.clear();
                const { row: currentRow, col: currentCol } = currentCell.dataset;
                const { row: startRow, col: startCol } = drawStartCell;
                const minRow = Math.min(startRow, currentRow);
                const maxRow = Math.max(startRow, currentRow);
                const minCol = Math.min(startCol, currentCol);
                const maxCol = Math.max(startCol, currentCol);

                for (let r = minRow; r <= maxRow; r++) {
                    for (let c = minCol; c <= maxCol; c++) {
                        previewCells.add(getCellId(r, c));
                    }
                }
                renderAllObjects();
            } else if (draggedObject) {
                isDragging = true;
                const { row: currentRow, col: currentCol } = currentCell.dataset;
                const { row: startRow, col: startCol } = drawStartCell;
                const deltaRow = parseInt(currentRow) - startRow;
                const deltaCol = parseInt(currentCol) - startCol;
                draggedObject.cells = originalObjectCells.map(cell => ({ row: cell.row + deltaRow, col: cell.col + deltaCol }));
                renderAllObjects();
            }
        }

        function handleDocumentMouseUp(e) {
            // BUG FIX: 마우스 다운이 그리드에서 시작되지 않았다면 아무것도 하지 않음
            if (!mousedownTarget) {
                return;
            }

            if (isDrawing) {
                if (!mouseMoved) { // 클릭 액션
                    const cell = mousedownTarget;
                    const cellId = cell.id;
                    const existingObjectId = cell.dataset.objectId;
                    if (existingObjectId) {
                        const existingObject = floors[currentFloor].objects.find(o => o.id == existingObjectId);
                        if (existingObject && existingObject.type === 'table') return;
                        if (existingObject && currentObjectType === 'wall' && existingObject.type !== 'wall') return;
                    }
                    if (activeCells.has(cellId)) {
                        activeCells.delete(cellId);
                    } else {
                        activeCells.add(cellId);
                    }
                } else { // 드래그 액션 종료
                    if (drawMode === 'add') {
                        previewCells.forEach(cellId => activeCells.add(cellId));
                    } else { // 'remove'
                        previewCells.forEach(cellId => activeCells.delete(cellId));
                    }
                }
                previewCells.clear();
                renderAllObjects();
            } else if (isDragging) { // 드래그 이동 종료
                const { rows, cols, objects } = floors[currentFloor];
                let collision = false;
                for (const cell of draggedObject.cells) {
                    let forbiddenTypes = [];
                    if (draggedObject.type === 'table') forbiddenTypes = ['table', 'wall', 'glass'];
                    else if (draggedObject.type === 'wall') forbiddenTypes = ['table', 'glass'];
                    else if (draggedObject.type === 'glass') forbiddenTypes = ['table'];

                    if (cell.row < 0 || cell.row >= rows || cell.col < 0 || cell.col >= cols || 
                        objects.filter(o => o.id !== draggedObject.id && forbiddenTypes.includes(o.type))
                               .some(other => other.cells.some(c => c.row === cell.row && c.col === cell.col))) {
                        collision = true; break;
                    }
                }
                if (collision) {
                    customAlert('다른 개체와 겹치거나 범위를 벗어날 수 없습니다.');
                    draggedObject.cells = originalObjectCells;
                    renderAllObjects();
                }
            } else if (!mouseMoved && mousedownTarget && currentMode === 'edit') { // 클릭으로 개체 선택
                const objectId = mousedownTarget.dataset.objectId;
                selectObject(objectId ? parseInt(objectId) : null);
            }

            // 모든 인터랙션 상태 초기화
            isDrawing = false;
            isDragging = false;
            mouseMoved = false;
            mousedownTarget = null;
            draggedObject = null;
            updateControlPanel();
        }

        // --- 맞춤형 Modal 함수들 ---
        const modalBackdrop = document.getElementById('modal-backdrop');
        function showModal(title, message, buttons) {
            modalBackdrop.innerHTML = `<div class="bg-white rounded-lg shadow-xl p-6 w-full max-w-sm"><h3 class="text-lg font-bold mb-4">${title}</h3><div class="text-slate-600 mb-6">${message}</div><div class="flex justify-end space-x-3">${buttons.map(btn => `<button class="${btn.classes}" onclick="${btn.onClick}">${btn.text}</button>`).join('')}</div></div>`;
            modalBackdrop.classList.remove('hidden');
        }
        function hideModal() { modalBackdrop.classList.add('hidden'); }
        function customAlert(message) { showModal('알림', message, [{ text: '확인', classes: 'bg-blue-600 text-white py-2 px-4 rounded-md', onClick: 'hideModal()' }]); }
        function customConfirm(message, onConfirm) {
            const confirmId = `confirm_${Date.now()}`;
            window[confirmId] = () => { onConfirm(); hideModal(); delete window[confirmId]; };
            showModal('확인', message, [{ text: '취소', classes: 'bg-slate-200 py-2 px-4 rounded-md', onClick: 'hideModal()' },{ text: '확인', classes: 'bg-red-600 text-white py-2 px-4 rounded-md', onClick: `${confirmId}()` }]);
        }
        function customPrompt(title, message, defaultValue, onConfirm) {
            const promptId = `prompt_${Date.now()}`; const inputId = `input_${Date.now()}`;
            window[promptId] = () => { const value = document.getElementById(inputId).value; onConfirm(value); hideModal(); delete window[promptId]; };
            showModal(title, `${message}<br/><input type="text" id="${inputId}" value="${defaultValue}" class="mt-2 w-full p-2 border rounded-md">`, [{ text: '취소', classes: 'bg-slate-200 py-2 px-4 rounded-md', onClick: 'hideModal()' },{ text: '확인', classes: 'bg-blue-600 text-white py-2 px-4 rounded-md', onClick: `${promptId}()` }]);
        }
        
        // --- 초기화 및 이벤트 리스너 ---
        document.addEventListener('DOMContentLoaded', () => {
            function initialize() {
                renderFloorSelector();
                handleSwitchFloor();
                updateModeUI();
                document.querySelector('.palette-button[data-type="table"]').classList.add('active');
            }
            // 층 관리
            floorSelector.addEventListener('change', handleSwitchFloor);
            document.getElementById('add-floor').addEventListener('click', () => {
                const name = document.getElementById('new-floor-name').value.trim();
                if (!name) { customAlert('새 층의 이름을 입력하세요.'); return; }
                if (floors[name]) { customAlert('이미 존재하는 층 이름입니다.'); return; }
                floors[name] = { objects: [], rows: 30, cols: 30 };
                currentFloor = name;
                document.getElementById('new-floor-name').value = '';
                renderFloorSelector(); handleSwitchFloor();
            });
            document.getElementById('rename-floor').addEventListener('click', () => {
                const oldName = currentFloor;
                customPrompt('층 이름 변경', '새로운 층 이름을 입력하세요.', oldName, (newName) => {
                    newName = newName.trim(); if (!newName || newName === oldName) return;
                    if (floors[newName]) { customAlert('이미 존재하는 층 이름입니다.'); return; }
                    floors[newName] = floors[oldName]; delete floors[oldName];
                    currentFloor = newName; renderFloorSelector();
                });
            });
            document.getElementById('delete-floor').addEventListener('click', () => {
                if (Object.keys(floors).length <= 1) { customAlert('마지막 남은 층은 삭제할 수 없습니다.'); return; }
                customConfirm(`'${currentFloor}' 층을 정말로 삭제하시겠습니까?`, () => {
                    delete floors[currentFloor]; currentFloor = Object.keys(floors)[0];
                    renderFloorSelector(); handleSwitchFloor();
                });
            });
            // 레이아웃 크기
            document.getElementById('resize-grid').addEventListener('click', () => {
                floors[currentFloor].rows = parseInt(rowsInput.value);
                floors[currentFloor].cols = parseInt(colsInput.value);
                createGrid();
            });
            // 모드 및 팔레트
            modeCreateBtn.addEventListener('click', () => { currentMode = 'create'; updateModeUI(); });
            modeEditBtn.addEventListener('click', () => { currentMode = 'edit'; updateModeUI(); });
            createPalette.addEventListener('click', (e) => {
                if (e.target.tagName === 'BUTTON') {
                    currentObjectType = e.target.dataset.type;
                    document.querySelectorAll('.palette-button').forEach(btn => btn.classList.remove('active'));
                    e.target.classList.add('active');
                    handleClearSelection();
                }
            });
            // 그리드 마우스 이벤트
            gridElement.addEventListener('mousedown', handleGridMouseDown);
            gridElement.addEventListener('mousemove', handleGridMouseMove);
            document.addEventListener('mouseup', handleDocumentMouseUp);
            
            initialize();
        });
    </script>
</body>
</html>
