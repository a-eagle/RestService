package com.mm.mybatis;

public class Department {
	public long id;
	public String name;
	public long parentId;
	public String parentName;
	public int type;
	
	public Department() {}
	
	public Department(long id, String n, long pid, String pname) {
		this.id = id;
		name = n;
		parentId = pid;
		parentName = pname;
	}
}
