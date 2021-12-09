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
  <script src="../js/xlsx.full.min.js"></script>
  <script src="../js/auth.js"></script>
   <script>
  
  	var tableName = '<%=request.getParameter("name")%>';
  </script>
   <style>
  
  xbody::-webkit-scrollbar {
	  display: none; /* Chrome Safari */
	}
  
  </style>
</head>
<body style="width:100%; height:100%;">

<div id="app" >
     <i-table :columns ="tableHeaders" :data ="tableDatas" height="500" >
     </i-table>
     <br/>
     
     <card style="background-color: #f5f7f9">
	     <row>
	     	<i-col span='6' > 
	     		<i-input type="number" v-model.trim.number = 'headerLineNo' > 
	     			<span slot="prepend">表格行头所在行，从1开始：</span>
	     		</i-col>
	     	<i-col span='8' offset="4" >
	      		<input type="file" style="border:dashed 1px #888;" accept=".xlsx,.xls"  title="选择导入的Excel文件..." id="efile" onchange="changeFile(this)" >  </input>
	      </i-col>
	      <i-col cols='6' >
	      	<i-button  @click='clearData' type="warning" > 清除表格数据 </i-button>
	      </i-col>
	     </row>
     </card>
     <br/>
     
     <card style="background-color: #f5f7f9">
	     <row :gutter="16">
	     	  <i-col span='5' >
	     		<i-select v-model="headersForSelectVal" > 
	     			 <i-Option v-for="item in headersForSelect" :value="item._name" :key="item._name">
	     			 	{{ item._name_cn }}
	     			 </i-Option>
	     		</i-select>
		      </i-col>
		      
		      <i-col span='5' >
		      	<i-button block @click='changeColumnToDate'  > 数字转为日期格式 </i-button>
		      </i-col>
		      
		     	<i-col span='5' >
		      	   <i-button block @click='importToServer' type="primary"> 确认导入数据 </i-button>
		      </i-col>
	     </row>
	 </card>
     
     <alert v-if="showAlert" show-icon :type = "alertType"  closable >
		{{alertText}}
	</alert>
	
</div>

 
  <script>
  
//colStr is A - ZZ
  function nextExcelColString(colStr) {
	 var r = '';
	 var jw = false;
	 var len = colStr.length;
	 var last = colStr.charCodeAt(len - 1) + 1;
 		 if (last > 90) {
 			 last = last - 90 + 64;
 			 jw = true;
 		 }
 		 r = String.fromCharCode(last);
 		 if (jw || len == 2) {
 			 var cc = (len == 2 ? colStr.charCodeAt(len - 2) : 64);
 			 if (jw) cc += 1;
 			 if (cc >= 65) {
 				 r = String.fromCharCode(cc) + r;
 			 }
 		 }
 		 return r;
  }
  
    var vm = new Vue({
      el: '#app',
      data : {
    	  tableHeaders: [{title: '#', key:'IDX', fixed: 'left', maxWidth: 100,}],
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
   				vm.tableHeaders.push({title: d[i]._name_cn, key: d[i]._name, render: (h, params) => {
   						var txt = params.row[params.column.key];
   						if (txt && txt.length > 30) {
   							txt = txt.substring(0, 30) + '...(' +  txt.length + ')';
   						}
	   					return h('span', txt);
	   				}
   				});
   				vm.tableHeadersProto.push(d[i]);
   				
   				var vs = {_name_cn: d[i]._name_cn, _name: d[i]._name};
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
			  
			  var range = worksheet['!ref'];
			  if (! range || range.indexOf(':') < 0)
				  return;
			  var startCol = '', endCol = '', startRow = 0, endRow = 0;
			  startCol = range.match(/[A-Z]+/g)[0]; // A - ZZ
			  endCol = range.match(/[A-Z]+/g)[1];
			  startRow = parseInt(range.match(/[0-9]+/g)[0]);
			  endRow = parseInt(range.match(/[0-9]+/g)[1]);
			  console.log('start-end col row:', startCol, endCol, startRow, endRow);
			  
			  // build headers map  --> { col-_name: col-head, ...}
			  var headerMap = {};
			  for (var i = 0; i < this.tableHeadersProto.length; ++i) {
				  var c = this.tableHeadersProto[i];
				  // 不超过100列
				  for (var hc = startCol, j = 0; j <= 100; hc = nextExcelColString(hc), ++j) {
					  var t = hc + this.headerLineNo;
					  var tv = worksheet[t];
					  if (tv && String(tv.v).trim() == c._name_cn.trim()) {
						  headerMap[c._name] = hc;
					  }
					  if (hc == endCol) {
						  break;
					  }
				  }
			  }
			  console.log('headerMap = ', headerMap);
			  
			// build data
			 for (var i = this.headerLineNo + 1, j = 1; i <= endRow; ++i, ++j) {
				  var item = {IDX: j};
				  var isAllEmpty = true;
				  for (h in headerMap) {
					  var d = worksheet[headerMap[h] + i];
					  // console.log(h, d);
					  if (! d) {
						  continue;
					  }
					  item[h] = d.w;
					  if (d.w) isAllEmpty = false;
				  }
				  if (isAllEmpty) {
				  	  break;
				  }
				  this.tableDatas.push(item);
			  }
    	  },
    	  
		  parseWorkbook_old: function(workbook) {
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
					  var kk = String(headRowData[k]);
					  if (kk.trim() == c._name_cn) {
						  headerMap.push({key: c._name, value: k});
						  break;
					  } 
				  }
			  }
			  
			  // build data
			  for (var i = 1; i < json.length; ++i) {
				  var item = {IDX: i};
				  var rowData = json[i];
				  for (var j = 0; j < headerMap.length; ++j) {
					  var h = headerMap[j];
					  var v = rowData[h.value];
					  if (v) {
						  v = '' + v;
						  if (v.length >= 30) {
							  v = v.substring(0, 30) + '...(' + v.length + ')'; 
						  }
					  }
					  item[h.key] = v;
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
        	  // console.log(url);
       		  axios.post(url, this.tableDatas).then(function (res) {
       			  var data = res.data;
       			  console.log(data);
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