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
			
			// _type �������ֲ��ţ������⣬��ʱ��ʹ�ã�Ĭ��0��ʾ����
			c.createStatement().execute("create table _department (_id integer PRIMARY KEY auto_increment, _name varchar(120), _parent_id integer default 0, _parent_name varchar(120),  _type integer default 0)");
			
			// _type is 1: table name, 2: column
			// _data_type is :  'file' or 'str' or 'lstr' (long str)
			// _max_len: only use for 'str' max length
			// _owner : is table name for column type
			/**
			 * _type	_name		_name_cn	_data_type	_max_len	_owner
				1		mzj_nhxx	ũҵ��Ϣ								mzj_nhxx
				2		_name		����			str			50			mzj_nhxx
				2		_birthday	��������		str			50			mzj_nhxx
				2		_address	סַ			str			250			mzj_nhxx
			 */
			c.createStatement().execute("create table _table_prototype (_id integer PRIMARY KEY auto_increment, _type integer, _name varchar(120),  _name_cn varchar(120),  _data_type char(4),  _max_len integer default 250,  _owner varchar(120), _html varchar(250), _dept_id  integer default 0)");
			
			// _name : system build unique file name
			// _raw_name: raw file name
			// _type : file type (doc,  xml, docx , ...)
			c.createStatement().execute("create table _file_info (_id integer PRIMARY KEY auto_increment, _name varchar(60),  _raw_name varchar(250), _type varchar(64) )");
			
			c.createStatement().execute("insert into _user (_name, _password) values('admin', 'admin@123')");
			
			c.createStatement().execute("insert into _department (_name) values ('��Ϣ��')");
			c.createStatement().execute("insert into _department (_name) values ('������')");
			c.createStatement().execute("insert into _department (_name) values ('����ί')");
			c.createStatement().execute("insert into _department (_name) values ('�����')");
			c.createStatement().execute("insert into _department (_name) values ('�Ƽ���')");
			c.createStatement().execute("insert into _department (_name) values ('���ž�')");
			c.createStatement().execute("insert into _department (_name) values ('������')");
			c.createStatement().execute("insert into _department (_name) values ('������')");
			c.createStatement().execute("insert into _department (_name) values ('˾����')");
			c.createStatement().execute("insert into _department (_name) values ('������')");
			c.createStatement().execute("insert into _department (_name) values ('�����')");
			c.createStatement().execute("insert into _department (_name) values ('��Ȼ��Դ��')");
			c.createStatement().execute("insert into _department (_name) values ('��̬������')");
			c.createStatement().execute("insert into _department (_name) values ('ס����')");
			c.createStatement().execute("insert into _department (_name) values ('���˾�')");
			c.createStatement().execute("insert into _department (_name) values ('ˮ����')");
			c.createStatement().execute("insert into _department (_name) values ('ũҵũ���')");
			c.createStatement().execute("insert into _department (_name) values ('�����')");
			c.createStatement().execute("insert into _department (_name) values ('����ί')");
			c.createStatement().execute("insert into _department (_name) values ('��ƾ�')");
			c.createStatement().execute("insert into _department (_name) values ('Ӧ�������')");
			c.createStatement().execute("insert into _department (_name) values ('���۾��������')");
			c.createStatement().execute("insert into _department (_name) values ('ͳ�ƾ�')");
			c.createStatement().execute("insert into _department (_name) values ('��ҵ��')");
			c.createStatement().execute("insert into _department (_name) values ('�м��')");
			c.createStatement().execute("insert into _department (_name) values ('������¾�')");
			c.createStatement().execute("insert into _department (_name) values ('ҽ����')");
			c.createStatement().execute("insert into _department (_name) values ('�ǹܾ�')");
			c.createStatement().execute("insert into _department (_name) values ('��ҵ԰��ί��')");
			c.createStatement().execute("insert into _department (_name) values ('�����������')");
			c.createStatement().execute("insert into _department (_name) values ('˰���')");
			c.createStatement().execute("insert into _department (_name) values ('�����')");
			
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
