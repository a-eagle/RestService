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
  <script src="../js/auth.js?v"></script>
   <script>
  
  	var tableName = '<%=request.getParameter("name")%>';
  </script>
   <style>
  
  body::-webkit-scrollbar {
	  display: none; /* Chrome Safari */
	}
  
  </style>
</head>
<body style="width:100%; height:100%;">
<div id="app" style="width:100%; height:100%;">
	<i-table :height="tableHeight" :columns="tableHeaders" :data="tableDatas" >
     	<template slot-scope="{ row, index }" slot="actions">
            <Icon type="md-build" size="20" @click="editItem(row)"> </Icon> &nbsp;
        </template>
     </i-table>

	
	<Modal model="editDialogShow" max-width="90%">
		
	</Modal>
	
</div>

 
  <script>
    var vm = new Vue({
      el: '#app',
      data : {
    	  tableHeight: 400,
    	  tableHeaders: [{title: '#', key:'IDX' }],
    	  tableDatas: [],
    	  
    	  editDialogShow: false,
    	  editDialog: {_name_cn:'', _name:'', 
    		  headers:[{title:'#', value:'idx'},{title:'ID', value:'_id'}, {title:'列中文名', value:'_name_cn'}, 
    			  {title:'列英文名', value:'_name'}, {title:'数据类型', value:'_data_type'}, {title:'最大长度', value:'_max_len'}], 
    		  datas: []},
      },
      
      mounted: function() {
    	  var vm = this;
    	  
    	  var url = '<%=request.getContextPath()%>/rest/api/' + tableName + "?result-for=ui";
   		  axios.get(url).then(function (res) {
   			  var headers = res.data.headers;
   			  var d = res.data.data;
   			  console.log(res.data);
   			  // only show max 12 columns
   			  for (var i = 0; i < headers.length && i < 12; ++i) {
     			  vm.tableHeaders.push({title: headers[i].text, key: headers[i].name});
     		  }
   			  for (var i = 0; i < d.length; ++i) {
   				  d[i].IDX = i + 1;
       			  vm.tableDatas.push(d[i]);
       		  }
       	  });
    	  
      },
      
      methods : {
    	  resetEditDialog: function() {
    		  this.editDialog._name_cn = '';
    		  this.editDialog._name = '';
    		  this.editDialog.datas.splice(0, this.editDialog.datas.length);
    	  },
    	  
    	  editItem: function(item) {
    		  console.log(item);
    		  this.resetEditDialog();
    		  this.editDialogShow = true;
    		  this.editDialog._name_cn = item._name_cn;
    		  this.editDialog._name = item._name;
    		  var vm = this;
        	  var url = '<%=request.getContextPath()%>/rest/tableprototype/' + item._name;
        	  console.log(url);
       		  axios.get(url).then(function (res) {
       			  var d = res.data.data;
       			  console.log(d);
       			  for (var i = 0; i < d.length; ++i) {
       				  if (d[i]._type != 2)
       					  continue;
       				  d[i].idx = i;
           			  vm.editDialog.datas.push(d[i]);
           		  }
           	  });
    	  },
    	  
    	  deleteItem: function(item) {
    		  
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