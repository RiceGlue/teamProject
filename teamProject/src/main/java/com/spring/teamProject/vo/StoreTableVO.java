package com.spring.teamProject.vo;

public class StoreTableVO {
	private long table_id;
	private long store_id;
	private String table_info;
	private int capacity;
	private int pos_x;
	private int pos_y;
	
	
	public long getTable_id() {
		return table_id;
	}
	public void setTable_id(long table_id) {
		this.table_id = table_id;
	}
	public long getStore_id() {
		return store_id;
	}
	public void setStore_id(long store_id) {
		this.store_id = store_id;
	}
	public String getTable_info() {
		return table_info;
	}
	public void setTable_info(String table_info) {
		this.table_info = table_info;
	}
	public int getCapacity() {
		return capacity;
	}
	public void setCapacity(int capacity) {
		this.capacity = capacity;
	}
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
	
	
}
