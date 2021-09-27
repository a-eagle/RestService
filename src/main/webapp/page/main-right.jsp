<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<% 
response.addCookie(new javax.servlet.http.Cookie("SameSite", "None"));
response.addCookie(new javax.servlet.http.Cookie("Secure", ""));
%>
<!DOCTYPE html>
<html>
<head>
  <link href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/@mdi/font@4.x/css/materialdesignicons.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.min.css" rel="stylesheet">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui">
  
  <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.js"></script>
  <script src="https://cdn.staticfile.org/axios/0.18.0/axios.min.js"></script>
   <script>
  
  	var deptId = '<%=request.getParameter("deptId")%>';
  	var deptName = '<%=request.getParameter("deptName")%>';
  	var deptNameEncode = encodeURIComponent(deptName);
  </script>
  <style>
  
  body::-webkit-scrollbar {
	  display: none; /* Chrome Safari */
	}
  
  </style>
</head>
<body >
<div id='app' style=" margin:  0px 20px;" >
<v-app style="overflow:hidden;" >
  <!-- 根据应用组件来调整你的内容 -->
  
    <!-- 给应用提供合适的间距 -->
    <h3>
    	<br/>
    	【<%=request.getParameter("deptName") %>】
    </h3>
    <!--  Table Info Page -->
    <div style="width:100%; height: 50px;"> 
       <v-tabs v-model="tab" align-with-title dark background-color="indigo"  >
         <v-tabs-slider color="yellow"></v-tabs-slider>
         <v-tab v-for="item in tabsInfo" :key="item.text" >
           {{ item.text }}
         </v-tab>
       </v-tabs>
      </div>
      <br/>
      <v-main>
	      <v-tabs-items v-model="tab">
	      	<v-tab-item v-for="item in tabsInfo" :key="item.url">
	      		<v-card flat>
	      			<iframe style="width:100%; height:600px; border:0; overflow: hidden; " :src='item.url'> </iframe>
	      		</v-card>
	      	</v-tab-item>
	      </v-tabs-items>
 	  </v-main>

</v-app>
</div>
 
  <script>
    var vm = new Vue({
      el: '#app',
      vuetify: new Vuetify(),
      data : {
    	  tabsInfo : [
    		  {text: '所属表', url:'list-table.jsp?deptId=' + deptId }, 
    		  {text: '新建表', url:'add-table.jsp?deptId=' + deptId + '&deptName=' + deptNameEncode},
    		],
    	  tab: null,
      },
      
      methods : {
    	  // item = {text:'', url:'' }
    	  addTab: function(item) {
    		  for (var i = 0; i < this.tabsInfo.length; ++i) {
    			  if (this.tabsInfo[i].url == item.url) {
    				  this.tab = i;
    				  return;
    			  }
    		  }
    		  
    		  this.tabsInfo.push(item);
    		  this.tab = this.tabsInfo.length - 1;
    	  }
      },
    });
    
    /* vm.$watch('newTableInfo.tabName', function (newVal, oldVal) {
    	if (newVal != '') this.newTableInfo.tabNameMD5 = '' + md5(newVal);
    	else  this.newTableInfo.tabNameMD5 = '';
    }); */
    
  
  </script>
</body>
</html>