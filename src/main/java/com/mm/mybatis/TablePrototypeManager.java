package com.mm.mybatis;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.ws.rs.PathParam;

import org.apache.ibatis.session.SqlSession;


public class TablePrototypeManager {
	public static class Table {
		
		public static class Header {
			public String name;
			public String text;
			public Header(String n, String t) {
				name = n;
				text = t;
			}
		}
		
		public List<TablePrototype> protoList;
		public String tableName;
		public String queryColumns; // split columns by ,
		public String dataColumns; // all data columns
		public List<Header> queryHeaders;
		public List<Header> dataHeaders;
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
			item.dataColumns = buildDataColumns(u);
			item.queryHeaders = buildQueryHeaders(u);
			item.dataHeaders = buildDataHeaders(u);
			// mTableMap.put(tableName, item);
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
		// mTableMap.remove(tableName);
	}
	
	
	private static String buildQueryColumns(List<TablePrototype>  tp) {
		StringBuilder buf = new StringBuilder(256);
		buf.append(" _id ");
		for (TablePrototype p : tp) {
			// only show str column
			if (p._type == TablePrototype.TYPE_COLUMN && "str".equals(p._data_type)) {
				buf.append(" ,").append(p._name);
			}
		}
		return buf.toString();
	}
	
	private static String buildDataColumns(List<TablePrototype>  tp) {
		StringBuilder buf = new StringBuilder(256);
		boolean first = true;
		for (TablePrototype p : tp) {
			if (p._type == TablePrototype.TYPE_COLUMN) {
				if (! first) buf.append(" ,");
				first = false;
				buf.append(p._name);
			}
		}
		return buf.toString();
	}
	
	private static List<Table.Header> buildQueryHeaders(List<TablePrototype> tps) {
		List<Table.Header> headers = new ArrayList<TablePrototypeManager.Table.Header>();
		headers.add(new Table.Header("_id", "ID"));
		
		for (TablePrototype tp : tps) {
			if (tp._type == TablePrototype.TYPE_COLUMN && "str".equals(tp._data_type)) {
				headers.add(new Table.Header(tp._name, tp._name_cn));
			}
		}
		return headers;
	}
	
	private static List<Table.Header> buildDataHeaders(List<TablePrototype> tps) {
		List<Table.Header> headers = new ArrayList<TablePrototypeManager.Table.Header>();
		
		for (TablePrototype tp : tps) {
			if (tp._type == TablePrototype.TYPE_COLUMN) {
				headers.add(new Table.Header(tp._name, tp._name_cn));
			}
		}
		return headers;
	}
}
