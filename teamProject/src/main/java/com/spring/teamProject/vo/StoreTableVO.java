// src/main/java/com/spring/teamProject/vo/StoreTableVO.java
package com.spring.teamProject.vo;

public class StoreTableVO {
	private Long tableId;
	private Long storeId;
	private String tableName; // table_info -> tableName으로 변경
	private int capacity;
	private int posX;
	private int posY;

	// 기본 생성자
	public StoreTableVO() {}

	// 모든 필드를 포함하는 생성자 (필요 시)
	public StoreTableVO(Long tableId, Long storeId, String tableName, int capacity, int posX, int posY) {
		this.tableId = tableId;
		this.storeId = storeId;
		this.tableName = tableName;
		this.capacity = capacity;
		this.posX = posX;
		this.posY = posY;
	}

	// Getter and Setter methods
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
	public int getPosX() {
		return posX;
	}
	public void setPosX(int posX) {
		this.posX = posX;
	}
	public int getPosY() {
		return posY;
	}
	public void setPosY(int posY) {
		this.posY = posY;
	}

	@Override
	public String toString() {
		return "StoreTableVO{" +
				"tableId=" + tableId +
				", storeId=" + storeId +
				", tableName='" + tableName + '\'' +
				", capacity=" + capacity +
				", posX=" + posX +
				", posY=" + posY +
				'}';
	}
}