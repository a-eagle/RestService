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
		<i-Select v-model="deptId" >
			<span slot="prefix">所属部门：</span>
        	<i-Option v-for="item in deptInfos" :value="item.id" :key="item.id">
        		{{ item.name }}
        	</i-Option>
    	</i-Select>
	</i-col>
	<i-col span="2" > <i-button block @click="updateTableToServer" > 修改表信息  </i-button>  </i-col>
</row>

<alert v-if="showAlertT" show-icon :type = "alertTypeT"  closable >
	{{alertTextT}}
</alert>

<Divider > </Divider>


<i-Table  :columns="colsInfo" :data="alreadyCreateColumns" height="300" >
	<template slot-scope="{ row, index }" slot="action">
        <i-Button v-if="curEidtRowIdx != index" type="primary" size="small" style="margin-right: 5px" @click="editCol(row, index)">Edit</i-Button>
        <i-Button v-else type="primary" size="small" style="margin-right: 5px" @click="saveCol(row, index)">Save</i-Button>
        <i-Button type="warning" size="small" @click="deleteCol(row, index)">Delete</i-Button>
    </template>
    
    <template slot-scope="{ row, index }" slot="_name_cn">
    	<span v-if="curEidtRowIdx != index" > {{row._name_cn}} </span>
    	<i-input v-else v-model.trim="curEidtRowData._name_cn" > </i-input>
    </template>
    
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

<Modal v-model="showDeleteDialog" width="360">
    <p slot="header" style="color:#f60;text-align:center">
        <Icon type="ios-information-circle"></Icon>
        <span>Delete confirmation</span>
    </p>
    <div style="text-align:center">
        <p>Will you delete column "{{delColInfo ? delColInfo._name_cn : null}}" ?</p>
    </div>  
    <div slot="footer">
        <i-Button type="error" size="large" long :loading="modal_loading" @click="delColOnDialog">Delete</i-Button>
    </div>
</Modal>


</div>


