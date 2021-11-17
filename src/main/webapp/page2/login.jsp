<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<% 
// response.addCookie(new javax.servlet.http.Cookie("SameSite", "None"));
// response.addCookie(new javax.servlet.http.Cookie("Secure", ""));
%>
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" type="text/css" href="../iview/styles/iview.css">
	<script src="../js/vue.js"></script>
	<script src="../js/axios.min.js"></script>
	<script src="../iview/iview.min.js"></script>
  
  <style scoped>
	body::-webkit-scrollbar {
		display: none; /* Chrome Safari */
	}
  
	body {
		margin: 0;
	  	padding: 0;
	  	border:0;
	    background: #f5f7f9;
	    position: relative;
	    overflow: hidden;
	    width:100%;
	    height:100%;
	}
	
	.layout {
		width: 400px;
		margin: 0 auto;
		margin-top: 200px;
	}

</style>
</head>
<body >
<div id="app" class="layout">
<card>
	<Row>
		<i-col span="24" >
			<i-input placeholder="Please Input..." v-model.trim = 'name' > 
				<span slot="prepend">User Name：</span>
			</i-input>
		</i-col>
	</Row>
	<br/>
	<Row>
		<i-col span="24" >
			<i-input placeholder="Please Input..." v-model.trim = 'password' type="password" > 
				<span slot="prepend">Password：&nbsp;&nbsp;</span>
			</i-input>
		</i-col>
	</Row>
	
	<br/>
	<Row>
		<i-col span="8" offset="10" >
			<i-button type="primary" @click="login" > Login </i-input>
		</i-col>
	</Row>
</card>
</div>
   
<script>
    var vm = new Vue({
        el: '#app',
        data: {
            name: '',
            password: '',
        },
        methods: {
            login: function() {
            	var vm = this;
          	  	var url = '<%=request.getContextPath()%>/rest/user/login';
          	    var param = {name: this.name, password: this.password};
         		axios.post(url, param).then(function (res) {
         			var d = res.data;
         			if (d.status == 'OK') {
         				// document.cookie = d.data;
         				localStorage.setItem('Auth', d.data);
         				if (d.data) {
         					window.location = 'main.jsp';
         				}
         			} else {
         				vm.$Message.error({background: true, content:'Login fail:' + d.msg, duration: 5 });
         			}
         		});
            },
        },
        
        mounted: function() {
        	var cntHeight = window.innerHeight;
        	var app = document.getElementById('app');
        	var top = (cntHeight - app.offsetHeight) / 2;
      		app.style.marginTop = '' + top + 'px';
        }
    });
    
  </script>
</body>
</html>