<%@page import="com.mm.service.Auth"%>
<%@page import="com.mm.mybatis.User"%>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<% 
response.addCookie(new javax.servlet.http.Cookie("SameSite", "None"));
response.addCookie(new javax.servlet.http.Cookie("Secure", ""));
%>
<!DOCTYPE html>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="../iview/styles/iview.css">
	<script src="../js/vue.js"></script>
	<script src="../js/axios.min.js"></script>
	<script src="../iview/iview.min.js"></script>

  <!-- link rel="stylesheet" type="text/css" href="http://unpkg.com/view-design/dist/styles/iview.css">
    <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
    <script type="text/javascript" src="http://unpkg.com/view-design/dist/iview.min.js"></script>
  <script src="https://cdn.staticfile.org/axios/0.18.0/axios.min.js"></script -->
  
  <script src="../js/auth.js?v"></script>
  <style>
	.layout {
	    border: 0px solid #d7dde4;
	    background: #f5f7f9;
	    position: relative;
	    overflow: hidden;
	}
	.menu {
		width: 240px; 
		height:100%; 
		overflow: auto;
		border-bottom: 1px solid #d7dde4;
		border-top: 1px solid #d7dde4;
		float: left;
	}
	.header {
		border-bottom: 0px solid #d7dde4;
	}
	.layout-logo {
	    width: 100px;
	    height: 30px;
	    background: #5b6270;
	    border-radius: 3px;
	    float: left;
	    position: relative;
	    top: 15px;
	    left: 20px;
	}
	.layout-nav {
	    width: 220px;
	    margin: 0 auto;
	    margin-right: 20px;
	}
	.layout-footer-center{
	    text-align: center;
	    width:100%;
	    background-color:#515A6E;
	    color:#fff;
	}
	body::-webkit-scrollbar {
	  display--x: none; /* Chrome Safari */
	}
	
	#main-iframe {
		border: 0;
		width: calc(100% - 240px);
	}
  	.head-title {
  		color: #ddd;
  		font-size: 20px;
  		position: relative;
	    left: 50px;
	    margin: auto 0;
	    float: left;
  	}
  </style>
</head>
<body>
<div id="app" class="layout">
    <div class="header" >
    	<i-Menu mode="horizontal" theme="dark" >
    		<div class="layout-logo"></div>
    		<div class='head-title'> 政务数据共享服务平台</div>
    		<div class="layout-nav">
    		<%
    			String userName = (String)session.getAttribute("userName");
    		    if (userName == null) {
    		%>
	    		<Menu-Item name="1">
	                <Icon type="ios-navigate"></Icon>
	                <a href = "login.jsp"> Login </a>
	            </Menu-Item>
	            <% } %>
	            
	            <Menu-Item name="1">
	                <Icon type="ios-navigate"></Icon>
	                <a href = "manager.jsp" target='main-iframe'> Manager </a>
	            </Menu-Item>
	            
	            <% 
	               if ("admin".equals(userName)) {
	            %>
	            <Menu-Item name="1">
	                <Icon type="ios-navigate"></Icon>
	                <a href = "list-user.jsp" target='main-iframe'> User </a>
	            </Menu-Item>
	            <% } %>
            </div>
    	</i-Menu>
    </div>
    
    <div id='main-right-div' style="overflow: hidden;">
        <div class='menu'>
        	<i-Menu theme="dark" width="auto" mode="vertical" active-name='' @on-select= 'changeDept'>
        		<Menu-Item v-for="dept in deptInfos" :name="dept.id" :key = 'dept.id'  > 
        			{{dept.name}} &nbsp;&nbsp;
        			<span v-if="dept.count != 0" > ({{dept.count}}) </span>
        		</Menu-Item>
        	</i-Menu>
        </div>
        
        <iframe id='main-iframe' name='main-iframe' src=''> </iframe>
        
    </div>
    
    <div class="layout-footer-center" theme="dark">2021-2026 &copy; TalkingData</div>
</div>

</div>
 
  <script>
    var vm = new Vue({
      el: '#app',
      data : {
    	  deptInfos : [],
    	  tab: null,
      },
      
      mounted: function() {
    	  var cntHeight = window.innerHeight - 60 - 22;
    	  document.getElementById('main-right-div').style.height = '' + cntHeight + 'px';
    	  document.getElementById('main-iframe').style.height = '' + cntHeight + 'px';
    	  
    	  var vm = this;
    	  axios.get("<%=request.getContextPath()%>/rest/department").then(function (response) {
    		  var d = response.data;
    		  if (d.status != "OK") {
    			  if (d.msg == "Auth Fail") {
    				  window.location = 'login.jsp';
    			  }
    			  return;
    		  }
    		  var dept = d.data;
    		  // console.log(dept);
    		  for (var i = 0; i < dept.length; ++i) {
    			  vm.deptInfos.push({id: dept[i].id, name: dept[i].name, count: 0});
    		  }
    		  
    		  axios.get("<%=request.getContextPath()%>/rest/tableprototype/count").then(function (response) {
    			  var dc = response.data;
    			  // console.log(dc);
    			  for (var n = 0; n < dc.data.length; ++n) {
    				  for (var i = 0; i < vm.deptInfos.length; ++i) {
            			  if (vm.deptInfos[i].id == dc.data[n]._dept_id) {
            				  vm.deptInfos[i].count = dc.data[n]._count;
            			  }
            		  }
    			  }
    			  // console.log(vm.deptInfos);
    		  });
    	  });
      },
      
      methods : {
    	  changeDept: function(id) {
    		  for (var i = 0; i < this.deptInfos.length; ++i) {
    			  var d = this.deptInfos[i];
    			  if (d.id == id) {
    				  var name = d.name;
    				  var url = 'main-right.jsp?deptId='+id+"&deptName="+encodeURIComponent(name);
    				  document.getElementById('main-iframe').src = url;
    			  }
    		  }
    	  },
      },
    });
    
  </script>
</body>
</html>