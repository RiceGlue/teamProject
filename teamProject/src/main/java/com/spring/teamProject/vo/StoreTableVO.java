package com.spring.teamProject.vo;

public class StoreTableVO {

    // 필드
    private Long tableId;
    private Long storeId;
    private String tableName;
    private int capacity;
    private String tableInfo;

    // ⭐ 수정된 부분: 필드 이름을 DB 컬럼과 동일하게 변경
    private int pos_x;
    private int pos_y;

    private boolean isReserved;

    // 기본 생성자
    public StoreTableVO() {}

    // Getter와 Setter
    public Long getTableId() {
        return tableId;
    }

    public void setTableId(Long tableId) {
        this.tableId = tableId;
    }

    public Long getStoreId() {
        return storeId;
    }

    public void setStoreId(Long storeId) {
        this.storeId = storeId;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getTableInfo() {
        return tableInfo;
    }

    public void setTableInfo(String tableInfo) {
        this.tableInfo = tableInfo;
    }

    // ⭐ 수정된 부분: DB 컬럼명에 맞는 Getter와 Setter
    public int getPos_x() {
        return pos_x;
    }

    public void setPos_x(int pos_x) {
        this.pos_x = pos_x;
    }

    public int getPos_y() {
        return pos_y;
    }

    public void setPos_y(int pos_y) {
        this.pos_y = pos_y;
    }

    public boolean getIsReserved() {
        return isReserved;
    }

    public void setIsReserved(boolean isReserved) {
        this.isReserved = isReserved;
    }
}
