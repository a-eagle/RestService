package com.mm.service;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.ws.rs.core.Context;

import org.apache.ibatis.session.SqlSession;

import com.mm.mybatis.User;
import com.mm.service.Auth.Token;

public class BasicService {
	@Context protected HttpServletRequest mRequest;
	
	public Auth.Token getRequestAuth() {
		Token t = (Token) mRequest.getAttribute("Auth.Token");
		if (t == null) {
			t = (Token) mRequest.getSession().getAttribute("Auth.Token");
		}
		return t;
	}
	
	public void setRequestAuth(Auth.Token token) {
		mRequest.setAttribute("Auth.Token", token);
		mRequest.getSession(true).setAttribute("Auth.Token", token);
	}
	
	public void setRequestUser(User u) {
		mRequest.getSession(true).setAttribute("user", u);
	}
	
	public User getUser() {
		return (User)mRequest.getSession().getAttribute("user");
	}
	
	public boolean saveLogger(SqlSession session, String operation, boolean commit) {
		User u = getUser();
		if (u != null) {
			return LoggerService.save(session, u.name, operation, commit);
		}
		return false;
	}
	
	public boolean isUserCertified() {
		Auth.Token u = getRequestAuth();
		if (u != null && u.isValid()) {
			return true;
		}
		return false;
	}
	
	public static class ServiceResult {
		public String status;  //  OK ,FAIL
		public String msg;
		public Object headers;
		public int count;
		public Object data;
		
		public ServiceResult() {
			status = "OK";
			msg = "success";
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
