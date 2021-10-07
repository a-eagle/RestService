package com.mm.service;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.ws.rs.core.Context;

import com.mm.mybatis.User;

public class BasicService {
	@Context protected HttpServletRequest mRequest;
	
	public User getRequestUser() {
		HttpSession s = mRequest.getSession(false);
		if (s != null) {
			return (User)s.getAttribute("user");
		}
		return null;
	}
	
	public void setRequestUser(User u) {
		HttpSession s = mRequest.getSession(true);
		s.setAttribute("user", u);
	}
	
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
