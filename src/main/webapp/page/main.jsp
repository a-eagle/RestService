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
  
</head>
<body style="overflow:hidden;">
<div id="app" style="overflow:hidden;">
<v-app>


  <v-app-bar app clipped-left>
    <!-- -->
    top
  </v-app-bar>
	
	<!-- 左侧 -->
  <v-navigation-drawer app clipped>
    <v-expansion-panels focusable	 >
    <v-expansion-panel v-for="(dept,i) in deptInfos" :key="dept.name+i" >
      <v-expansion-panel-header @click="changeDept(dept.id, dept.name)" >
        {{dept.name}}
      </v-expansion-panel-header>
      
      <v-expansion-panel-content>
      
      </v-expansion-panel-content>
    </v-expansion-panel>
  </v-expansion-panels>
  </v-navigation-drawer>

  <!-- 根据应用组件来调整你的内容 -->
  <v-main>
    <!-- 给应用提供合适的间距  -->
    <iframe id='main-right' style="width:100%; height:100%; border:0; overflow: hidden; " src=''> </iframe>
    
  </v-main>

	<!--底部 -->
  <v-footer app>
    bottom
  </v-footer>
</v-app>
</div>

 
  <script>
    var vm = new Vue({
      el: '#app',
      vuetify: new Vuetify(),
      data : {
    	  deptInfos : [],
    	  // curTableInfo : [{text: '表结构'}, {text: ''}],
    	  tab: null,
    	  
    	  // for new table
    	  /* newTableInfo: {deptName:'', deptId:0, tabName: '',  tabNameMD5: '', alreadyCreateColumns: [], 
    		  			add: {_name_cn:'', _name:'_c01', _data_type:'str', _max_len:'100'},
    					showAlert: false, alertType: 'success', alertText:'' , colNum : 0}, */
      },
      
      mounted: function() {
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
    	  changeDept: function(id, name) {
    		  document.getElementById('main-right').src = 'main-right.jsp?deptId='+id+"&deptName="+encodeURIComponent(name);
    	  },
      },
    });
    
    /* vm.$watch('newTableInfo.tabName', function (newVal, oldVal) {
    	if (newVal != '') this.newTableInfo.tabNameMD5 = '' + md5(newVal);
    	else  this.newTableInfo.tabNameMD5 = '';
    }); */
    
  
  </script>
</body>
</html>