package com.mm.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.ws.rs.Consumes;
import javax.ws.rs.FormParam;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
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
import com.mm.mybatis.TablePrototypeManager;
import com.mm.mybatis.User;
import com.mm.service.BasicService.ServiceResult;

@Path("/table/{table-name}")
public class TableService extends BasicService {
	
	public static class Results extends ServiceResult {
		public List<TablePrototypeManager.Table.Header> headers;
	}
	
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public Results findAll(@PathParam("table-name") String tabName, @QueryParam("result-for") String rfStr) {
		SqlSession session = null;
		Results r = new Results();
		try {
			session  = MyBatis.getSession();
			TablePrototypeManager.Table t = TablePrototypeManager.findByName2(tabName, session);
			Map<String, String> param = new HashMap<String, String>();
			param.put("tableName", t.tableName);
			String dc = t.dataColumns;
			r.headers = t.dataHeaders;
			if ("ui".equals(rfStr)) {
				dc = t.queryColumns;
				r.headers = t.queryHeaders;
			}
			param.put("columns", dc);
			List< java.util.Map<String, String> > u = session.selectList("com.mm.mybatis.Table.findAll", param);
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
	@Path("/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult findByName(@PathParam("table-name") String tableName, @PathParam("id") String id) {
		SqlSession session = null;
		User u = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			Map<String, String> param = new HashMap<String, String>();
			param.put("tableName", tableName);
			param.put("id", id);
			u = session.selectOne("com.mm.mybatis.Table.findById", param);
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
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult insert(@PathParam("table-name") String tableName, String json) {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			ObjectMapper m = new ObjectMapper();
			Map<String, String> data = m.readValue(json, Map.class);
			int num = session.insert("com.mm.mybatis.Table.insert", data);
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
