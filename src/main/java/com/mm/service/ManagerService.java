package com.mm.service;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;

import org.apache.ibatis.session.SqlSession;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.type.MapLikeType;
import com.fasterxml.jackson.databind.type.TypeFactory;
import com.mm.mybatis.MyBatis;
import com.mm.mybatis.TableStatistics;

@Path("/manager")
public class ManagerService extends BasicService {
	
	@POST
	@Path("/execSql")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult execSql(String json) {
		ServiceResult r = new ServiceResult();
		SqlSession session = null;
		
		try {
			session  = MyBatis.getSession();
			ObjectMapper m = new ObjectMapper();
			TypeFactory fac = m.getTypeFactory();
			MapLikeType type = fac.constructMapLikeType(HashMap.class, String.class, String.class);
			Map<String, String> params = m.readValue(json, type);
			String sql = params.get("sql").trim();
			String lsql = sql.toLowerCase();
			
			if (lsql.startsWith("insert") || lsql.startsWith("update") || lsql.startsWith("delete") || 
					lsql.startsWith("create") || lsql.startsWith("drop") || lsql.startsWith("alter")) {
				execUpdate(sql, r, session);
			} else {
				execQuery(sql, r, session);
			}
			
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
	@Path("/TableStatistics/update")
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult updateTableStatistics() {
		ServiceResult r = new ServiceResult();
		SqlSession session = MyBatis.getSession();
		try {
			Connection con = session.getConnection();
			Statement stmt = con.createStatement();
			List<String> tabs = new ArrayList<String>();
			List<Integer> tabsCount = new ArrayList<Integer>();
			
			ResultSet rs = stmt.executeQuery("select _name from _table_prototype where _type = 1");
			while (rs.next()) {
				tabs.add(rs.getString(1));
			}
			rs.close();
			for (String t : tabs) {
				try {
					ResultSet rs2 = stmt.executeQuery("select count(*) from " + t);
					rs2.next();
					tabsCount.add(rs2.getInt(1));
					rs2.close();
				} catch (Exception ex2) {
					ex2.printStackTrace();
					tabsCount.add(-1);
				}
			}
			
			List<TableStatistics> datas = session.selectList("com.mm.mybatis.TableStatistics.findAll");
			Map<String, TableStatistics> ks = new HashMap<String, TableStatistics>();
			for (TableStatistics t : datas) {
				ks.put(t.tableName, t);
			}
			for (int i = 0; i < tabs.size(); ++i) {
				TableStatistics t = ks.get(tabs.get(i));
				if (t == null) {
					t = new TableStatistics();
					t.tableName = tabs.get(i);
					ks.put(tabs.get(i), t);
				}
				t.dataCount = tabsCount.get(i);
				session.insert("com.mm.mybatis.TableStatistics.update", t);
			}
			
			session.commit();
			r.setSimpleData("ok");
		} catch (Exception ex) {
			ex.printStackTrace();
			r.fail(ex.getMessage());
			session.rollback();
		} finally {
			if (session != null)
				session.close();
		}
		
		return r;
	}
	
	@GET
	@Path("/TableStatistics/findAll")
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult findAllTableStatistics() {
		ServiceResult r = new ServiceResult();
		SqlSession session = MyBatis.getSession();
		try {
			List<TableStatistics> datas = session.selectList("com.mm.mybatis.TableStatistics.findAll");
			r.setListData(datas);
		} catch (Exception ex) {
			ex.printStackTrace();
			r.fail(ex.getMessage());
		} finally {
			if (session != null)
				session.close();
		}
		
		return r;
	}
	
	private void execUpdate(String sql, ServiceResult r, SqlSession session) throws Exception {
		Connection con = session.getConnection();
		Statement stmt = con.createStatement();
		int rc = stmt.executeUpdate(sql);
		
		Map<String, Object> rr = new HashMap<String, Object>();
		List<HashMap<String, String>> head = new ArrayList<HashMap<String, String>>();
		HashMap<String, String> col = new HashMap<String, String>();
		col.put("title", "update info");
		col.put("key", "INFO");
		head.add(col);
		
		List<HashMap<String, String>> data = new ArrayList<HashMap<String, String>>();
		HashMap<String, String> row = new HashMap<String, String>();
		row.put("INFO", "" + rc);
		data.add(row);
		
		rr.put("heads", head);
		rr.put("datas", data);
		r.setSimpleData(rr);
		
		stmt.close();
	}
	
	private void execQuery(String sql, ServiceResult r, SqlSession session) throws Exception {
		Map<String, Object> rr = new HashMap<String, Object>();
		Connection con = session.getConnection();
		Statement stmt = con.createStatement();
		ResultSet rs = stmt.executeQuery(sql);
		ResultSetMetaData md = rs.getMetaData();
		List<HashMap<String, String>> head = new ArrayList<HashMap<String, String>>();
		
		for (int i = 0; i < md.getColumnCount(); ++i) {
			HashMap<String, String> col = new HashMap<String, String>();
			col.put("title", md.getColumnLabel(i + 1));
			col.put("key", md.getColumnName(i + 1));
			head.add(col);
		}
		
		List<HashMap<String, String>> data = new ArrayList<HashMap<String, String>>();
		while (rs.next()) {
			HashMap<String, String> row = new HashMap<String, String>();
			for (int i = 0; i < md.getColumnCount(); ++i) {
				row.put(md.getColumnName(i + 1), rs.getString(i + 1));
			}
			data.add(row);
		}
		
		rr.put("heads", head);
		rr.put("datas", data);
		r.setSimpleData(rr);
		
		rs.close();
		stmt.close();
	}
}
