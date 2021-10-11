package com.mm.service;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESKeySpec;
import javax.servlet.http.HttpServletRequest;
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

// No use this filter
@Provider
public class AuthDynamic implements DynamicFeature {

	@Override
	public void configure(ResourceInfo resourceInfo, FeatureContext context) {
		boolean isLogin = resourceInfo.getResourceClass() == UserService.class
				&& resourceInfo.getResourceMethod().getName().equals("login");
		boolean isApiPublic = resourceInfo.getResourceClass() == TableService.class
				&& resourceInfo.getResourceMethod().isAnnotationPresent(GET.class);
		boolean isInitSys = resourceInfo.getResourceClass() == InitSystem.class;

		if (!isLogin && !isApiPublic && !isInitSys) {
			context.register(AuthFilter.class);
		}
	}

	public static class AuthFilter implements ContainerRequestFilter, ContainerResponseFilter {
		// private static ThreadLocal lo = new ThreadLocal();
		
		@Context
		private HttpServletRequest mReq;
		
		@Override
		public void filter(ContainerRequestContext requestContext) throws IOException {
			// String path = requestContext.getUriInfo().getPath();
			// System.out.println("Filter request path: " + path);
			String token = requestContext.getHeaderString("Auth");

			Auth.Token auth = Auth.parseAuthToken(token);
			
			if (auth == null || !auth.isValid()) {
				BasicService.ServiceResult sr = new BasicService.ServiceResult();
				sr.fail("Auth Fail");
				Response r = Response.status(Response.Status.OK).entity(sr).build();
				requestContext.abortWith(r);
			} else {
				mReq.setAttribute("Auth.Token", auth);
			}
		}

		@Override
		public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext)
				throws IOException {
			// String path = requestContext.getUriInfo().getPath();
			// System.out.println("Filter response path: " + path);
			
			// 让浏览器能访问到其它响应头
			//responseContext.addHeader("Access-Control-Expose-Headers","Auth");
		}

	}
}
