package com.mm.service;

import java.util.List;

public class BasicService {
	
	public static class ServiceResult {
		public String status;  //  OK ,FAIL
		public String msg;
		public Object headers;
		public int count;
		public Object data;
		
		public ServiceResult() {
			status = "OK";
		}
		
		public ServiceResult(String code, String msg, Object data) {
			this.status = code;
			this.msg = msg;
			this.data = data;
		}
		
		public void fail(String msg) {
			this.status = "FAIL";
			this.msg = msg;
		}
		
		public void setListData(List list) {
			data = list;
			if (list != null) {
				count = list.size();
			}
		}
		
		public void setSimpleData(Object obj) {
			data = obj;
			if (obj != null) {
				count = 1;
			}
		}
	}
	
}
