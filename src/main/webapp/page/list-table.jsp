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
<v-app>
  <!-- 根据应用组件来调整你的内容 -->
  <v-main>
    <!-- 给应用提供合适的间距 -->
   
        <v-data-table :headers="tableHeaders" :items="tableDatas" class="elevation-1" >
        	<template v-slot:item.actions="{item}">
		      <v-icon  class="mr-2" @click="editItem(item)" >
		        mdi-pencil
		      </v-icon>
		      <!-- 
		      <v-icon small @click="deleteItem(item)" >
		        mdi-delete
		      </v-icon>
		       -->
		       <v-icon  class="mr-2" @click="listItemData(item)" >
		        mdi-magnify  
		      </v-icon>
		      
		      <v-icon  class="mr-2" @click="importItemData(item)" >
		        mdi-import
		      </v-icon>
		    </template>
        </v-data-table>
  </v-main>
	
	<v-dialog v-model="editDialogShow" max-width="90%">
		<v-card>
			<v-card-title> {{editDialog._name_cn}} </v-card-title>
		</v-card>
		<v-data-table :headers="editDialog.headers" :items="editDialog.datas" class="elevation-1" hide-default-footer >
		</v-data-table>
	</v-dialog>
	
</v-app>
</div>

 
  <script>
    var vm = new Vue({
      el: '#app',
      vuetify: new Vuetify(),
      data : {
    	  tableHeaders: [{text: '#', value:'idx' },
    		  {text: 'ID', value:'_id' },  
    		  {text: '表中文名', value:'_name_cn' },
    		  {text: '表英文名(MD5)', value:'_name' },
    		  {text: 'Actions', value:'actions' }
    	  ],
    	  tableDatas: [],
    	  
    	  editDialogShow: false,
    	  editDialog: {_name_cn:'', _name:'', 
    		  headers:[{text:'#', value:'idx'},{text:'ID', value:'_id'}, {text:'列中文名', value:'_name_cn'}, 
    			  {text:'列英文名', value:'_name'}, {text:'数据类型', value:'_data_type'}, {text:'最大长度', value:'_max_len'}], 
    		  datas: []},
      },
      
      mounted: function() {
    	  var vm = this;
    	  var url = '<%=request.getContextPath()%>/rest/tableprototype/table?dept-id=<%=request.getParameter("deptId")%>';
   		  axios.get(url).then(function (res) {
   			  var d = res.data.data;
   			  //console.log(res);
   			  for (var i = 0; i < d.length; ++i) {
       			  vm.tableDatas.push({_id: d[i]._id, _name: d[i]._name, _name_cn: d[i]._name_cn, idx: i + 1});
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
    		  // console.log(item);
    		  this.resetEditDialog();
    		  this.editDialogShow = true;
    		  this.editDialog._name_cn = item._name_cn;
    		  this.editDialog._name = item._name;
    		  var vm = this;
        	  var url = '<%=request.getContextPath()%>/rest/tableprototype/' + item._name;
        	  console.log(url);
       		  axios.get(url).then(function (res) {
       			  var d = res.data.data;
       			  //console.log(res);
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
    	  
    	  listItemData: function(item) {
    		  var frame = top.document.getElementById('main-right').contentWindow;
    		  var u = 'list-table-data.jsp?name=' + item._name;
    		  frame.vm.addTab({text: item._name_cn, url: u});
    	  },
    	  
    	  importItemData: function(item) {
    		  var frame = top.document.getElementById('main-right').contentWindow;
    		  var u = 'import-table-data.jsp?name=' + item._name;
    		  frame.vm.addTab({text: item._name_cn + '[IN]', url: u});
    	  }
      },
    });
    
    /* vm.$watch('newTableInfo.tabName', function (newVal, oldVal) {
    	if (newVal != '') this.newTableInfo.tabNameMD5 = '' + md5(newVal);
    	else  this.newTableInfo.tabNameMD5 = '';
    }); */
    
  
  </script>
</body>
</html>