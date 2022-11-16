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
            <Icon type="md-beaker" size="20" @click="delItemData(row)"> </Icon>&nbsp;
        </template>
     </i-table>
	
	
<Modal v-model="editModalShow" width="400"
	title="更新密码"
	@on-ok="saveEditInfo"
	>
	新密码：<i-input v-model = 'curUserPassword' > </i-input>
</Modal>

<Modal v-model="addModalShow" width="400"
	title="新用户"
	@on-ok="saveAddInfo"
	>
	用户名：<i-input v-model = 'curUserName' > </i-input>
	密码：<i-input v-model = 'curUserPassword' > </i-input>
	所属部门： <i-input v-model = 'curUserDept' > </i-input>
</Modal>

<Modal v-model="delModalShow" width="360">
    <template #header>
        <p style="color:#f60;text-align:center">
            <Icon type="ios-information-circle"></Icon>
            <span>请确认</span>
        </p>
    </template>
    <div style="text-align:center">
        <p>确定要删除吗？</p>
    </div>
    <template #footer>
        <i-Button type="error" size="large" long  @click="del">删除</i-Button>
    </template>
</Modal>
	
	 <i-Button size="large" type="info"   @click="addUserView">创建新用户</i-Button>
</div>

 
  <script>
  	
  
    var vm = new Vue({
      el: '#app',
      data : {
    	  editModalShow : false, 
    	  delModalShow : false,
    	  addModalShow: false,
    	  
    	  curUser : null,
    	  curUserId : null,
    	  curUserName: null,
    	  curUserPassword : null,
    	  curUserDept : null,
    	  
    	  tableHeight: 400,
    	  
    	  tableHeaders: [{title: '#', key:'idx', width:80 },
    		  // {title: 'ID', key:'_id' , sortable: true, width:80},
    		  {title: '用户名', key:'name' , sortable: true},
    		  {title: '密码', key:'password' , sortable: true},
    		  {title: '所属部门', key: 'dept', sortable: true},
    		  {title: 'Actions', slot:'actions', width:150 }
    	  ],
    	  tableDatas: [],
      },
      
      mounted: function() {
    	  var vm = this;
    	  var url = '<%=request.getContextPath()%>/rest/user';
   		  axios.get(url).then(function (res) {
   			  var d = res.data.data;
   			  //console.log(res);
   			  for (var i = 0; d && i < d.length; ++i) {
       			  vm.tableDatas.push(d[i]);
       		  }
       	  });
      },
      
      methods : {
    	  editItemData: function(item) {
    		  this.curUser = item;
    		  this.curUserId = item.id;
    		  this.curUserPassword = item.password;
    		  this.editModalShow = true;
    	  },
    	  
    	  saveEditInfo: function() {
    		  var vm = this;
    		  var param = {id: this.curUserId, password: this.curUserPassword};
    	  	  	axios.put("<%=request.getContextPath()%>/rest/user", param).then(function (res) {
    	  		  var d = res.data;
    	  		  console.log(d);
	    	  		if (d.status == 'OK') {
	  				  vm.$Message.success({content: '更新成功', background: true, duration: 2.5});
	  				   // window.location.reload (true);
	  				   vm.curUser.password = vm.curUserPassword;
	  			  } else {
	  				  vm.$Message.error({content: '更新失败 ' + d.msg, background: true, duration: 10});
	  			  }
    	  	  	});
    	  },
    	  
    	  delItemData: function(item) {
    		  this.delModalShow = true;
    		  this.curUser = item;
    		  this.curUserId = item.id;
    	  },
    	  
    	  del: function() {
    		  this.delModalShow = false;
    		  console.log(this.curUserId);
    		  var vm = this;
    	  	  	axios.delete("<%=request.getContextPath()%>/rest/user/" + this.curUserId).then(function (res) {
    	  		  var d = res.data;
    	  		  console.log(d);
	    	  		if (d.status == 'OK') {
	  				  vm.$Message.success({content: '删除成功', background: true, duration: 2.5});
	  				   // window.location.reload (true);
	  				   // vm.curUser.password = vm.curUserPassword;
	  				   for (var i = 0;  i < vm.tableDatas.length; ++i) {
	  					   var dx = vm.tableDatas[i];
	  					   if (dx.id == vm.curUserId) {
	 		       			  vm.tableDatas.splice(i, 1);
	 		       			  break;
	  					   }
		       		  }
	  			  } else {
	  				  vm.$Message.error({content: '删除失败 ' + d.msg, background: true, duration: 10});
	  			  }
    	  	  	});
    	  },
    	  
    	  addUserView: function() {
    		  this.curUserName = null;
    		  this.curUserPassword = null;
    		  this.curUserDept = null;
    		  this.addModalShow = true;
    	  },
    	  
    	  saveAddInfo: function() {
    		  var vm = this;
    		  var param = {name: this.curUserName, password: this.curUserPassword, dept: this.curUserDept};
    		  console.log('Add', param);
    	  	  	axios.post("<%=request.getContextPath()%>/rest/user", param).then(function (res) {
    	  		  var d = res.data;
    	  		  console.log(d);
	    	  		if (d.status == 'OK') {
	  				  vm.$Message.success({content: '创建成功', background: true, duration: 2.5});
	  				  window.location.reload (true);
	  			  } else {
	  				  vm.$Message.error({content: '创建失败 ' + d.msg, background: true, duration: 10});
	  			  }
    	  	  	});
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
    	mintHeight -= 80;
    	
    	if (mintHeight > 400 && mintHeight != vm.tableHeight) {
    		vm.tableHeight = mintHeight;
    	}
    	vm.tableHeight = mintHeight;
    	console.log('mintHeight', mintHeight);
    }
    
  </script>
</body>
</html>