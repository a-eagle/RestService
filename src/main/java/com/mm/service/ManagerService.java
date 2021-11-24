package com.mm.service;

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

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.type.MapLikeType;
import com.fasterxml.jackson.databind.type.TypeFactory;
import com.mm.mybatis.MyBatis;

@Path("/manager")
public class ManagerService extends BasicService {
	
	@POST
	@Path("/execSql")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.APPLICATION_JSON)
	public ServiceResult execSql(String json) {
		SqlSession session = null;
		ServiceResult r = new ServiceResult();
		try {
			ObjectMapper m = new ObjectMapper();
			TypeFactory fac = m.getTypeFactory();
			MapLikeType type = fac.constructMapLikeType(HashMap.class, String.class, String.class);
			Map<String, String> params = m.readValue(json, type);
			String sql = params.get("sql");
			
			Map<String, Object> rr = new HashMap<String, Object>();
			session  = MyBatis.getSession();
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
			rs.close();
			stmt.close();
			
			rr.put("heads", head);
			rr.put("datas", data);
			r.setSimpleData(rr);
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
