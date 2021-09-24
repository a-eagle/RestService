package com.mm.service;

import java.util.List;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

import org.apache.ibatis.session.SqlSession;

import com.mm.mybatis.MyBatis;
import com.mm.mybatis.User;

@Path("/user")
public class UserService extends BasicService {
	
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult findAll() {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			List<User> u = session.selectList("com.mm.mybatis.User.findAll"); 
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
	
	@GET
	@Path("/{name}")
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult findByName(@PathParam("name") String name) {
		SqlSession session = null;
		User u = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			u = session.selectOne("com.mm.mybatis.User.findByName", name);
			sr.setSimpleData(u);
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
	public ServiceResult insert(@FormParam("name") String name, @FormParam("password") String password) {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			int num = session.insert("com.mm.mybatis.User.insert", new User(name, password));
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
	
	@PUT
	@Consumes(MediaType.APPLICATION_FORM_URLENCODED)
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult updatePassword(@FormParam("name") String name, @FormParam("password") String password) {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			User u = session.selectOne("com.mm.mybatis.User.findByName", name);
			if (u != null) {
				u.password = password;
				int num = session.update("com.mm.mybatis.User.updatePassword", u);
				session.commit();
				sr.setSimpleData(num);
			} else {
				sr.fail("user not found");
			}
		} catch(Exception ex) {
			ex.printStackTrace();
			sr.fail(ex.getMessage());
		} finally {
			if (session != null)
				session.close();
		}
		
		return sr;
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
			int num = session.delete("com.mm.mybatis.User.delete", ids);
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
