<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<!DOCTYPE html>
<html>
<head>
	<link rel="stylesheet" type="text/css" href="../iview/styles/iview.css">
	<script src="../js/vue.js"></script>
	<script src="../js/axios.min.js"></script>
	<script src="../iview/iview.min.js"></script>
  <script src="../js/md5.js"></script>
  <script src="../js/auth.js?v"></script>
  <style>
  
  xbody::-webkit-scrollbar {
	  display: none; /* Chrome Safari */
	}
  
  </style>
</head>
<body style="padding: 20px;">
<div id="app">

<i-input placeholder="Input sql..." v-model.trim = 'sql' type="textarea" style=' width: 80%;' :rows="5" >  </i-input>  
<br/>
<i-button block @click="executeSql" > Execute  </i-button>

<Divider > </Divider>


<i-Table  :columns="colsInfo" :data="sqlDatas" height="600" >
	<!-- 
	<template slot-scope="{ row, index }" slot="action">
        <i-Button type="primary" size="small" style="margin-right: 5px" @click="editCol(index)">Edit</i-Button>
        <i-Button type="error" size="small" @click="deleteCol(index)">Delete</i-Button>
    </template>
     -->
</i-Table>

</div>


<script>
    var vm = new Vue({
      el: '#app',
      data : {
    	  colsInfo: [],
    	  sql: '',
    	  sqlDatas: [], 
      },
      
      mounted: function() {
    	  
      },
      
      methods : {
    	  rest: function() {
    		  this.sqlDatas = [];
    		  this.sql = '';
    	  },
    	  
    	  executeSql: function() {
    		  var vm = this;
    		  vm.sqlDatas.splice(0, vm.sqlDatas.length);
    		  vm.colsInfo.splice(0, vm.colsInfo.length);
    		  var url = "<%=request.getContextPath()%>/rest/manager/execSql";
    		  axios.post(url, {sql: this.sql}).then(function(res) {
    			  var d = res.data;
    			  var dd = d.data;
    			  console.log(dd)
    			  if (d.status == 'OK') {
    				  vm.colsInfo.push({title:'#', key:'__idx__'});
    				  for (var i = 0; i < dd.heads.length; ++i) {
    				  	 vm.colsInfo.push(dd.heads[i]);
    				  }
    				  for (var i = 0; i < dd.datas.length; ++i) {
    					  dd.datas[i].__idx__ = i + 1; 
      				  	 vm.sqlDatas.push(dd.datas[i]);
    				  }
    			  } else {
    				  vm.$Message.error({content: 'Fail: '+ d.msg, background: true, duration: 10});
    			  }
    		  }).catch(function (error) {
    			  vm.$Message.error({content: 'Fail: '+ error, background: true, duration: 10});
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
