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
<div id="app" >
     <i-table :height="tableHeight" :columns="tableHeaders" :data="tableDatas" >
     	<template slot-scope="{ row, index }" slot="actions">
            <Icon type="md-build" size="20" @click="editItemData(row)"> </Icon> &nbsp;
            <Icon type="ios-list" size="20" @click="listItemData(row)"> </Icon>&nbsp;
            <Icon type="ios-cloud-upload-outline" size="20" @click="importItemData(row)"> </Icon>
        </template>
     </i-table>
	
</div>

 
  <script>
  	function loadTableCount(datas) {
  		url = '<%=request.getContextPath()%>/rest/manager/TableStatistics/findAll';
		 axios.get(url).then(function (res) {
			 var d = res.data.data;
			 var hs = {};
			 console.log('loadTableCount', d);
			 for (let i = 0; i < d.length; ++i) {
				 hs[d[i].tableName] = d[i];
			 }
			 for (let i = 0; i < datas.length; ++i) {
				 let c = datas[i];
				 if (hs[c._name])
				 	c._count = hs[c._name].dataCount;
				 else 
					c._count = 'unknow';
			 }
		 });
  	}
  
    var vm = new Vue({
      el: '#app',
      data : {
    	  tableHeight: 600,
    	  
    	  tableHeaders: [{title: '#', key:'idx', sortable: true, width:80 },
    		  {title: 'ID', key:'_id' , sortable: true, width:80},
    		  {title: '表中文名', key:'_name_cn' , sortable: true},
    		  {title: '表英文名(MD5)', key:'_name' , sortable: true},
    		  {title: '数据量', key: '_count', sortable: true},
    		  {title: 'Actions', slot:'actions', width:150 }
    	  ],
    	  tableDatas: [],
      },
      
      mounted: function() {
    	  var vm = this;
    	  var url = '<%=request.getContextPath()%>/rest/tableprototype/table?dept-id=<%=request.getParameter("deptId")%>';
   		  axios.get(url).then(function (res) {
   			  var d = res.data.data;
   			  //console.log(res);
   			  for (var i = 0; d && i < d.length; ++i) {
       			  vm.tableDatas.push({_id: d[i]._id, _name: d[i]._name, _name_cn: d[i]._name_cn, idx: i + 1, _count: ''});
       		  }
   		      loadTableCount(vm.tableDatas);
       	  });
      },
      
      methods : {
    	  deleteItem: function(item) {
    		  
    	  },
    	  
    	  editItemData: function(item) {
    		  var frame = top.document.getElementById('main-iframe').contentWindow;
    		  var u = 'edit-table.jsp?name=' + item._name + "&name_cn=" + encodeURIComponent(item._name_cn);
    		  // console.log(u);
    		  frame.vm.addTab({text: item._name_cn + "[ED]", url: u});
    	  },
    	  
    	  listItemData: function(item) {
    		  var frame = top.document.getElementById('main-iframe').contentWindow;
    		  var u = 'list-table-data.jsp?name=' + item._name;
    		  frame.vm.addTab({text: item._name_cn, url: u});
    	  },
    	  
    	  importItemData: function(item) {
    		  var frame = top.document.getElementById('main-iframe').contentWindow;
    		  var u = 'import-table-data.jsp?name=' + item._name;
    		  frame.vm.addTab({text: item._name_cn + '[IM]', url: u});
    	  }
      },
    });
    
    /* vm.$watch('newTableInfo.tabName', function (newVal, oldVal) {
    	if (newVal != '') this.newTableInfo.tabNameMD5 = '' + md5(newVal);
    	else  this.newTableInfo.tabNameMD5 = '';
    }); 
	*/
	
    window.onresize = function() {
    	var mintHeight = window.innerHeight;//style.height;
    	mintHeight -= 40; // sub bottom space
    	
    	if (mintHeight > 400 && mintHeight != vm.tableHeight) {
    		vm.tableHeight = mintHeight;
    	}
    }
    
  </script>
</body>
</html>