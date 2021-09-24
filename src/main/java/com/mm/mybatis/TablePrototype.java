package com.mm.mybatis;

public class TablePrototype {
	public long _id;
	public int _type;  // 1: table name, 2: column, ¡¾3: is build db table? save 'true' or 'false' in _name column¡¿
	public String _name;
	public String _name_cn;
	public String _data_type;  // 4bytes: 'file' or 'str' or 'lstr' (long str)
	public int _max_len;  // default 250
	public String _owner; // is table name for column type
	public String _html;  // 250 bytes limit
}
