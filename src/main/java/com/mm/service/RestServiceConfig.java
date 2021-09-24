package com.mm.service;

import javax.ws.rs.ApplicationPath;

import org.glassfish.jersey.media.multipart.MultiPartFeature;
import org.glassfish.jersey.server.ResourceConfig;

@ApplicationPath("/rest")
public class RestServiceConfig extends ResourceConfig {
	public RestServiceConfig() {
		packages("com.mm.service");
	    register(MultiPartFeature.class);
	}
}
