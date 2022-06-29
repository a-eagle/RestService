package com.mm.mybatis;

public class TableStatistics {
	public long id;
	public String tableName;
	public int dataCount;
	
	public String toString() {
		return "id = " + id + " tableName = " + tableName + " dataCount = " + dataCount;
	}
}