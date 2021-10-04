package com.mm.mybatis;

import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.ExecutorType;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

public class MyBatis {
	private static SqlSessionFactory mFactory;
	private static boolean mInited;
	
	private static void init() {
		mInited = true;
		String resource = "mybatis-config.xml";// 通过流处理获取sqlSessionFactory创建一个实例
		InputStream inputStream;
		try {
			inputStream = Resources.getResourceAsStream(resource);
			mFactory = new SqlSessionFactoryBuilder().build(inputStream);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static SqlSession getSession() {
		if (! mInited) {
			init();
		}
		
		return mFactory.openSession(false);
	}
	
	public static SqlSession getBatchSession() {
		if (! mInited) {
			init();
		}
		return mFactory.openSession(ExecutorType.BATCH, false);
	}
}
