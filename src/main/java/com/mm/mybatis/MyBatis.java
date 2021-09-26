package com.mm.mybatis;

import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.ExecutorType;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

public class MyBatis {
	private static SqlSessionFactory mFactory;
	private static boolean mInited;
	
	private static void init() {
		mInited = true;
		String resource = "mybatis-config.xml";// 通过流处理获取sqlSessionFactory创建一个实例
		InputStream inputStream;
		try {
			inputStream = Resources.getResourceAsStream(resource);
			mFactory = new SqlSessionFactoryBuilder().build(inputStream);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static boolean initSystem() {
		SqlSession s = getSession();
		java.sql.Connection c = s.getConnection();
		
		int version = 0;
		
		if (version == 0 && version_1(s, c)) {
			version = 1;
		}
		
		s.close();
		
		return version == 1;
	}
	
	private static boolean version_1(SqlSession s, java.sql.Connection c) {
		try {
			c.createStatement().execute("create table _user (_id integer PRIMARY KEY auto_increment, _name varchar(60),  _password varchar(60) )");
			
			// _type 用于区分部门，或主题，暂时不使用，默认0表示部门
			c.createStatement().execute("create table _department (_id integer PRIMARY KEY auto_increment, _name varchar(120), _parent_id integer default 0, _parent_name varchar(120),  _type integer default 0)");
			
			// _type is 1: table name, 2: column
			// _data_type is :  'file' or 'str' or 'lstr' (long str)
			// _max_len: only use for 'str' max length
			// _owner : is table name for column type
			/**
			 * _type	_name		_name_cn	_data_type	_max_len	_owner
				1		mzj_nhxx	农业信息								mzj_nhxx
				2		_name		姓名			str			50			mzj_nhxx
				2		_birthday	出生日期		str			50			mzj_nhxx
				2		_address	住址			str			250			mzj_nhxx
			 */
			c.createStatement().execute("create table _table_prototype (_id integer PRIMARY KEY auto_increment, _type integer, _name varchar(120),  _name_cn varchar(120),  _data_type char(4),  _max_len integer default 250,  _owner varchar(120), _html varchar(250), _dept_id  integer default 0)");
			
			// _name : system build unique file name
			// _raw_name: raw file name
			// _type : file type (doc,  xml, docx , ...)
			c.createStatement().execute("create table _file_info (_id integer PRIMARY KEY auto_increment, _name varchar(60),  _raw_name varchar(250), _type varchar(64) )");
			
			c.createStatement().execute("insert into _user (_name, _password) values('admin', 'admin@123')");
			
			s.commit();
			return true;
		} catch (SQLException e) {
			e.printStackTrace();
			s.rollback();
		}
		return false;
	}
	
	public static SqlSession getSession() {
		if (! mInited) {
			init();
		}
		
		return mFactory.openSession();
	}
	
	public static SqlSession getBatchSession() {
		if (! mInited) {
			init();
		}
		return mFactory.openSession(ExecutorType.BATCH);
	}
}
