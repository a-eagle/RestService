package com.mm.mybatis;

public class User {
	public long id;
	public String name;
	public String password;
	
	public User() {}
	
	public User(String n, String p) {
		name = n;
		password = p;
	}
	
	public String toString() {
		return "id = " + id + " name = " + name + " password = " + password;
	}
}
