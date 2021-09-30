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
  <script src="../js/xlsx.full.min.js"></script>
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
<v-app>
  <!-- 根据应用组件来调整你的内容 -->
  <v-main>
    <!-- 给应用提供合适的间距 -->
   
        <v-data-table :headers="tableHeaders" :items="tableDatas" class="elevation-1" >
        	<template v-slot:item.actions="{item}">
		      <!-- 
		      <v-icon  class="mr-2" @click="editItem(item)" >
		        mdi-pencil
		      </v-icon>
		      <v-icon small @click="deleteItem(item)" >
		        mdi-delete
		      </v-icon>
		       -->
		    </template>
        </v-data-table>
        <br/><br/><br/>
        <v-row>
        	<v-col cols='2' > <v-text-field v-model.trim.number = 'headerLineNo' label="表格行头所在行，从1开始"   >  </v-col>
        	<v-col cols='4' >
	        	<input type="file" accept=".xlsx,.xls"  title="选择导入的Excel文件..." id="efile" onchange="changeFile(this)" >  </input>
	        </v-col>
	        <v-col cols='2' >
	        	<v-btn block @click='clearData' > 清除表格数据 </v-btn>
	        </v-col>
        </v-row>
        
        <v-row>
        	<v-col cols='2' >
        		<v-select :items = "headersForSelect" v-model="headersForSelectVal" > </v-select>
	        </v-col>
	        
	        <v-col cols='2' >
	        	<v-btn block @click='changeColumnToDate'  > 数字转为日期格式 </v-btn>
	        </v-col>
	        
	        <v-col cols='2' >
	        </v-col>
        
        	<v-col cols='2' >
	        	<v-btn block @click='importToServer' > 确认导入数据 </v-btn>
	        </v-col>
        </v-row>
        
        <v-alert v-model="showAlert" border="left" close-text="Close Alert" color="green" elevation = 4 text :type = "alertType"  dismissible >
			{{alertText}}
		</v-alert>
  </v-main>
	
