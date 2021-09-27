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


<v-row justify="space-around">
	<v-col cols="10"  md="4">  <v-text-field label="表名（中文）：" v-model.trim = 'tabName' > </v-text-field>  </v-col>
	<v-col cols="10"  md="4">  <v-text-field label="表名MD5：" v-model = 'tabNameMD5' readonly> </v-text-field>  </v-col>
	<v-col cols="2"  md="1"> <v-btn block @click="newTableToServer" > 创建表  </v-btn>  </v-col>
</v-row>

<v-alert v-model="showAlert" border="left" close-text="Close Alert" color="green" elevation = 4 text :type = "alertType"  dismissible >
	{{alertText}}
</v-alert>

<v-row justify="space-around">
	<v-col > 列名（中文）  </v-col>
	<v-col > 列名(英文)  </v-col>
	<v-col > 数据类型 </v-col>
	<v-col > 最大长度 </v-col>
	<v-col cols="2"  md="1">  </v-col>
</v-row>

<v-row justify="space-around" v-for = 'c in alreadyCreateColumns' :key = "c._name" >
	<v-col > {{c._name_cn}}  </v-col>
	<v-col > {{c._name}}  </v-col>
	<v-col > {{c._data_type}}  </v-col>
	<v-col > {{c._max_len}}  </v-col>
	<v-col cols="2"  md="1">  </v-col>
</v-row>


<v-row justify="space-around">
	<v-col > <v-text-field v-model.trim = 'add._name_cn' >  </v-col>
	<v-col > <v-text-field  v-model.trim = 'add._name' > </v-col>
	<v-col > <v-text-field   v-model.trim = 'add._data_type' > </v-col>
	<v-col > <v-text-field   v-model.trim = 'add._max_len' > </v-col>
	<v-col cols="2"  md="1" @click="newColumnToServer">  <v-btn block> 创建列  </v-btn> </v-col>
</v-row>

</v-app>
</div>
<script>
    var vm = new Vue({
      el: '#app',
      vuetify: new Vuetify(),
      data : {
    	  // for new table
    	  deptName: '<%=request.getParameter("deptName")%>', deptId : '<%=request.getParameter("deptId")%>',
    	  tabName: '',  tabNameMD5: '', 
    	  alreadyCreateColumns: [], 
    	  add: {_name_cn:'', _name:'_c01', _data_type:'str', _max_len:'100'},
    	  
    	  showAlert: false, alertType: 'success', alertText:'' , 
    	  
    	  colNum : 0
      },
      
      mounted: function() {
      },
      
      methods : {
    	  newTableOf: function(deptId, deptName) {
    		  // alert(deptId + ',' + deptName);
    		  // reset new table ui
    		  this.tabName = '';
    		  this.tabNameMD5 = '';
    		  this.alreadyCreateColumns.splice(0, this.alreadyCreateColumns.length);
    		  this.add._name_cn = '';
    		  this.add._name = '_c01';
    		  this.add._data_type = 'str';
    		  this.add._max_len = '100';
    		  this.showAlert = false;
    		  
    		  this.deptName = deptName;
    		  this.deptId = deptId;
    		  this.showType = 2;
    	  },
    	  
    	  changeTable: function(tabId, tabName, tabNameCN) {
    		  this.showType = 1;
    		  this.curTableInfo[1].text = tabName;
    	  },
    	  
    	  newTableToServer: function() {
    		  var vm = this
    		  param = [{_name_cn: this.tabName, _name: this.tabNameMD5, _type: 1, 
    			  		_owner: this.tabNameMD5, _dept_id: this.deptId}];
    		  var url = "<%=request.getContextPath()%>/rest/tableprototype";
    		  axios.post(url, param).then(function(res) {
    			  var d = res.data;
    			  if (d.status == 'OK') {
    				  vm.alertType = 'success';
    				  vm.alertText = 'Create Table Success';
    				  vm.showAlert = true;
    			  } else {
    				  vm.alertType = 'error';
    				  vm.alertText = 'Create Table Fail: ' + d.msg;
    				  vm.showAlert = true;
    			  }
    		  }).catch(function (error) {
    			  vm.alertType = 'error';
    			  vm.alertText = 'Create Table Fail: ' + error;
    			  vm.showAlert = true;
    		  });
    	  },
    	  
    	  newColumnToServer: function() {
    		  param = {_name_cn: this.add._name_cn, _name: this.add._name, 
    				  _type: 2, _data_type: this.add._data_type, 
    				  _max_len: this.add._max_len, _owner: this.tabNameMD5};
    		  var vm = this
    		  var url = "<%=request.getContextPath()%>/rest/tableprototype";
    		  axios.post(url, [param]).then(function(res) {
    			  var d = res.data;
    			  if (d.status == 'OK') {
    				  vm.alertType = 'success';
    				  vm.alertText = 'Create Column Success';
    				  vm.showAlert = true;
    				  vm.colNum++;
    				  var cc = vm.colNum + 1;
    				  if (cc < 10) cc = '0' + cc;
    				  vm.add._name = '_c' + cc;
    				  vm.add._name_cn = '';
    				  
    				  vm.alreadyCreateColumns.push(param);
    			  } else {
    				  vm.alertType = 'error';
    				  vm.alertText = 'Create Column Fail: ' + d.msg;
    				  vm.showAlert = true;
    			  }
    		  }).catch(function (error) {
    			  vm.alertType = 'error';
    			  vm.alertText = 'Create Column Fail: ' + error;
    			  vm.showAlert = true;
    		  });
    	  }
      },
      
      watch: {
      }
    });
    
    vm.$watch('tabName', function (newVal, oldVal) {
    	if (newVal != '') this.tabNameMD5 = '' + md5(newVal);
    	else  this.tabNameMD5 = '';
    });
    
  
  </script>
</body>
</html>
