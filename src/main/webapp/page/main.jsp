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
  <script src="https://cdn.bootcss.com/blueimp-md5/2.10.0/js/md5.min.js"></script>
  
</head>
<body>
<div id="app">
<v-app>


  <v-app-bar app clipped-left>
    <!-- -->
    top
  </v-app-bar>
	
	<!-- 左侧 -->
  <v-navigation-drawer app clipped>
    <v-expansion-panels focusable	 >
    <v-expansion-panel v-for="(dept,i) in deptInfos" :key="dept.name+i" >
      <v-expansion-panel-header>
        {{dept.name}}
      </v-expansion-panel-header>
      
      <v-expansion-panel-content>
      
        <v-list flat>
	      <v-list-item-group  color="primary" >
	      	<v-list-item>
		      	<v-list-item-content>
		      		<v-list-item-title v-text="'New Table'" :key="dept.id" @click="newTableOf(dept.id, dept.name)" ></v-list-item-title>
		      	</v-list-item-content>
	      	</v-list-item>
	        <v-list-item v-for="(t, i) in dept.tableInfos"  :key="t._name+i" >
	          <v-list-item-content>
	            <v-list-item-title v-text="t._name_cn" @click="changeTable(t._id, t._name_cn, t._name)" ></v-list-item-title>
	          </v-list-item-content>
	        </v-list-item>
	      </v-list-item-group>
    	</v-list>
    	
      </v-expansion-panel-content>
    </v-expansion-panel>
  </v-expansion-panels>
  </v-navigation-drawer>

  <!-- 根据应用组件来调整你的内容 -->
  <v-main>
    <!-- 给应用提供合适的间距 -->
    <v-container fluid>
    
    	<!--  Table Info Page -->
      <template v-if = "showType == 1 ">
        <v-tabs v-model="tab" align-with-title dark background-color="indigo">
          <v-tabs-slider color="yellow"></v-tabs-slider>
          <v-tab v-for="item in curTableInfo" :key="item.text" >
            {{ item.text }}
          </v-tab>
        </v-tabs>
      
	      <v-tabs-items v-model="tab">
	      	<v-tab-item v-for="item in curTableInfo" :key="item.text">
	      		<v-card flat>
	      			<v-card-text v-text="item.text"></v-card-text>
	      		</v-card>
	      	</v-tab-item>
	      </v-tabs-items>
      </template>
      
      <!-- New Table Page -->
      <template v-else-if = "showType == 2 " >
      	<%@ include file = "main-new-table.jsp" %>
      </template>
      
    </v-container>
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
    	  curTableInfo : [{text: '表结构'}, {text: ''}],
    	  tab: null,
    	  showType: 0,
    	  
    	  // for new table
    	  newTableInfo: {deptName:'', deptId:0, tabName: '',  tabNameMD5: '', alreadyCreateColumns: [], 
    		  			add: {_name_cn:'', _name:'_c01', _data_type:'str', _max_len:'100'},
    					showAlert: false, alertType: 'success', alertText:'' , colNum : 0},
      },
      
      mounted: function() {
    	  var vm = this;
    	  axios.get("<%=request.getContextPath()%>/rest/department").then(function (response) {
    		  var dept = response.data.data;
    		  console.log(dept);
    		  axios.get("<%=request.getContextPath()%>/rest/tableprototype/table").then(function (res) {
    			  var t = res.data.data;
    			  console.log(res);
    			  for (var i = 0; i < dept.length; ++i) {
    				  var obj = {id: dept[i].id, name: dept[i].name, tableInfos: []};
    				  for (var j = 0; j < t.length; ++j) {
    					  if (t[j]._dept_id == dept[i].id) {
    						  obj.tableInfos.push({_id: t[j]._id, _name: t[j]._name, _name_cn: t[j]._name_cn});
    					  }
    				  }
        			  vm.deptInfos.push(obj);
        		  }
        	  });
    	  });
    	  
      },
      
      methods : {
    	  newTableOf: function(deptId, deptName) {
    		  // alert(deptId + ',' + deptName);
    		  // reset new table ui
    		  this.newTableInfo.tabName = '';
    		  this.newTableInfo.tabNameMD5 = '';
    		  this.newTableInfo.alreadyCreateColumns.splice(0, this.newTableInfo.alreadyCreateColumns.length);
    		  this.newTableInfo.add._name_cn = '';
    		  this.newTableInfo.add._name = '_c01';
    		  this.newTableInfo.add._data_type = 'str';
    		  this.newTableInfo.add._max_len = '100';
    		  this.newTableInfo.showAlert = false;
    		  
    		  this.newTableInfo.deptName = deptName;
    		  this.newTableInfo.deptId = deptId;
    		  this.showType = 2;
    	  },
    	  
    	  changeTable: function(tabId, tabName, tabNameCN) {
    		  this.showType = 1;
    		  this.curTableInfo[1].text = tabName;
    	  },
    	  
    	  newTableToServer: function() {
    		  var vm = this
    		  param = [{_name_cn: this.newTableInfo.tabName, _name: this.newTableInfo.tabNameMD5, _type: 1, 
    			  		_owner: this.newTableInfo.tabNameMD5, _dept_id: this.newTableInfo.deptId}];
    		  axios.post("<%=request.getContextPath()%>/rest/tableprototype", param).then(function(res) {
    			  var d = res.data;
    			  if (d.status == 'OK') {
    				  vm.newTableInfo.alertType = 'success';
    				  vm.newTableInfo.alertText = 'Create Table Success';
    				  vm.newTableInfo.showAlert = true;
    			  } else {
    				  vm.newTableInfo.alertType = 'error';
    				  vm.newTableInfo.alertText = 'Create Table Fail: ' + d.msg;
    				  vm.newTableInfo.showAlert = true;
    			  }
    		  }).catch(function (error) {
    			  vm.newTableInfo.alertType = 'error';
    			  vm.newTableInfo.alertText = 'Create Table Fail: ' + error;
    			  vm.newTableInfo.showAlert = true;
    		  });
    	  },
    	  
    	  newColumnToServer: function() {
    		  param = {_name_cn: this.newTableInfo.add._name_cn, _name: this.newTableInfo.add._name, 
    				  _type: 2, _data_type: this.newTableInfo.add._data_type, 
    				  _max_len: this.newTableInfo.add._max_len, _owner: this.newTableInfo.tabNameMD5};
    		  var vm = this
    		  axios.post("<%=request.getContextPath()%>/rest/tableprototype", [param]).then(function(res) {
    			  var d = res.data;
    			  if (d.status == 'OK') {
    				  vm.newTableInfo.alertType = 'success';
    				  vm.newTableInfo.alertText = 'Create Column Success';
    				  vm.newTableInfo.showAlert = true;
    				  vm.newTableInfo.colNum++;
    				  vm.newTableInfo.add._name = '_c' + (vm.newTableInfo.colNum + 1);
    				  vm.newTableInfo.add._name_cn = '';
    				  
    				  vm.newTableInfo.alreadyCreateColumns.push(param);
    			  } else {
    				  vm.newTableInfo.alertType = 'error';
    				  vm.newTableInfo.alertText = 'Create Column Fail: ' + d.msg;
    				  vm.newTableInfo.showAlert = true;
    			  }
    		  }).catch(function (error) {
    			  vm.newTableInfo.alertType = 'error';
    			  vm.newTableInfo.alertText = 'Create Column Fail: ' + error;
    			  vm.newTableInfo.showAlert = true;
    		  });
    	  }
      },
      
      watch: {
      }
    });
    
    vm.$watch('newTableInfo.tabName', function (newVal, oldVal) {
    	if (newVal != '') this.newTableInfo.tabNameMD5 = '' + md5(newVal);
    	else  this.newTableInfo.tabNameMD5 = '';
    });
    
  
  </script>
</body>
</html>