package com.mm.service;

import java.util.List;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;

import org.apache.ibatis.session.SqlSession;

import com.mm.mybatis.MyBatis;
import com.mm.mybatis.Logger;

@Path("/Logger")
public class LoggerService extends BasicService {
	
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult findAll() {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			List<Logger> u = session.selectList("com.mm.mybatis.Logger.findAll"); 
			sr.setListData(u);
		} catch(Exception ex) {
			ex.printStackTrace();
			sr.fail(ex.getMessage());
		} finally {
			if (session != null) 
				session.close();
		}
		
		return sr;
	}
	
	@POST
	@Consumes(MediaType.APPLICATION_FORM_URLENCODED)
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult insert(@FormParam("usrName") String usrName, @FormParam("operation") String operation) {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			int num = session.insert("com.mm.mybatis.Logger.insert", new Logger(usrName, operation));
			session.commit();
			sr.setSimpleData(num);
		} catch(Exception ex) {
			ex.printStackTrace();
			sr.fail(ex.getMessage());
		} finally {
			if (session != null)
				session.close();
		}
		
		return sr;
	}
	
	public static boolean save(SqlSession session, String usrName, String operation) {
		boolean st = false;
		try {
			int num = session.insert("com.mm.mybatis.Logger.insert", new Logger(usrName, operation));
			session.commit();
			st = true;
		} catch(Exception ex) {
			ex.printStackTrace();
		} finally {
			if (session != null)
				session.close();
		}
		
		return st;
	}
	
	public static boolean save(String usrName, String operation) {
		SqlSession session = MyBatis.getSession();
		return save(session, usrName, operation);
	}
	
	
	@DELETE
	@Path("/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult delete(@PathParam("id") String id) {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			String[] ids = id.split(",");
			int num = session.delete("com.mm.mybatis.Logger.delete", ids);
			session.commit();
			sr.setSimpleData(num);
		} catch(Exception ex) {
			ex.printStackTrace();
			sr.fail(ex.getMessage());
		} finally {
			if (session != null)
				session.close();
		}
		
		return sr;
	}
	
}
