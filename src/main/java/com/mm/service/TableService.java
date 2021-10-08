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
import com.fasterxml.jackson.databind.type.TypeFactory;
import com.mm.mybatis.MyBatis;
import com.mm.mybatis.TablePrototype;
import com.mm.mybatis.TablePrototypeManager;
import com.mm.mybatis.User;
import com.mm.service.BasicService.ServiceResult;

@Path("/api/{table-name}")
public class TableService extends BasicService {
	
	public static class Data {
		public String tableName;
		public String colNames;
		public List<String> colValues;
	}
	
	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult findAll(@PathParam("table-name") String tabName) {
		SqlSession session = null;
		ServiceResult r = new ServiceResult();
		try {
			session  = MyBatis.getSession();
			TablePrototypeManager.Table t = TablePrototypeManager.findByName2(tabName, session);
			Map<String, String> param = new HashMap<String, String>();
			param.put("tableName", t.tableName);
			
			String dc = null;
			if (isUserCertified()) {
				dc = t.queryColumns;
				r.headers = t.queryHeaders;
			} else {
				dc = t.dataColumns;
				r.headers = t.dataHeaders;
			}
			param.put("columns", dc);
			List< java.util.Map<String, String> > u = session.selectList("com.mm.mybatis.Table.findAll", param);
			r.setListData(u);
			
		} catch(Exception ex) {
			ex.printStackTrace();
			if (isUserCertified()) {
				r.fail(ex.getMessage());
			} else {
				r.fail("Server occur exception");
			}
		} finally {
			if (session != null)
				session.close();
		}
		return r;
	}
	
	@GET
	@Path("/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult findById(@PathParam("table-name") String tableName, @PathParam("id") String id) {
		SqlSession session = null;
		Map<String, String> u = null;
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
			if (isUserCertified()) {
				sr.fail(ex.getMessage());
			} else {
				sr.fail("Server occur exception");
			}
		} finally {
			if (session != null)
				session.close();
		}
		return sr;
	}
	
	// remove columns not in prototype
	protected void updateData(Data data, Map<String, String> map, SqlSession session) {
		List<TablePrototype> columns = TablePrototypeManager.findByName(data.tableName, session);
		
		StringBuilder cols = new StringBuilder();
		
		for (TablePrototype p : columns) {
			if (p._type != TablePrototype.TYPE_COLUMN) {
				continue;
			}
			if (! map.containsKey(p._name)) {
				continue;
			}
			if (cols.length() != 0) 
				cols.append(",");
			cols.append(p._name);
			data.colValues.add(map.get(p._name));
		}
		
		data.colNames = cols.toString();
	}
	
	@POST
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult insert(@PathParam("table-name") String tableName, String json) {
		SqlSession session = null;
		ServiceResult sr = new ServiceResult();
		try {
			session  = MyBatis.getBatchSession();
			ObjectMapper m = new ObjectMapper();
			TypeFactory fac = m.getTypeFactory();
			JavaType innerType = fac.constructParametricType(HashMap.class, String.class, String.class);
			JavaType jt = fac.constructParametricType(ArrayList.class, innerType);
			List<Map<String, String>> data = m.readValue(json, jt);
			int num = 0;
			
			Data param = new Data();
			param.tableName = tableName;
			param.colValues = new ArrayList<String>();
			
			for (int i = 0; data!= null && i < data.size(); ++i) {
				param.colValues.clear();
				param.colNames = "";
				updateData(param, data.get(i), session);
				if (param.colValues.size() == 0) {
					// no data, ignore
					continue;
				}
				int numr = session.insert("com.mm.mybatis.Table.insert", param);
				num += numr;
			}
			
			session.commit();
			sr.setSimpleData(num);
		} catch(Exception ex) {
			session.rollback();
			ex.printStackTrace();
			if (isUserCertified()) {
				sr.fail(ex.getMessage());
			} else {
				sr.fail("Server occur exception");
			}
		} finally {
			if (session != null)
				session.close();
		}
		
		return sr;
	}
}