<script>
    var vm = new Vue({
      el: '#app',
      data : {
    	  tabName: '',
    	  tabNameMD5: '',
    	  deptId: '',
    	  tabObj: null,
    	  deptInfos: [],
    	  
    	  curEidtRowIdx: -1,
    	  curEidtRowData: null,
    	  
    	  colsInfo: [ {title:'列名（中文）', key:'_name_cn', slot:'_name_cn'}, 
    		  		  {title:'列名(英文)', key:'_name'}, 
    		  		  {title:'数据类型', key:'_data_type'}, 
    		  		  {title:'最大长度', key:'_max_len'}, 
    		  		  {title:'Actions', slot:'action'}],
    	  
    	  alreadyCreateColumns: [], 
    	  
    	  add: {_name_cn:'', _name:'_c01', _data_type:'str', _max_len:'100'},
    	  
    	  showAlert: false, alertText:'' , alertType:'success',
    	  
    	  showAlertT: false, alertTextT:'' , alertTypeT:'success',
    	  
    	  colNum : 0,
    	  
    	  mcols: '',
    	  mcols_split: '\\s+',
    	  
    	  showDeleteDialog: false,
    	  deleteDialogMsg: '',
    	  modal_loading:false,
    	  delColInfo: null,
      },
      
      mounted: function() {
    	  var vm = this;
    	  var url = '<%=request.getContextPath()%>/rest/tableprototype/<%=request.getParameter("name")%>';
    	  
   		  axios.get(url).then(function (res) {
   			  var d = res.data.data;
   			  // console.log(d);
   			  for (var i = 0; i < d.length; ++i) {
   				  if (d[i]._type == 1) {
   					  vm.tabName = d[i]._name_cn;
   					  vm.tabNameMD5 = d[i]._name;
   					  vm.tabObj = d[i];
   					  vm.deptId = d[i]._dept_id;
   				  } else if (d[i]._type == 2) {
   					  // d[i].idx = i;
   	       			  vm.alreadyCreateColumns.push(d[i]);
   				  }
       		  }
   			  
   			  var maxC = 0;
   			  var reg = /^_c([0-9]{2})$/i
   			  var mg = /[0-9]+/
   			  for (var i = 0; i < vm.alreadyCreateColumns.length; ++i) {
   				var m = vm.alreadyCreateColumns[i];
   				if (m._type != 2) 
   					continue;
   				if (reg.test(m._name)) {
   					var vv = parseInt(m._name.match(mg));
   					if (vv > maxC) maxC = vv;
   				}
   			  }
   			  vm.colNum = maxC;
   			  ++maxC;
   			  vm.add._name = '_c' + (maxC > 9 ? maxC : '0' + maxC);
       	  });
   		  
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
    	  updateTableToServer: function() {
    		  var vm = this;
    		  param = {_name_cn:  this.tabName, _dept_id: this.deptId};
    		  var url = "<%=request.getContextPath()%>/rest/tableprototype/" + this.tabObj._id;
    		  axios.put(url, param).then(function(res) {
    			  var d = res.data;
    			  if (d.status == 'OK') {
    				  vm.$Message.success({content: 'Modify Table Success', background: true, duration: 2.5});
    			  } else {
    				  vm.$Message.error({content: 'Modify Table Fail: ' + d.msg, background: true, duration: 10});
    			  }
    		  }).catch(function (error) {
    			  vm.$Message.error({content: 'Modify Table Fail: ' + error, background: true, duration: 10});
    		  });
    	  },
    	  
    	  updateTableColToServer: function(item, callback) {
    		  var vm = this;
    		  param = item;
    		  var cb = callback;
    		  var url = "<%=request.getContextPath()%>/rest/tableprototype/" + item._id;
    		  axios.put(url, param).then(function(res) {
    			  var d = res.data;
    			  if (d.status == 'OK') {
    				  vm.$Message.success({content: 'Modify Table Success', background: true, duration: 2.5});
    				  if (typeof cb == 'function') {
    					  cb(true);
    				  }
    			  } else {
    				  vm.$Message.error({content: 'Modify Table Fail: ' + d.msg, background: true, duration: 10});
    				  if (typeof cb == 'function') {
    					  cb(false);
    				  }
    			  }
    		  }).catch(function (error) {
    			  vm.$Message.error({content: 'Modify Table Fail: ' + error, background: true, duration: 10});
    			  if (typeof cb == 'function') {
					  cb(false);
				  }
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
    				  vm.$Message.error({content: 'Server Create Column Fail: ' + d.msg, background: true, duration: 10});
    			  }
    			  // console.log(cbfunc);
    			  if (typeof cbfunc == 'function') {
    				  cbfunc();
    			  }
    		  }).catch(function (error) {
    			  vm.$Message.error({content: 'Client Create Column Fail: ' + error, background: true, duration: 10});
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
	      
	      editCol: function(row, index) {
	    	  this.curEidtRowData = row,
	    	  this.curEidtRowIdx = index;
	      },
	      
	      deleteCol: function(row, index) {
	    	  this.delColInfo = {_id: row._id, _name_cn: row._name_cn, idx: index};
	    	  this.showDeleteDialog = true;
	    	  this.deleteDialogMsg = "";
	    	  this.modal_loading =  false;
	      },
	      
	      delColOnDialog: function() {
	    	  this.modal_loading = true;
	    	  var vm = this;
    		  var url = "<%=request.getContextPath()%>/rest/tableprototype/column/" + this.delColInfo._id;
    		  axios.delete(url).then(function(res) {
    			  var d = res.data;
    			  console.log(d);
    			  vm.modal_loading = false;
    			  vm.showDeleteDialog = false;
    			  if (d.status == 'OK') {
    				  vm.alreadyCreateColumns.splice(vm.delColInfo.idx, 1);
    				  vm.$Message.success({content: 'Successfully delete', background: true, duration: 2.5});
    			  } else {
    				  vm.$Message.error({content: 'Server Fail delete: '+ d.msg, background: true, duration: 10});
    			  }
    		  }).catch(function (error) {
    			  vm.$Message.error({content:'Client Fail delete: '+ error, background: true, duration: 10});
    		  });
	      },
	      
	      saveCol: function(row, index) {
	    	  var idx = index;
	    	  var param = {_name_cn: row._name_cn, _id: row._id};
	    	  var vm = this;
	    	  this.updateTableColToServer(param, function(ok) {
	    		  vm.curEidtRowIdx = -1;
	        	  vm.curEidtRowData = null;
	        	  if (ok) {
	        		  vm.alreadyCreateColumns[idx]._name_cn = param._name_cn;
	        	  }
	    	  });
	      }
      },
      
      watch: {
      }
    });
    
  
  </script>
</body>
</html>
