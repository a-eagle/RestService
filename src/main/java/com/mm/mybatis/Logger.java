package com.mm.mybatis;

import java.text.SimpleDateFormat;
import java.util.Date;

public class Logger {
	public long id;
	public String time;
	public String userName;
	public String operation;
	
	public Logger() {
	}
	
	public Logger(String time, String userName, String operation) {
		this.time = time;
		this.userName = userName;
		this.operation = operation;
	}
	
	public Logger(String userName, String operation) {
		Date date = new Date();
		SimpleDateFormat dateFormat= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		this.time = dateFormat.format(date);
		this.userName = userName;
		this.operation = operation;
	}
	
	public String toString() {
		return "id = " + id + " time = " + time + " userName = " + userName + " operation=" + operation;
	}
}
