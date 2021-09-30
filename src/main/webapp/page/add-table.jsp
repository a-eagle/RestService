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
  <style>
  
  body::-webkit-scrollbar {
	  display: none; /* Chrome Safari */
	}
  
  </style>
</head>
<body>
<div id="app">
<v-app>


<v-row justify="space-around">
	<v-col cols="10"  md="4">  <v-text-field label="表名（中文）：" v-model.trim = 'tabName' > </v-text-field>  </v-col>
	<v-col cols="10"  md="4">  <v-text-field label="表名MD5：" v-model = 'tabNameMD5' readonly> </v-text-field>  </v-col>
	<v-col cols="2"  md="1"> <v-btn block @click="newTableToServer" > 创建表  </v-btn>  </v-col>
</v-row>

<v-alert v-model="showAlert" border="left" close-text="Close Alert" color="green" elevation = 4 text type = "success"  dismissible >
	{{alertText}}
</v-alert>

<v-alert v-model="showErrAlert" border="left" close-text="Close Alert" elevation = 4 text type="error"  dismissible >
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


<v-row justify="space-around" style="border: solid 1px #ccc; background-color:#ddd; height: 60px;">
	<v-col > <v-text-field v-model.trim = 'add._name_cn' required :counter="30" >  </v-col>
	<v-col > <v-text-field  v-model.trim = 'add._name' required> </v-col>
	<v-col > <v-text-field   v-model.trim = 'add._data_type' required> </v-col>
	<v-col > <v-text-field   v-model.trim = 'add._max_len' required> </v-col>
	<v-col cols="2"  md="1" @click="newColumnToServer">  <v-btn block> 创建列  </v-btn> </v-col>
</v-row>
<br/>
<br/>
<v-row justify="space-around" style="background-color:#ddddEE; height: 180px;">
	<v-col cols="6"  > <v-textarea v-model.trim = 'mcols' label="多列名称" > </v-textarea> </v-col>
	<v-col > <v-text-field  v-model.trim = 'mcols_split' label="分割符(Regex)" > </v-col>
	<v-col cols="2"  md="1" @click="splitCols">  <v-btn block> 分割 </v-btn> </v-col>
	<v-col cols="2"  md="1" @click="newMultiColumn">  <v-btn block> 创建多列 </v-btn> </v-col>
</v-row>

<v-row justify="space-around" style="background-color:#cccfcc; height: 60px;">
	<v-col  @click="rest">  <v-btn block> 重置  </v-btn> </v-col>
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
    	  
    	  showAlert: false, showErrAlert: false, alertText:'' , 
    	  
    	  colNum : 0,
    	  
    	  mcols: '',
    	  mcols_split: '\\s+',
      },
      
      mounted: function() {
      },
      
      methods : {
    	  rest: function() {
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
    		  this.colNum = 0;
    		  this.mcols = '';
    	  },
    	  
    	  newTableToServer: function() {
    		  var vm = this
    		  param = [{_name_cn: this.tabName, _name: this.tabNameMD5, _type: 1, 
    			  		_owner: this.tabNameMD5, _dept_id: this.deptId}];
    		  var url = "<%=request.getContextPath()%>/rest/tableprototype";
    		  axios.post(url, param).then(function(res) {
    			  var d = res.data;
    			  if (d.status == 'OK') {
    				  vm.showAlert = true;
    				  vm.showErrAlert = false;
    				  vm.alertText = 'Create Table Success';
    			  } else {
    				  vm.showErrAlert = true;
    				  vm.showAlert = false;
    				  vm.alertType = 'error';
    				  vm.alertText = 'Create Table Fail: ' + d.msg;
    			  }
    		  }).catch(function (error) {
    			  vm.showAlert = false;
    			  vm.showErrAlert = true;
    			  vm.alertText = 'Create Table Fail: ' + error;
    		  });
    	  },
    	  
    	  newColumnToServer: function(cb) {
    		  param = {_name_cn: this.add._name_cn, _name: this.add._name, 
    				  _type: 2, _data_type: this.add._data_type, 
    				  _max_len: this.add._max_len, _owner: this.tabNameMD5};
    		  var vm = this
    		  var url = "<%=request.getContextPath()%>/rest/tableprototype";
    		  
    		  if (this.add._name_cn == '') {
    			  return;
    		  }
    		  var cbfunc = cb;
    		  
    		  axios.post(url, [param]).then(function(res) {
    			  var d = res.data;
    			  if (d.status == 'OK') {
    				  vm.showAlert = true;
    				  vm.showErrAlert = false;
    				  vm.alertType = 'success';
    				  vm.alertText = 'Create Column Success';
    				  vm.colNum++;
    				  var cc = vm.colNum + 1;
    				  if (cc < 10) cc = '0' + cc;
    				  vm.add._name = '_c' + cc;
    				  vm.add._name_cn = '';
    				  
    				  vm.alreadyCreateColumns.push(param);
    			  } else {
    				  vm.showAlert = false;
    				  vm.showErrAlert = true;
    				  vm.alertText = 'Server Create Column Fail: ' + d.msg;
    			  }
    			  // console.log(cbfunc);
    			  if (typeof cbfunc == 'function') {
    				  cbfunc();
    			  }
    		  }).catch(function (error) {
    			  vm.alertText = 'Client Create Column Fail: ' + error;
    			  vm.showAlert = false;
				  vm.showErrAlert = true;
    		  });
    	  },
      
	      splitCols: function() {
	    	  var re = new RegExp(this.mcols_split);
	    	  var lines = this.mcols.split(re);
	    	  this.mcols = lines.join('\n');
	      },
	      
	      newMultiColumn: function() {
	    	  var vm = this;
	    	  var lines = this.mcols.split('\n');
	    	  if (lines.length == 0 || lines[0] == '') {
	    		  return;
	    	  }
	    	  this.add._name_cn = lines[0];
	    	  this.newColumnToServer(function() {
	    		  lines.shift();
	    		  vm.mcols = lines.join('\n');
	    	  });
	      },
	      
	      
      },
      watch: {
      }
    });
    
    vm.$watch('tabName', function (newVal, oldVal) {
    	if (newVal != '') this.tabNameMD5 = 'e' + md5(newVal);
    	else  this.tabNameMD5 = '';
    });
    
  
  </script>
</body>
</html>
