package com.mm.service;

import java.io.InputStream;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.FormParam;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Form;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.MultivaluedMap;
import javax.ws.rs.core.UriInfo;

import org.glassfish.jersey.media.multipart.FormDataContentDisposition;
import org.glassfish.jersey.media.multipart.FormDataParam;


@Path("/db/{ww}")
public class Hello {
	
	@GET
	@Produces(MediaType.TEXT_PLAIN)
	public String get(@PathParam("ww") String name) {
		String r = "get, db is :" + name; 
		System.out.println(r);
		return r;
	}
	
	@POST
	@Consumes(MediaType.MULTIPART_FORM_DATA)
	@Produces(MediaType.APPLICATION_JSON)
	public String addMultiPart(@PathParam("ww") String ww,  Form obj) {
		
		return "post multi part, db = " + ww;
	}
	
	  @POST
	  @Path("importFile")
	  @Consumes(MediaType.MULTIPART_FORM_DATA)
	  @Produces(MediaType.APPLICATION_JSON)
	  public String importForFile(@FormDataParam("file") String fileString,
	                                         @FormDataParam("file") InputStream fis,
	                                         @FormDataParam("file") FormDataContentDisposition fileDisposition) {
	    // TODO
	    return "import file ok";
	  }

	
	@POST
	@Consumes(MediaType.APPLICATION_FORM_URLENCODED)
	@Produces(MediaType.APPLICATION_JSON)
	public String add(@PathParam("ww") String ww, @Context UriInfo uri, MultivaluedMap<String, String> formParams) {
		Set<String> keys = formParams.keySet();
		System.out.println(keys);
		for (String k : keys) {
			List<String> v = formParams.get(k);
			System.out.println(k + "=" + v);
		}
		
		return "post, db = " + ww;
	}
	
	/*
	@POST
	@Consumes(MediaType.APPLICATION_FORM_URLENCODED)
	public String post(@PathParam("ww") String ww, String content) {
		System.out.println(content);
		return "post 2, db = " + ww + content;
	}
	*/
	
	@PUT
	@Path("/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public String update(@PathParam("ww") String ww, @PathParam("id") String id, @FormParam("name") String name) {
		String r = "put, db = " + ww + " ,id=" + id + " ,name=" + name;
		System.out.println(r);
		
		return "put, db = " + ww + " ,id=" + id + " ,name=" + name;
	}
	
	@DELETE
	@Path("/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public String delete(@PathParam("ww") String ww, @PathParam("id") String id) {
		return "delete, db = " + ww + " , id=" + id;
	}
	
}
