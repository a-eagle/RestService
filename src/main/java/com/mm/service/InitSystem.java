package com.mm.service;

import java.sql.SQLException;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.apache.ibatis.session.SqlSession;

import com.mm.mybatis.MyBatis;

@Path("/init-system")
public class InitSystem {
	private String msg;
	
	@GET
	@Produces(MediaType.TEXT_PLAIN)
	public String get() {
		try {
			boolean ok = initSystem();
			return "R: init system " + (ok ? " success" : " fail") + "; " + msg;
		} catch (Exception ex) {
			ex.printStackTrace();
			return "E: init system "  + " fail" + "; " + ex.getMessage();
		}
	}
	
	private boolean initSystem() {
		SqlSession s = MyBatis.getSession();
		java.sql.Connection c = s.getConnection();
		boolean ok = version_1(s, c);
		s.close();
		return ok;
	}
	
	private boolean version_1(SqlSession s, java.sql.Connection c) {
		try {
			c.createStatement().execute("create table _user (_id integer PRIMARY KEY auto_increment, _name varchar(60),  _password varchar(60), _dept varchar(120) )");
			
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
			
			c.createStatement().execute("insert into _department (_name) values ('信息办')");
			c.createStatement().execute("insert into _department (_name) values ('政府办')");
			c.createStatement().execute("insert into _department (_name) values ('发改委')");
			c.createStatement().execute("insert into _department (_name) values ('教体局')");
			c.createStatement().execute("insert into _department (_name) values ('科技局')");
			c.createStatement().execute("insert into _department (_name) values ('工信局')");
			c.createStatement().execute("insert into _department (_name) values ('公安局')");
			c.createStatement().execute("insert into _department (_name) values ('民政局')");
			c.createStatement().execute("insert into _department (_name) values ('司法局')");
			c.createStatement().execute("insert into _department (_name) values ('财政局')");
			c.createStatement().execute("insert into _department (_name) values ('人社局')");
			c.createStatement().execute("insert into _department (_name) values ('自然资源局')");
			c.createStatement().execute("insert into _department (_name) values ('生态环境局')");
			c.createStatement().execute("insert into _department (_name) values ('住建局')");
			c.createStatement().execute("insert into _department (_name) values ('交运局')");
			c.createStatement().execute("insert into _department (_name) values ('水利局')");
			c.createStatement().execute("insert into _department (_name) values ('农业农村局')");
			c.createStatement().execute("insert into _department (_name) values ('商务局')");
			c.createStatement().execute("insert into _department (_name) values ('卫健委')");
			c.createStatement().execute("insert into _department (_name) values ('审计局')");
			c.createStatement().execute("insert into _department (_name) values ('应急管理局')");
			c.createStatement().execute("insert into _department (_name) values ('退役军人事务局')");
			c.createStatement().execute("insert into _department (_name) values ('统计局')");
			c.createStatement().execute("insert into _department (_name) values ('林业局')");
			c.createStatement().execute("insert into _department (_name) values ('市监局')");
			c.createStatement().execute("insert into _department (_name) values ('乡村振新局')");
			c.createStatement().execute("insert into _department (_name) values ('医保局')");
			c.createStatement().execute("insert into _department (_name) values ('城管局')");
			c.createStatement().execute("insert into _department (_name) values ('产业园管委会')");
			c.createStatement().execute("insert into _department (_name) values ('政务服务中心')");
			c.createStatement().execute("insert into _department (_name) values ('税务局')");
			c.createStatement().execute("insert into _department (_name) values ('气象局')");
			
			c.createStatement().execute("create table _logger (_id integer PRIMARY KEY auto_increment, _time varchar(60),  _usrName varchar(60),  _operation varchar(255) )");
			c.createStatement().execute("create table _table_statistics (_id integer PRIMARY KEY auto_increment, _table_name varchar(60),  _data_count integer )");
			
			s.commit();
			return true;
		} catch (SQLException e) {
			e.printStackTrace();
			s.rollback();
			msg = e.getMessage();
		}
		return false;
	}
}
