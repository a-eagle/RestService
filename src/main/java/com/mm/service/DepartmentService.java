package com.mm.service;

import java.util.List;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

import org.apache.ibatis.session.SqlSession;

import com.mm.mybatis.MyBatis;
import com.mm.mybatis.Department;;

@Path("/department")
public class DepartmentService extends BasicService {
	
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult findAll() {
		SqlSession session = null;
		ServiceResult r = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			List<Department> data = session.selectList("com.mm.mybatis.Department.findAll");
			r.setListData(data);
		} catch(Exception ex) {
			ex.printStackTrace();
			r.fail(ex.getMessage());
		} finally {
			if (session != null) 
				session.close();
		}
		
		return r;
	}
	
	@GET
	@Path("/{name}")
	@Produces(MediaType.APPLICATION_JSON)
	public Department findByName(@PathParam("name") String name) {
		SqlSession session = null;
		Department u = null;
		ServiceResult r = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			u = session.selectOne("com.mm.mybatis.Department.findByName", name);
			r.setSimpleData(u);
		} catch(Exception ex) {
			ex.printStackTrace();
		} finally {
			if (session != null)
				session.close();
		}
		return u;
	}
	
	@POST
	@Consumes(MediaType.APPLICATION_FORM_URLENCODED)
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult insert(@FormParam("name") String name, @FormParam("parentId") String parentId, @FormParam("parentName") String parentName) {
		SqlSession session = null;
		int num = 0;
		ServiceResult r = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			num = session.insert("com.mm.mybatis.Department.insert", new Department(0, name, Long.parseLong(parentId), parentName));
			session.commit();
			r.setSimpleData(num);
		} catch(Exception ex) {
			ex.printStackTrace();
			r.fail(ex.getMessage());
		} finally {
			if (session != null)
				session.close();
		}
		return r;
	}
	
	@PUT
	@Path("/{id}")
	@Consumes(MediaType.APPLICATION_FORM_URLENCODED)
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult update(@PathParam("id") String id, @FormParam("name") String name, @FormParam("parentId") String parentId, @FormParam("parentName") String parentName) {
		SqlSession session = null;
		int num = 0;
		ServiceResult r = new ServiceResult();
		try {
			Department d = new Department(Long.parseLong(id), name, Long.parseLong(parentId), parentName);
			session  = MyBatis.getSession();
			num = session.update("com.mm.mybatis.Department.update", d);
			session.commit();
			r.setSimpleData(num);
		} catch(Exception ex) {
			ex.printStackTrace();
			r.fail(ex.getMessage());
		} finally {
			if (session != null)
				session.close();
		}
		
		return r;
	}
	
	@DELETE
	@Path("/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult delete(@PathParam("id") String id) {
		SqlSession session = null;
		int num = 0;
		ServiceResult r = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			String[] ids = id.split(",");
			num = session.delete("User_delete", ids);
			session.commit();
			r.setSimpleData(num);
		} catch(Exception ex) {
			ex.printStackTrace();
			r.fail(ex.getMessage());
		} finally {
			if (session != null)
				session.close();
		}
		return r;
	}
	
}
