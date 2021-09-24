package com.mm.service;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import com.mm.mybatis.MyBatis;

@Path("/init-system")
public class InitSystem {
	
	@GET
	@Produces(MediaType.TEXT_PLAIN)
	public String get() {
		boolean ok = MyBatis.initSystem();
		return "init system " + (ok ? "success" : "fail");
	}
	
}
