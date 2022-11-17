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
     	
     </i-table>
        
</div>

 
  <script>
    var vm = new Vue({
      el: '#app',
      data : {
    	  tableHeight: 400,
    	  tableHeaders: [{title: '#', key:'IDX' }, 
    		  {title: '操作时间', key:'time' }, {title: '用户', key:'userName' }, {title: '事件', key:'operation' }],
    	  tableDatas: [],
    	  
    	  editDialogShow: false,
    	  
      },
      
      mounted: function() {
    	  var vm = this;
    	  
    	  var url = '<%=request.getContextPath()%>/rest/logger';
   		  axios.get(url).then(function (res) {
   			  var d = res.data.data;
   			  console.log(res.data);
   			  for (var i = 0; i < d.length; ++i) {
   				  d[i].IDX = i + 1;
       			  vm.tableDatas.push(d[i]);
       		  }
       	  });
    	  
      },
      
      methods : {
    	  
      },
    });
    
    /* vm.$watch('newTableInfo.tabName', function (newVal, oldVal) {
    	if (newVal != '') this.newTableInfo.tabNameMD5 = '' + md5(newVal);
    	else  this.newTableInfo.tabNameMD5 = '';
    }); */
    
  
  </script>
</body>
</html>