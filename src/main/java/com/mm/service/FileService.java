package com.mm.service;

import java.io.InputStream;
import java.util.Calendar;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.glassfish.jersey.media.multipart.FormDataContentDisposition;
import org.glassfish.jersey.media.multipart.FormDataParam;

@Path("/file")
public class FileService {
	
	// 18 byte length yyyyMMDDHHMMSS_xxx
	public static synchronized String genFileId() {
		java.util.Date now = new java.util.Date();
		Calendar c = Calendar.getInstance();
		StringBuilder id =  new StringBuilder(50);
		id.append(c.get(Calendar.YEAR)).append(c.get(Calendar.MONTH) + 1).append(c.get(Calendar.DAY_OF_MONTH));
		id.append(c.get(Calendar.HOUR_OF_DAY)).append(c.get(Calendar.MINUTE)).append(c.get(Calendar.SECOND));
		id.append('_').append(c.get(Calendar.MILLISECOND));
		return id.toString();
	}
	
	@POST
	@Path("/upload")
	@Consumes(MediaType.MULTIPART_FORM_DATA)
	@Produces(MediaType.APPLICATION_JSON)
	public String upload(@FormDataParam("file") String fileString, @FormDataParam("file") InputStream fis,
			@FormDataParam("file") FormDataContentDisposition fileDisposition) {
		System.out.println(fileString);
		// TODO
		return "{fileId:}";
	}

	@GET
	@Path("/download/{file-id}")
	@Produces(MediaType.APPLICATION_OCTET_STREAM)
	public Response download(@PathParam("file-id") String fileId) {
		
		
		// TODO
		return null;
	}

}
