package com.mm.service;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESKeySpec;

public class Auth {
	private static final byte[] KEY = "auth-x-key-token-restservice".getBytes();
	
	public static class Token {
		public String userName;
		public long time;
		
		public boolean isValid() {
			if (userName == null || userName.length() == 0) {
				return false;
			}
			
			long curTime = System.currentTimeMillis() / 1000;
			// 过期时间 30 天
			return curTime < time + 30 * 24 * 3600;
		}
		
		public boolean isPublicUser() {
			return "public".equals(userName);
		}
		
		public String toString() {
			return "userName=" + userName + ", time=" + time;
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
		
		try {
			byte[] bytes = buf.toString().getBytes("utf-8");
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
			byte[] org = Base64.getDecoder().decode(auth);
			byte[] db = decrypt(org, KEY);
			String data = new String(db, "utf-8");
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
		Cipher cipher = Cipher.getInstance("DES/ECB/PKCS5Padding");
		cipher.init(Cipher.ENCRYPT_MODE, securekey, sr);
		return cipher.doFinal(data);
	}

	private static byte[] decrypt(byte[] data, byte[] key) throws Exception {
		SecureRandom sr = new SecureRandom();
		DESKeySpec dks = new DESKeySpec(key);
		SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("DES");
		SecretKey securekey = keyFactory.generateSecret(dks);
		Cipher cipher = Cipher.getInstance("DES/ECB/PKCS5Padding");
		cipher.init(Cipher.DECRYPT_MODE, securekey, sr);
		return cipher.doFinal(data);
	}
}
