<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<% 
response.addCookie(new javax.servlet.http.Cookie("SameSite", "None"));
response.addCookie(new javax.servlet.http.Cookie("Secure", ""));
%>
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" type="text/css" href="http://unpkg.com/view-design/dist/styles/iview.css">
    <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
    <script type="text/javascript" src="http://unpkg.com/view-design/dist/iview.min.js"></script>
  <script src="https://cdn.staticfile.org/axios/0.18.0/axios.min.js"></script>
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
	    width: 420px;
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
  
  </style>
</head>
<body>
<div id="app" class="layout">
    <div class="header" >
    	<i-Menu mode="horizontal" theme="dark" >
    		<div class="layout-logo"></div>
    		<div class="layout-nav">
	    		<Menu-Item name="1">
	                <Icon type="ios-navigate"></Icon>
	                Item 1
	            </Menu-Item>
            </div>
    	</i-Menu>
    </div>
    
    <div id='main-right-div' style="overflow: hidden;">
        <div class='menu'>
        	<i-Menu theme="dark" width="auto" mode="vertical" active-name='' @on-select= 'changeDept'>
        		<Menu-Item v-for="dept in deptInfos" :name="dept.id" :key = 'dept.id'  > 
        			{{dept.name}}
        		</Menu-Item>
        	</i-Menu>
        </div>
        
        <iframe id='main-iframe' src=''> </iframe>
        
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
    		  var dept = response.data.data;
    		  //console.log(dept);
    		  for (var i = 0; i < dept.length; ++i) {
    			  vm.deptInfos.push({id: dept[i].id, name: dept[i].name});
    		  }
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