</v-app>
</div>

 
  <script>
    var vm = new Vue({
      el: '#app',
      vuetify: new Vuetify(),
      data : {
    	  tableHeaders: [{text: '#', value:'IDX' }],
    	  tableHeadersProto: [],
    	  tableDatas: [],
    	  
         importFileObj: null,
         headerLineNo: 2,
         
         headersForSelect: [],
         headersForSelectVal: null,
         
         alertType: 'success',
         showAlert: false,
         alertText: '',
      },
      
      mounted: function() {
    	  var vm = this;
    	  var url = '<%=request.getContextPath()%>/rest/tableprototype/' + tableName;
   		  axios.get(url).then(function (res) {
   			  var headers = res.data.headers;
   			  var d = res.data.data;
   			  // console.log(d);
   			 for (var i = 0; i < d.length; ++i) {
   				 if (d[i]._type != 2) {
   					 continue;
   				 }
   				vm.tableHeaders.push({text: d[i]._name_cn, value: d[i]._name});
   				vm.tableHeadersProto.push(d[i]);
   				
   				var vs = {text: d[i]._name_cn, value: d[i]._name};
   				if (d[i]._name_cn.indexOf('日期') >= 0 || d[i]._name_cn.indexOf('时间') >= 0) {
   					vm.headersForSelect.unshift(vs);			
   				} else {
   					vm.headersForSelect.push(vs);	
   				}
      		  }
       	  });
    	  
      },
      
      methods : {
    	  // rowIdx start from 1
    	  removeRow :function(worksheet, rowIdx, range) {
    		  for (var i = 0; i < 26; ++i) {
				  var v = String.fromCharCode(65 + i);
				  delete worksheet[v + rowIdx];
			  }
    		  
        		// less than 26 columns
    		  if (range.length == 1) {
    			  return;
    		  }
    		// more than 26 columns, delete from AA to AZ
    		  for (var i = 0; i < 26; ++i) {
				  var v = String.fromCharCode(65 + i);
				  delete worksheet['A' + v + rowIdx];
			  }
    	  },
    	  
		  parseWorkbook: function(workbook) {
			  var worksheet = workbook.Sheets[workbook.SheetNames[0]];
			  console.log(worksheet);
			  // remove !merges
			  if (worksheet['!merges']) {
				  worksheet['!merges'].length = 0;  
			  }
			  // delete before table header rows
			  this.headerLineNo = parseInt('' + this.headerLineNo);
			  var range = worksheet['!ref'];
			  range = range.substring(range.indexOf(':') + 1);
			  if (range.charAt(1) > 'A' && range.charAt(1) <= 'Z' ) {
				  range = range.substring(0, 2);
			  } else {
				  range = range.substring(0, 1);
			  }
			  for (var r = 1; r < this.headerLineNo; ++r) {
				  this.removeRow(worksheet, r, range);
			  }
			  var json = XLSX.utils.sheet_to_json(worksheet);
			  console.log(json);
			  
			  // build headers map
			  var headerMap = [];
			  var headRowData = json[0];
			  for (var i = 0; i < this.tableHeadersProto.length; ++i) {
				  var c = this.tableHeadersProto[i];
				  for (k in headRowData) {
					  if (headRowData[k] == c._name_cn) {
						  headerMap.push({key: c._name, value: k});
						  break;
					  } 
				  }
			  }
			  
			  // build data
			  for (var i = 1; i < json.length; ++i) {
				  var item = {};
				  var rowData = json[i];
				  for (var j = 0; j < headerMap.length; ++j) {
					  var h = headerMap[j];
					  item[h.key] = rowData[h.value];
				  }
				  this.tableDatas.push(item);
			  }
    	  },
    	  
    	  clearData: function() {
    		  var f = document.getElementById('efile'); 
    		  f.outerHTML = f.outerHTML;
    		  this.tableDatas.splice(0, this.tableDatas.length);
    	  },
    	  
    	  changeColumnToDate: function() {
    		  var key = this.headersForSelectVal;
    		  if (! key) {
    			  return;
    		  }
    		  for (var i = 0; i < this.tableDatas.length; ++i) {
    			  var row = this.tableDatas[i];
    			  row[key] =  numberToDate(row[key]);
    		  }
    	  },
    	  
    	  importToServer: function() {
    		  var vm = this;
        	  var url = '<%=request.getContextPath()%>/rest/api/' + tableName;
        	  console.log(url);
       		  axios.post(url, this.tableDatas).then(function (res) {
       			  var data = res.data;
       			  if (data.status == 'OK') {
       				vm.alertType = 'success';
       				vm.showAlert = true;
       				vm.alertText = '导入数据成功，共' + data.data + '条记录';
       			  } else {
       				vm.alertType = 'error';
       				vm.showAlert = true;
       				vm.alertText = '导入数据失败! ' + data.msg;
       			  }
           	  });
    	  },
    	  
      },
    });
    
    // n is 1900-01-01 to now day number
    function numberToDate(n) {
    	if (! n) {
    		return '';
    	}
    	n = parseInt(n);
    	var d = new Date('01-01-1900');
    	var ms = d.getTime() + (n - 1) * (24 * 60 * 60 * 1000);
    	var rd = new Date(ms);
    	d= rd;
    	
    	// d.setDate(d.getDate() + parseInt(n));
    	var m = d.getMonth() + 1;
    	m = m < 10 ? '0' + m: m;
    	var day = d.getDate() < 10 ? '0' + d.getDate(): d.getDate();
    	return '' + d.getFullYear() + '-' + m + "-" + day;
    }
    
    function changeFile (obj) {
     file = obj.files[0];
	  // console.log(file);
	  var reader = new FileReader();
	  reader.onload = function(e) {
		 var data = e.target.result;
		 var workbook = XLSX.read(data, {type: 'binary'});
		 vm.parseWorkbook(workbook);
	  };
	  
	  if (file) {
		  vm.tableDatas.splice(0, vm.tableDatas.length);
		  reader.readAsBinaryString(file);  
	  }
	}
    
    /* vm.$watch('newTableInfo.tabName', function (newVal, oldVal) {
    	if (newVal != '') this.newTableInfo.tabNameMD5 = '' + md5(newVal);
    	else  this.newTableInfo.tabNameMD5 = '';
    }); */
    
  
  </script>
</body>
</html>