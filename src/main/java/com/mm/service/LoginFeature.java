package com.mm.service;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.ws.rs.GET;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import javax.ws.rs.container.DynamicFeature;
import javax.ws.rs.container.ResourceInfo;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.FeatureContext;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.Provider;

import com.mm.mybatis.User;
import com.mm.service.AuthDynamic.AuthFilter;

// No use this filter
@Provider
public class LoginFeature implements DynamicFeature {
	
	@Override
	public void configure(ResourceInfo resourceInfo, FeatureContext context) {
		boolean isLogin = resourceInfo.getResourceClass() == UserService.class
				&& resourceInfo.getResourceMethod().getName().equals("login");
		boolean isApiPublic = resourceInfo.getResourceClass() == TableService.class
				&& resourceInfo.getResourceMethod().isAnnotationPresent(GET.class);
		boolean isInitSys = resourceInfo.getResourceClass() == InitSystem.class;

		if (!isLogin && !isApiPublic && !isInitSys) {
			context.register(LoginFilter.class);
		}
	}

	public static class LoginFilter implements ContainerRequestFilter, ContainerResponseFilter {
		@Context private HttpServletRequest mRequest;
		
		@Override
		public void filter(ContainerRequestContext requestContext) throws IOException {
			HttpSession session = mRequest.getSession(false);
			if (session == null) {
				failRequest(requestContext);
				return;
			}
			User u = (User)session.getAttribute("user");
			if (u == null) {
				failRequest(requestContext);
			}
		}
		
		void failRequest(ContainerRequestContext requestContext) {
			BasicService.ServiceResult sr = new BasicService.ServiceResult();
			sr.fail("Auth Fail");
			Response r = Response.status(Response.Status.OK).entity(sr).build();
			requestContext.abortWith(r);
		}
		
		@Override
		public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext)
				throws IOException {
		}
		
	}
}
