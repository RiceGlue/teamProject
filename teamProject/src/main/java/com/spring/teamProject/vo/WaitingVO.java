package com.spring.teamProject.vo;

public class WaitingVO {
	private String waiting_id;
	private String store_id;
	private String day_of_week;
	private String time_slot;
	private String max_teams;
	private boolean is_active;
	
	public String getWaiting_id() {
		return waiting_id;
	}
	public void setWaiting_id(String waiting_id) {
		this.waiting_id = waiting_id;
	}
	public String getStore_id() {
		return store_id;
	}
	public void setStore_id(String store_id) {
		this.store_id = store_id;
	}
	public String getDay_of_week() {
		return day_of_week;
	}
	public void setDay_of_week(String day_of_week) {
		this.day_of_week = day_of_week;
	}
	public String getTime_slot() {
		return time_slot;
	}
	public void setTime_slot(String time_slot) {
		this.time_slot = time_slot;
	}
	public String getMax_teams() {
		return max_teams;
	}
	public void setMax_teams(String max_teams) {
		this.max_teams = max_teams;
	}
	public boolean isIs_active() {
		return is_active;
	}
	public void setIs_active(boolean is_active) {
		this.is_active = is_active;
	}
	
	

}
