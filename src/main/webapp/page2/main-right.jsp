<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
  <link href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/@mdi/font@4.x/css/materialdesignicons.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.min.css" rel="stylesheet">
  
  <link rel="stylesheet" type="text/css" href="http://unpkg.com/view-design/dist/styles/iview.css">
  <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
  <script type="text/javascript" src="http://unpkg.com/view-design/dist/iview.min.js"></script>
  <script src="https://cdn.staticfile.org/axios/0.18.0/axios.min.js"></script>
   <script>
  
  	var deptId = '<%=request.getParameter("deptId")%>';
  	var deptName = '<%=request.getParameter("deptName")%>';
  	var deptNameEncode = encodeURIComponent(deptName);
  </script>
  <style>
  
  wbody::-webkit-scrollbar {
	  display: none; /* Chrome Safari */
	}
  
  </style>
</head>
<body >
<div id='app' style=" margin:  0px 5px;" >
    <!-- h3>
    	【<%=request.getParameter("deptName") %>】
    </h3>
     -->
    <Tabs :value="tab" type="card" closable @on-tab-remove='removeTab' >
    	<Tab-pane v-for="(item, idx) in tabsInfo" :key="item.url" :label="item.text" :name="item.url" 	 >
    		<iframe style="width:100%; border:0;" :id="'ifr' + idx"
    			@load="adjustFrame('ifr' + idx)"
    			scrolling="no"
    			frameborder="0"
    		 	:src='item.url'> </iframe>
    	</Tab-pane>
    </Tabs>
</div>    
 
  <script>
    var vm = new Vue({
      el: '#app',
      data : {
    	  tabsInfo : [
    		  {text: '所属表', url:'list-table.jsp?deptId=' + deptId }, 
    		  {text: '新建表', url:'add-table.jsp?deptId=' + deptId + '&deptName=' + deptNameEncode},
    		],
    	  tab: null,
      },
      
      methods : {
    	  // item = {text:'', url:'' }
    	  adjustFrame: function(frameId) {
    		  var fr = document.getElementById(frameId);
    		  if (fr.document) {
    			  fr.height = fr.document.body.scrollHeight;
    		  } else {
    			  fr.height = fr.contentDocument.body.offsetHeight;
    		  }  
    	  },
    	  
    	  addTab: function(item) {
    		  for (var i = 0; i < this.tabsInfo.length; ++i) {
    			  if (this.tabsInfo[i].url == item.url) {
    				  this.tab = item.url;
    				  return;
    			  }
    		  }
    		  
    		  this.tabsInfo.push(item);
    		  this.tab = item.url;
    	  },
    	  
    	  removeTab:  function(url) {
    		  console.log('remove tab:' + url);
    		  for (var i = 0; i < this.tabsInfo.length; ++i) {
    			  if (this.tabsInfo[i].url == url) {
    				  this.tabsInfo.splice(i, 1);
    			  }
    		  }
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