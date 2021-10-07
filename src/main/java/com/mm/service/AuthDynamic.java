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
// @Provider
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
		private static ThreadLocal lo = new ThreadLocal();
		
		@Context
		private HttpServletRequest mReq;
		
		@Override
		public void filter(ContainerRequestContext requestContext) throws IOException {
			String path = requestContext.getUriInfo().getPath();
			System.out.println("Filter request path: " + path);
			String token = requestContext.getHeaderString("Token");

			Auth.Token auth = Auth.parseAuthToken(token);
			
			if (auth == null || !auth.valid()) {
				BasicService.ServiceResult sr = new BasicService.ServiceResult();
				sr.fail("Auth Fail");
				Response r = Response.status(Response.Status.OK).entity(sr).build();
				requestContext.abortWith(r);
			} else {
				lo.set(auth);
			}
		}

		@Override
		public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext)
				throws IOException {
			String path = requestContext.getUriInfo().getPath();
			System.out.println("Filter response path: " + path);
			lo.remove();
		}

	}

	public static class Auth {
		private static final byte[] KEY = "auth-x".getBytes();
		
		public static class Token {
			String userName;
			long time;
			
			public boolean valid() {
				if (userName == null || userName.length() == 0) {
					return false;
				}
				long curTime = System.currentTimeMillis() / 1000;
				// 过期时间24h
				return curTime > time + 24 * 3600;
			}
		}
		
		private static MessageDigest getMD5() {
			try {
				return MessageDigest.getInstance("MD5");
			} catch (NoSuchAlgorithmException e) {
				e.printStackTrace();
			}
			return null;
		}

		public static String buildAuthToken(String userName) {
			if (userName == null || userName.length() == 0) {
				return null;
			}
			StringBuilder buf = new StringBuilder();
			buf.append("User: ").append(userName).append("\n");
			buf.append("Time: ").append(System.currentTimeMillis() / 1000);
			byte[] bytes = buf.toString().getBytes();
			try {
				byte[] e = encrypt(bytes, KEY);
				String b = Base64.getEncoder().encodeToString(e);
				return b;
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		public static Token parseAuthToken(String auth) {
			if (auth == null || auth.length() == 0) {
				return null;
			}
			try {
				byte[] db = decrypt(auth.getBytes(), KEY);
				String data = new String(db);
				Token token = new Token();
				String[] dds = data.split("\n");
				for (String s : dds) {
					if (s.startsWith("User: ")) {
						token.userName = s.substring(6);
					} else if (s.startsWith("Time: ")) {
						token.time = Long.parseLong(s.substring(6));
					}
				}
				return token;
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		private static byte[] encrypt(byte[] data, byte[] key) throws Exception {
			SecureRandom sr = new SecureRandom();
			DESKeySpec dks = new DESKeySpec(key);
			SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
			SecretKey securekey = keyFactory.generateSecret(dks);
			Cipher cipher = Cipher.getInstance("DES");
			cipher.init(Cipher.ENCRYPT_MODE, securekey, sr);
			return cipher.doFinal(data);
		}

		private static byte[] decrypt(byte[] data, byte[] key) throws Exception {
			SecureRandom sr = new SecureRandom();
			DESKeySpec dks = new DESKeySpec(key);
			SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
			SecretKey securekey = keyFactory.generateSecret(dks);
			Cipher cipher = Cipher.getInstance("DES");
			cipher.init(Cipher.DECRYPT_MODE, securekey, sr);
			return cipher.doFinal(data);
		}
	}
}
