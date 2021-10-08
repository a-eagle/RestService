<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<!DOCTYPE html>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="http://unpkg.com/view-design/dist/styles/iview.css">
  <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
  <script src="http://unpkg.com/view-design/dist/iview.min.js"></script>
  <script src="https://cdn.staticfile.org/axios/0.18.0/axios.min.js"></script>
  <script src="../js/md5.js"></script>
  <style>
  
  xbody::-webkit-scrollbar {
	  display: none; /* Chrome Safari */
	}
  
  </style>
</head>
<body >
<div id="app">

<Row justify="space-around" :gutter="16" type="flex" >
	<i-col span="9" >  
		<i-input placeholder="Please Input..." v-model.trim = 'tabName' > 
			<span slot="prepend">表名（中文）：</span>
		</i-input>  
	</i-col>
	<i-col span="9" >  
		<i-input placeholder="" v-model = 'tabNameMD5' readonly>
			<span slot="prepend">表名MD5：</span>
		</i-input>  
	</i-col>
	<i-col span="2" > <i-button block @click="newTableToServer" > 创建表  </i-button>  </i-col>
	<i-col span="2" >  <i-button block @click="rest"> 重置  </i-button> </i-col>
</row>
<alert v-if="showAlertT" show-icon :type = "alertTypeT"  closable >
	{{alertTextT}}
</alert>
<Divider > </Divider>


<i-Table  :columns="colsInfo" :data="alreadyCreateColumns" height="300" >
	<!-- 
	<template slot-scope="{ row, index }" slot="action">
        <i-Button type="primary" size="small" style="margin-right: 5px" @click="editCol(index)">Edit</i-Button>
        <i-Button type="error" size="small" @click="deleteCol(index)">Delete</i-Button>
    </template>
     -->
</i-Table>

<row justify="space-around" style=" background-color: #f5f7f9; padding:5px;" :gutter="8">
	<i-col span="5" > <i-input v-model.trim = 'add._name_cn' required maxlength="30"  show-word-limit>  </i-col>
	<i-col span="5"> <i-input  v-model.trim = 'add._name' required> </i-col>
	<i-col span="5" > <i-input   v-model.trim = 'add._data_type' required> </i-col>
	<i-col span="5" > <i-input   v-model.trim = 'add._max_len' required> </i-col>
	<i-col span="4" >  <i-button block @click="newColumnToServer"> 创建列  </i-button> </i-col>
</row>

<br/>

<alert v-if="showAlert" show-icon :type = "alertType"  closable >
	{{alertText}}
</alert>


<Card style="background-color: #f5f7f9" >
<row justify="space-around" style="" :gutter="8">
	<i-col span="8"  > 
			多列名
		<i-input type = "textarea" v-model.trim = 'mcols' placeholder='Please Input...' :rows="4" > 
			<span slot="prepend">多列名称</span>
		</i-input> 
	</i-col>
	<i-col span="6"  offset="2" > 
		分割符(Regex)
		<i-input  v-model.trim = 'mcols_split' > 
			
		</i-input> 
	</i-col>
	<i-col span="3" offset="2"  >  <i-button block @click="splitCols"> 分割 </i-button> </i-col>
	<i-col span="3" >  <i-button block  @click="newMultiColumn"> 创建多列 </i-button> </i-col>
	
</row>

</Card>

</div>


<script>
    var vm = new Vue({
      el: '#app',
      data : {
    	  // for new table
    	  deptName: '<%=request.getParameter("deptName")%>', deptId : '<%=request.getParameter("deptId")%>',
    	  tabName: '',  tabNameMD5: '',
    	  
    	  colsInfo: [ {title:'列名（中文）', key:'_name_cn'}, 
    		  		  {title:'列名(英文)', key:'_name'}, 
    		  		  {title:'数据类型', key:'_data_type'}, 
    		  		  {title:'最大长度', key:'_max_len'}, 
    		  		  ],
    	  
    	  alreadyCreateColumns: [], 
    	  
    	  add: {_name_cn:'', _name:'_c01', _data_type:'str', _max_len:'100'},
    	  
    	  showAlert: false, alertText:'' , alertType:'success',
    	  showAlertT: false, alertTextT:'' , alertTypeT:'success',
    	  
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
    			  vm.showAlertT = false;
    			  if (d.status == 'OK') {
    				  vm.$Message.success({content: 'Create Table Success', background: true, duration: 2.5});
    			  } else {
    				  vm.$Message.error({content: 'Create Table Fail: '+ d.msg, background: true, duration: 10});
    			  }
    		  }).catch(function (error) {
    			  vm.$Message.error({content: 'Create Table Fail: '+ error, background: true, duration: 10});
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
    				  vm.$Message.success({content: 'Create Column Success', background: true, duration: 2.5});
    				  vm.colNum++;
    				  var cc = vm.colNum + 1;
    				  if (cc < 10) cc = '0' + cc;
    				  vm.add._name = '_c' + cc;
    				  vm.add._name_cn = '';
    				  
    				  vm.alreadyCreateColumns.push(param);
    			  } else {
    				  vm.$Message.error({content: 'Server Create Column Fail:' + d.msg, background: true, duration: 10});
    			  }
    			  // console.log(cbfunc);
    			  if (typeof cbfunc == 'function') {
    				  cbfunc();
    			  }
    		  }).catch(function (error) {
				   vm.$Message.error({content: 'Client Create Column Fail:' + error, background: true, duration: 10});
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
    
    window.onload = function() {
    	
    }
  
  </script>
</body>
</html>
