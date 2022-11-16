package com.mm.mybatis;

public class User {
	public long id;
	public String name;
	public String password;
	public String dept;
	
	public User() {}
	
	public User(String name, String password, String dept) {
		this.name = name;
		this.password = password;
		this.dept = dept;
	}
	
	public String toString() {
		return "id = " + id + " name = " + name + " password = " + password;
	}
}
