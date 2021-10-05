package com.mm.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.FormParam;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;

import org.apache.ibatis.session.SqlSession;

import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mm.mybatis.MyBatis;
import com.mm.mybatis.TablePrototype;
import com.mm.mybatis.TablePrototypeManager;;

@Path("/tableprototype")
public class TablePrototypeService extends BasicService {
	
	@GET
	@Path("/{table-name}")
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult findByName(@PathParam("table-name") String name) {
		SqlSession session = null;
		ServiceResult r = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			List<TablePrototype> u = TablePrototypeManager.findByName(name, session);
			r.setListData(u);
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
	@Path("/table")
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult findByOwner(@QueryParam("dept-id") String deptId) {
		SqlSession session = null;
		ServiceResult r = new ServiceResult();
		try {
			long did = -1;
			if (deptId == null || "".equals(deptId)) {
				did = 0;
			} else {
				try {
					did = Long.parseLong(deptId);
				} catch (Exception ex) {
					did = -1;
				}
			}
			session  = MyBatis.getSession();
			List<TablePrototype> u = session.selectList("com.mm.mybatis.TablePrototype.findByDeptId", did);
			r.setListData(u);
		} catch(Exception ex) {
			ex.printStackTrace();
			r.fail(ex.getMessage());
		} finally {
			if (session != null)
				session.close();
		}
		return r;
	}
	
	@POST
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult insert(String json) {
		SqlSession session = null;
		ServiceResult r = new ServiceResult();
		try {
			ObjectMapper m = new ObjectMapper();
			JavaType jt = m.getTypeFactory().constructParametricType(ArrayList.class, TablePrototype.class);
			List<TablePrototype> data = m.readValue(json, jt);
			session  = MyBatis.getSession();
			int num = 0;
			for (TablePrototype d : data) {
				if (d._type == TablePrototype.TYPE_TABLE) {
					session.insert("com.mm.mybatis.TablePrototype.createTableStructure", d);
					System.out.println(d._name);
				} else if (d._type == TablePrototype.TYPE_COLUMN) {
					session.insert("com.mm.mybatis.TablePrototype.addColumn", d);
				}
				num += session.insert("com.mm.mybatis.TablePrototype.insert", d);
			}
			session.commit();
			r.setSimpleData(num);
		} catch(Exception ex) {
			session.rollback();
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
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult update(@PathParam("id") String id, String json) {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			ObjectMapper m = new ObjectMapper();
			JavaType jt = m.getTypeFactory().constructParametricType(HashMap.class, String.class, String.class);
			HashMap<String, String> data = m.readValue(json, jt);
			data.put("_id", id);
			
			int num = session.update("com.mm.mybatis.TablePrototype.update", data);
			session.commit();
			sr.setSimpleData(num);
		} catch(Exception ex) {
			session.rollback();
			ex.printStackTrace();
			sr.fail(ex.getMessage());
		} finally {
			if (session != null)
				session.close();
		}
		
		return sr;
	}
	
	@DELETE
	@Path("/{table-name}")
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult deleteByName(@PathParam("table-name") String name) {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			int num = session.delete("com.mm.mybatis.TablePrototype.delete", name);
			session.commit();
			sr.setSimpleData(num);
			TablePrototypeManager.dirty(name);
		} catch(Exception ex) {
			session.rollback();
			ex.printStackTrace();
			sr.fail(ex.getMessage());
		} finally {
			if (session != null)
				session.close();
		}
		
		return sr;
	}
	
	@DELETE
	@Path("/column/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult deleteColumn(@PathParam("id") String id) {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			int num = session.delete("com.mm.mybatis.TablePrototype.deleteColumn", Long.parseLong(id));
			session.commit();
			sr.setSimpleData(num);
		} catch(Exception ex) {
			session.rollback();
			ex.printStackTrace();
			sr.fail(ex.getMessage());
		} finally {
			if (session != null)
				session.close();
		}
		
		return sr;
	}
	
}
