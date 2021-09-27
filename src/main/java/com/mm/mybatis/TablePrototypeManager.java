package com.mm.mybatis;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.ws.rs.PathParam;

import org.apache.ibatis.session.SqlSession;


public class TablePrototypeManager {
	public static class Table {
		public List<TablePrototype> protoList;
		public String tableName;
		public String queryColumns; // split columns by ,
	}
	
	// key: table name
	private static Map<String, Table> mTableMap = new HashMap<String, Table>();
	
	private TablePrototypeManager() {
	}
	
	public static Table findByName2(String tableName, SqlSession session) {
		Table item = mTableMap.get(tableName);
		if (item != null && item.protoList != null) {
			return item;
		}
		List<TablePrototype> u = session.selectList("com.mm.mybatis.TablePrototype.findByName", tableName);
		if (u != null) {
			item = new Table();
			item.tableName = tableName;
			item.protoList = u;
			item.queryColumns = buildQueryColumns(u);
			mTableMap.put(tableName, item);
		}
		return item;
	}
	
	public static List<TablePrototype> findByName(String tableName, SqlSession session) {
		Table item = findByName2(tableName, session);
		if (item != null) {
			return item.protoList;
		}
		return null;
	}
	
	public static void dirty(String tableName) {
		mTableMap.remove(tableName);
	}
	
	
	private static String buildQueryColumns(List<TablePrototype>  tp) {
		StringBuilder buf = new StringBuilder(256);
		buf.append(" _id ");
		for (TablePrototype p : tp) {
			// only show str column
			if (p._type == 2 && "str".equals(p._data_type)) {
				buf.append(" ,").append(p._name);
			}
		}
		return buf.toString();
	}
	
}
