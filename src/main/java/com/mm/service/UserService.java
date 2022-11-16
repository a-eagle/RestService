package com.mm.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;

import org.apache.ibatis.session.SqlSession;

import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.type.TypeFactory;
import com.mm.mybatis.MyBatis;
import com.mm.mybatis.TablePrototype;
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
	
	public static User findUser(String name) {
		SqlSession session = null;
		User u = null;
		try {
			session  = MyBatis.getSession();
			u = (User)session.selectOne("com.mm.mybatis.User.findByName", name);
		} catch(Exception ex) {
			ex.printStackTrace();
		} finally {
			if (session != null)
				session.close();
		}
		return u;
	}
	
	@POST
	//@Consumes(MediaType.APPLICATION_FORM_URLENCODED)
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	//public ServiceResult insert(@FormParam("name") String name, @FormParam("password") String password, @FormParam("dept") String dept) {
	public ServiceResult insert( String json) {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			ObjectMapper m = new ObjectMapper();
			TypeFactory fac = m.getTypeFactory();
			JavaType jt = fac.constructParametricType(HashMap.class, String.class, String.class);
			Map<String, String> data = m.readValue(json, jt);
			String name = data.get("name");
			String password = data.get("password");
			String dept = data.get("dept");
			int num = session.insert("com.mm.mybatis.User.insert", new User(name, password, dept));
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
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult updatePassword(String json) {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			ObjectMapper m = new ObjectMapper();
			TypeFactory fac = m.getTypeFactory();
			JavaType jt = fac.constructParametricType(HashMap.class, String.class, String.class);
			Map<String, String> data = m.readValue(json, jt);
			String id = data.get("id");
			String password = data.get("password");
			User u = new User();
			u.id = Integer.parseInt(id);
			u.password = password;
			int num = session.update("com.mm.mybatis.User.updatePassword", u);
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
	
	@POST
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	@Path("login")
	public ServiceResult login(String json) {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			ObjectMapper m = new ObjectMapper();
			User data = m.readValue(json, User.class);
			session  = MyBatis.getSession();
			User nu = session.selectOne("com.mm.mybatis.User.findByName", data.name);
			if (nu != null && data.password != null && nu.password != null && data.password.equals(nu.password)) {
				sr.setSimpleData(Auth.buildAuthToken(data.name));
				// setRequestUser(nu);
			} else {
				sr.fail("User name or password wrong");
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
}
